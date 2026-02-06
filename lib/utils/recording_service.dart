import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:path_provider/path_provider.dart';
import 'package:record/record.dart';
import 'package:rhythm_metronome/model/recording_clip.dart';
import 'package:uuid/uuid.dart';

class RecordingStopResult {
  final String filePath;
  final int durationMs;

  const RecordingStopResult({
    required this.filePath,
    required this.durationMs,
  });
}

class RecordingService {
  static const int defaultSampleRate = 44100;
  static const int defaultBitRate = 128000;
  static const String _recordingsDirName = 'recordings';
  static const String _indexFileName = 'index.json';

  final AudioRecorder _recorder = AudioRecorder();
  final Uuid _uuid = const Uuid();

  Directory? _recordingsDir;
  DateTime? _startTime;

  Future<void> init() async {
    if (_recordingsDir != null) {
      return;
    }
    final Directory appDocDir = await getApplicationDocumentsDirectory();
    final String recordingsPath =
        '${appDocDir.path}${Platform.pathSeparator}$_recordingsDirName';
    final Directory dir = Directory(recordingsPath);
    if (!await dir.exists()) {
      await dir.create(recursive: true);
    }
    final File indexFile = File('${dir.path}${Platform.pathSeparator}$_indexFileName');
    if (!await indexFile.exists()) {
      await indexFile.writeAsString('[]');
    }
    _recordingsDir = dir;
  }

  Stream<double> amplitudeStream({Duration interval = const Duration(milliseconds: 40)}) {
    return _recorder.onAmplitudeChanged(interval).map((Amplitude amp) {
      // record package amplitude is dBFS in [-160, 0], normalize into [0, 1].
      final double normalized = ((amp.current + 60) / 60).clamp(0.0, 1.0);
      return normalized.isFinite ? normalized : 0.0;
    });
  }

  Future<bool> ensurePermission() async {
    return _recorder.hasPermission();
  }

  Future<String> start() async {
    await init();
    final String id = _uuid.v4();
    final String filePath =
        '${_recordingsDir!.path}${Platform.pathSeparator}$id.m4a';
    await _recorder.start(
      const RecordConfig(
        encoder: AudioEncoder.aacLc,
        sampleRate: defaultSampleRate,
        bitRate: defaultBitRate,
        numChannels: 1,
      ),
      path: filePath,
    );
    _startTime = DateTime.now();
    return filePath;
  }

  Future<RecordingStopResult?> stop() async {
    if (!await _recorder.isRecording()) {
      return null;
    }
    final String? filePath = await _recorder.stop();
    final DateTime startedAt = _startTime ?? DateTime.now();
    _startTime = null;
    if (filePath == null || filePath.isEmpty) {
      return null;
    }
    final int durationMs = DateTime.now().difference(startedAt).inMilliseconds;
    return RecordingStopResult(
      filePath: filePath,
      durationMs: durationMs,
    );
  }

  Future<void> cancel() async {
    if (!await _recorder.isRecording()) {
      return;
    }
    final String? filePath = await _recorder.stop();
    _startTime = null;
    if (filePath == null || filePath.isEmpty) {
      return;
    }
    final File file = File(filePath);
    if (await file.exists()) {
      await file.delete();
    }
  }

  Future<List<RecordingClip>> loadClips() async {
    await init();
    final File indexFile = _indexFile();
    final String content = await indexFile.readAsString();
    if (content.trim().isEmpty) {
      return <RecordingClip>[];
    }
    final dynamic decoded = jsonDecode(content);
    if (decoded is! List<dynamic>) {
      return <RecordingClip>[];
    }
    final List<RecordingClip> clips = decoded
        .whereType<Map>()
        .map((Map<dynamic, dynamic> e) =>
            RecordingClip.fromJson(Map<String, dynamic>.from(e)))
        .toList();
    clips.sort((RecordingClip a, RecordingClip b) => b.createdAt.compareTo(a.createdAt));
    return clips;
  }

  Future<void> saveClips(List<RecordingClip> clips) async {
    await init();
    final File indexFile = _indexFile();
    final String encoded = jsonEncode(clips.map((RecordingClip e) => e.toJson()).toList());
    await indexFile.writeAsString(encoded);
  }

  Future<void> deleteFile(String filePath) async {
    final File file = File(filePath);
    if (await file.exists()) {
      await file.delete();
    }
  }

  Future<bool> existsFile(String filePath) async {
    return File(filePath).exists();
  }

  Future<void> dispose() async {
    if (await _recorder.isRecording()) {
      await _recorder.stop();
    }
    await _recorder.dispose();
  }

  File _indexFile() {
    return File(
      '${_recordingsDir!.path}${Platform.pathSeparator}$_indexFileName',
    );
  }
}
