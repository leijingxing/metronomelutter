import 'dart:async';
import 'dart:math';

import 'package:audioplayers/audioplayers.dart';
import 'package:mobx/mobx.dart';
import 'package:rhythm_metronome/model/recording_clip.dart';
import 'package:rhythm_metronome/utils/recording_service.dart';

part 'recording_store.g.dart';

class RecordingStore = _RecordingStore with _$RecordingStore;

abstract class _RecordingStore with Store {
  _RecordingStore() {
    _bindPlayerStream();
  }

  static const int _livePeakMaxCount = 240;
  static const int _savedPeakCount = 300;

  final RecordingService _service = RecordingService();
  final AudioPlayer _player = AudioPlayer();

  StreamSubscription<double>? _ampSubscription;
  StreamSubscription<Duration>? _positionSubscription;
  StreamSubscription<void>? _completeSubscription;
  Timer? _recordTimer;
  Timer? _playbackPollTimer;

  int _playingDurationMs = 1;

  @observable
  bool initialized = false;

  @observable
  bool isSheetOpen = false;

  @observable
  bool isRecording = false;

  @observable
  bool isPlaying = false;

  @observable
  bool isPaused = false;

  @observable
  bool withMetronome = false;

  @observable
  String activeClipId = '';

  @observable
  double currentAmp = 0;

  @observable
  int recordElapsedMs = 0;

  @observable
  double playbackProgress = 0;

  @observable
  int playbackPositionMs = 0;

  @observable
  int playbackDurationMs = 0;

  @observable
  ObservableList<double> livePeaks = ObservableList<double>();

  @observable
  ObservableList<RecordingClip> clips = ObservableList<RecordingClip>();

  @action
  Future<void> init() async {
    if (initialized) {
      return;
    }
    await _service.init();
    await loadClips();
    initialized = true;
  }

  @action
  void openSheet() {
    isSheetOpen = true;
  }

  @action
  void closeSheet() {
    isSheetOpen = false;
  }

  @action
  void setWithMetronome(bool value) {
    withMetronome = value;
  }

  @action
  Future<String?> startRecord() async {
    if (isRecording) {
      return null;
    }
    final bool hasPermission = await _service.ensurePermission();
    if (!hasPermission) {
      return '需要麦克风权限才能录音';
    }
    if (isPlaying) {
      await stopPlay();
    }
    livePeaks = ObservableList<double>();
    recordElapsedMs = 0;
    currentAmp = 0;
    await _service.start();
    _listenAmplitude();
    _startRecordTimer();
    isRecording = true;
    return null;
  }

  @action
  Future<String?> stopRecord() async {
    if (!isRecording) {
      return null;
    }
    final RecordingStopResult? result = await _service.stop();
    await _ampSubscription?.cancel();
    _ampSubscription = null;
    _recordTimer?.cancel();
    _recordTimer = null;
    isRecording = false;
    currentAmp = 0;
    if (result == null) {
      return '录音结束失败';
    }
    final String id = _extractIdFromPath(result.filePath);
    final RecordingClip clip = RecordingClip(
      id: id,
      filePath: result.filePath,
      createdAt: DateTime.now(),
      durationMs: max(result.durationMs, 1),
      sampleRate: RecordingService.defaultSampleRate,
      bitRate: RecordingService.defaultBitRate,
      withMetronome: withMetronome,
      waveformPeaks: _compressPeaks(livePeaks.toList(), _savedPeakCount),
    );
    clips.insert(0, clip);
    await _service.saveClips(clips.toList(growable: false));
    livePeaks = ObservableList<double>();
    recordElapsedMs = 0;
    return null;
  }

  @action
  Future<void> cancelRecord() async {
    if (!isRecording) {
      return;
    }
    await _service.cancel();
    await _ampSubscription?.cancel();
    _ampSubscription = null;
    _recordTimer?.cancel();
    _recordTimer = null;
    isRecording = false;
    currentAmp = 0;
    recordElapsedMs = 0;
    livePeaks = ObservableList<double>();
  }

  @action
  Future<void> loadClips() async {
    final List<RecordingClip> loaded = await _service.loadClips();
    final List<RecordingClip> valid = <RecordingClip>[];
    bool changed = false;
    for (final RecordingClip clip in loaded) {
      if (await _service.existsFile(clip.filePath)) {
        valid.add(clip);
      } else {
        changed = true;
      }
    }
    clips = ObservableList<RecordingClip>.of(valid);
    if (changed) {
      await _service.saveClips(valid);
    }
  }

  @action
  Future<String?> playClip(String id) async {
    if (isRecording) {
      return '录音中无法回放';
    }
    final RecordingClip? clip = _findClipById(id);
    if (clip == null) {
      return '录音不存在';
    }
    final bool exists = await _service.existsFile(clip.filePath);
    if (!exists) {
      await deleteClip(clip.id);
      return '录音文件已丢失，已从列表移除';
    }
    if (activeClipId == clip.id && isPaused) {
      await resumePlay();
      return null;
    }
    if (activeClipId == clip.id && isPlaying) {
      return null;
    }
    try {
      final String path = clip.filePath.trim();
      final Source source = path.startsWith('file://')
          ? UrlSource(path)
          : DeviceFileSource(path);
      await _player.stop();
      await _player.setReleaseMode(ReleaseMode.stop);
      await _player.play(source);
      activeClipId = clip.id;
      _playingDurationMs = max(clip.durationMs, 1);
      playbackDurationMs = _playingDurationMs;
      playbackPositionMs = 0;
      playbackProgress = 0;
      isPlaying = true;
      isPaused = false;
      _startPlaybackPoll();
      return null;
    } catch (e) {
      return '播放失败: $e';
    }
  }

