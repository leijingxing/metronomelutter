class RecordingClip {
  final String id;
  final String filePath;
  final DateTime createdAt;
  final int durationMs;
  final int sampleRate;
  final int bitRate;
  final bool withMetronome;
  final List<double> waveformPeaks;

  const RecordingClip({
    required this.id,
    required this.filePath,
    required this.createdAt,
    required this.durationMs,
    required this.sampleRate,
    required this.bitRate,
    required this.withMetronome,
    required this.waveformPeaks,
  });

  factory RecordingClip.fromJson(Map<String, dynamic> json) {
    return RecordingClip(
      id: json['id'] as String? ?? '',
      filePath: json['filePath'] as String? ?? '',
      createdAt: DateTime.tryParse(json['createdAt'] as String? ?? '') ??
          DateTime.fromMillisecondsSinceEpoch(0),
      durationMs: json['durationMs'] as int? ?? 0,
      sampleRate: json['sampleRate'] as int? ?? 44100,
      bitRate: json['bitRate'] as int? ?? 128000,
      withMetronome: json['withMetronome'] as bool? ?? false,
      waveformPeaks: ((json['waveformPeaks'] as List<dynamic>?) ?? <dynamic>[])
          .map((dynamic e) => (e as num).toDouble())
          .toList(),
    );
  }

  Map<String, dynamic> toJson() {
    return <String, dynamic>{
      'id': id,
      'filePath': filePath,
      'createdAt': createdAt.toIso8601String(),
      'durationMs': durationMs,
      'sampleRate': sampleRate,
      'bitRate': bitRate,
      'withMetronome': withMetronome,
      'waveformPeaks': waveformPeaks,
    };
  }
}
