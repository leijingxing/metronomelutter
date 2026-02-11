import 'dart:async';
import 'dart:math';

import 'package:flutter/foundation.dart';
import 'package:record/record.dart';
import 'package:rhythm_metronome/utils/pitch_detector.dart';

class PitchTrainingStore extends ChangeNotifier {
  static const int _sampleRate = 44100;
  static const int _frameSize = 2048;
  static const int _hopSize = 1024;
  static const int _maxPoints = 180;
  static const int _uiRefreshMs = 33;
  static const double _smoothingAlpha = 0.22;

  static const List<String> selectableNotes = <String>[
    'C4',
    'C#4',
    'D4',
    'D#4',
    'E4',
    'F4',
    'F#4',
    'G4',
    'G#4',
    'A4',
    'A#4',
    'B4',
    'C5',
    'C#5',
    'D5',
    'D#5',
    'E5',
    'F5',
    'F#5',
    'G5',
    'G#5',
    'A5',
    'A#5',
    'B5',
  ];

  final AudioRecorder _recorder = AudioRecorder();
  final PitchDetector _detector = PitchDetector(sampleRate: _sampleRate);
  final List<double?> _centsSeries = <double?>[];
  final List<int> _pcmSamples = <int>[];

  StreamSubscription<Uint8List>? _streamSubscription;
  DateTime _lastUiUpdate = DateTime.fromMillisecondsSinceEpoch(0);
  int _unvoicedFrames = 0;

  bool _isMonitoring = false;
  String _statusText = '未开始';
  String _targetNote = 'D4';
  double _targetFrequencyHz = PitchDetector.noteNameToFrequency('D4') ?? 293.66;
  PitchFrameResult _currentResult = const PitchFrameResult.unvoiced();
  double? _currentTargetCents;
  double? _smoothedCents;

  bool get isMonitoring => _isMonitoring;
  String get statusText => _statusText;
  String get targetNote => _targetNote;
  double get targetFrequencyHz => _targetFrequencyHz;
  PitchFrameResult get currentResult => _currentResult;
  double? get currentTargetCents => _currentTargetCents;
  List<double?> get centsSeries =>
      List<double?>.of(_centsSeries, growable: false);

  Future<String?> startMonitoring() async {
    if (_isMonitoring) {
      return null;
    }
    final bool hasPermission = await _recorder.hasPermission();
    if (!hasPermission) {
      return '需要麦克风权限才能检测音准';
    }
    try {
      final Stream<Uint8List> stream = await _recorder.startStream(
        const RecordConfig(
          encoder: AudioEncoder.pcm16bits,
          sampleRate: _sampleRate,
          numChannels: 1,
        ),
      );
      _resetForStart();
      _streamSubscription = stream.listen(
        _handleChunk,
        onError: (_) {
          _statusText = '音频流异常';
          _isMonitoring = false;
          notifyListeners();
        },
        onDone: () {
          _isMonitoring = false;
          _statusText = '已停止';
          notifyListeners();
        },
      );
      _isMonitoring = true;
      _statusText = '监听中';
      notifyListeners();
      return null;
    } catch (e) {
      return '启动监听失败: $e';
    }
  }

  Future<void> stopMonitoring() async {
    await _streamSubscription?.cancel();
    _streamSubscription = null;
    if (await _recorder.isRecording()) {
      await _recorder.stop();
    }
    _isMonitoring = false;
    _statusText = '未开始';
    _pcmSamples.clear();
    _smoothedCents = null;
    notifyListeners();
  }

  void setTargetNote(String noteName) {
    final double? frequency = PitchDetector.noteNameToFrequency(noteName);
    if (frequency == null) {
      return;
    }
    _targetNote = noteName;
    _targetFrequencyHz = frequency;
    final double? currentFrequency = _currentResult.frequencyHz;
    if (currentFrequency != null) {
      _currentTargetCents = _calcCentsAgainstTarget(currentFrequency);
    } else {
      _currentTargetCents = null;
    }
    notifyListeners();
  }

  Future<void> close() async {
    await stopMonitoring();
    await _recorder.dispose();
  }

  void _resetForStart() {
    _centsSeries.clear();
    _pcmSamples.clear();
    _currentResult = const PitchFrameResult.unvoiced();
    _currentTargetCents = null;
    _smoothedCents = null;
    _unvoicedFrames = 0;
    _lastUiUpdate = DateTime.fromMillisecondsSinceEpoch(0);
  }

  void _handleChunk(Uint8List bytes) {
    if (!_isMonitoring) {
      return;
    }
    if (bytes.isEmpty) {
      return;
    }
    final ByteData byteData = ByteData.sublistView(bytes);
    final int sampleCount = bytes.length ~/ 2;
    for (int i = 0; i < sampleCount; i++) {
      _pcmSamples.add(byteData.getInt16(i * 2, Endian.little));
    }

    while (_pcmSamples.length >= _frameSize) {
      final List<int> frame = _pcmSamples.sublist(0, _frameSize);
      _pcmSamples.removeRange(0, _hopSize);
      _consumeFrame(frame);
    }
  }

  void _consumeFrame(List<int> frame) {
    final PitchFrameResult result = _detector.processFrame(frame);
    _currentResult = result;

    if (!result.voiced || result.frequencyHz == null) {
      _unvoicedFrames += 1;
      _currentTargetCents = null;
      _smoothedCents = null;
      _appendSeries(null);
      _statusText = _unvoicedFrames >= 8 ? '无稳定音高' : '监听中';
      _notifyThrottled();
      return;
    }

    _unvoicedFrames = 0;
    _statusText = '监听中';
    final double rawCents = _calcCentsAgainstTarget(result.frequencyHz!);
    final double next = _smoothedCents == null
        ? rawCents
        : (_smoothedCents! * (1 - _smoothingAlpha)) +
            (rawCents * _smoothingAlpha);
    _smoothedCents = next;
    _currentTargetCents = next;
    _appendSeries(next.clamp(-80.0, 80.0));
    _notifyThrottled();
  }

  double _calcCentsAgainstTarget(double frequencyHz) {
    return 1200.0 * (log(frequencyHz / _targetFrequencyHz) / ln2);
  }

  void _appendSeries(double? value) {
    _centsSeries.add(value);
    if (_centsSeries.length > _maxPoints) {
      _centsSeries.removeAt(0);
    }
  }

  void _notifyThrottled() {
    final DateTime now = DateTime.now();
    if (now.difference(_lastUiUpdate).inMilliseconds >= _uiRefreshMs) {
      _lastUiUpdate = now;
      notifyListeners();
    }
  }
}