  @action
  Future<void> stopPlay() async {
    await _player.stop();
    _stopPlaybackPoll();
    isPlaying = false;
    isPaused = false;
    playbackProgress = 0;
    playbackPositionMs = 0;
    playbackDurationMs = 0;
    activeClipId = '';
  }

  @action
  Future<void> pausePlay() async {
    if (!isPlaying) {
      return;
    }
    await _player.pause();
    _stopPlaybackPoll();
    isPlaying = false;
    isPaused = true;
  }

  @action
  Future<void> resumePlay() async {
    if (!isPaused) {
      return;
    }
    await _player.resume();
    _startPlaybackPoll();
    isPlaying = true;
    isPaused = false;
  }

  @action
  Future<void> seekToProgress(double progress) async {
    if (activeClipId.isEmpty || playbackDurationMs <= 0) {
      return;
    }
    final int targetMs =
        (playbackDurationMs * progress.clamp(0.0, 1.0)).round().clamp(0, playbackDurationMs);
    await _player.seek(Duration(milliseconds: targetMs));
    playbackPositionMs = targetMs;
    playbackProgress = targetMs / playbackDurationMs;
  }

  @action
  Future<void> deleteClip(String id) async {
    final RecordingClip? clip = _findClipById(id);
    if (clip == null) {
      return;
    }
    if (activeClipId == id && isPlaying) {
      await stopPlay();
    }
    clips.removeWhere((RecordingClip e) => e.id == id);
    await _service.saveClips(clips.toList(growable: false));
    await _service.deleteFile(clip.filePath);
  }

  Future<void> dispose() async {
    _recordTimer?.cancel();
    _stopPlaybackPoll();
    await _ampSubscription?.cancel();
    await _positionSubscription?.cancel();
    await _completeSubscription?.cancel();
    await _player.dispose();
    await _service.dispose();
  }

  void _listenAmplitude() {
    _ampSubscription?.cancel();
    _ampSubscription = _service.amplitudeStream().listen((double value) {
      currentAmp = value;
      livePeaks.add(value);
      if (livePeaks.length > _livePeakMaxCount) {
        livePeaks.removeAt(0);
      }
    });
  }

  void _startRecordTimer() {
    _recordTimer?.cancel();
    _recordTimer = Timer.periodic(const Duration(milliseconds: 100), (Timer timer) {
      recordElapsedMs += 100;
    });
  }

  void _bindPlayerStream() {
    _positionSubscription = _player.onPositionChanged.listen((Duration position) {
      if (!isPlaying) {
        return;
      }
      final int posMs = position.inMilliseconds;
      playbackPositionMs = posMs.clamp(0, playbackDurationMs);
      playbackProgress = (posMs / _playingDurationMs).clamp(0.0, 1.0);
    });
    _completeSubscription = _player.onPlayerComplete.listen((_) {
      _stopPlaybackPoll();
      isPlaying = false;
      isPaused = false;
      playbackPositionMs = playbackDurationMs;
      playbackProgress = 1;
    });
  }

  String _extractIdFromPath(String filePath) {
    final String normalized = filePath.replaceAll('\\', '/');
    final String filename = normalized.split('/').last;
    final int dotIndex = filename.lastIndexOf('.');
    if (dotIndex == -1) {
      return filename;
    }
    return filename.substring(0, dotIndex);
  }

  List<double> _compressPeaks(List<double> source, int targetCount) {
    if (source.isEmpty || targetCount <= 0) {
      return <double>[];
    }
    if (source.length <= targetCount) {
      return source;
    }
    final double bucketSize = source.length / targetCount;
    final List<double> result = <double>[];
    for (int i = 0; i < targetCount; i++) {
      final int start = (i * bucketSize).floor();
      final int end = min(source.length, ((i + 1) * bucketSize).ceil());
      double maxV = 0;
      for (int j = start; j < end; j++) {
        if (source[j] > maxV) {
          maxV = source[j];
        }
      }
      result.add(maxV.clamp(0.0, 1.0));
    }
    return result;
  }

  RecordingClip? _findClipById(String id) {
    for (final RecordingClip clip in clips) {
      if (clip.id == id) {
        return clip;
      }
    }
    return null;
  }

  void _startPlaybackPoll() {
    _stopPlaybackPoll();
    _playbackPollTimer =
        Timer.periodic(const Duration(milliseconds: 150), (_) async {
      if (!isPlaying) {
        return;
      }
      final Duration? position = await _player.getCurrentPosition();
      final Duration? duration = await _player.getDuration();
      final int posMs = (position?.inMilliseconds ?? 0).clamp(0, 1 << 31);
      final int durMs = max(
        duration?.inMilliseconds ?? playbackDurationMs,
        max(playbackDurationMs, 1),
      );
      playbackDurationMs = durMs;
      playbackPositionMs = posMs.clamp(0, durMs);
      playbackProgress = (playbackPositionMs / durMs).clamp(0.0, 1.0);
    });
  }

  void _stopPlaybackPoll() {
    _playbackPollTimer?.cancel();
    _playbackPollTimer = null;
  }
}
