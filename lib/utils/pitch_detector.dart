import 'dart:math';

class PitchFrameResult {
  final double? frequencyHz;
  final String? noteName;
  final double? centsFromNearestNote;
  final double confidence;
  final bool voiced;

  const PitchFrameResult({
    required this.frequencyHz,
    required this.noteName,
    required this.centsFromNearestNote,
    required this.confidence,
    required this.voiced,
  });

  const PitchFrameResult.unvoiced()
      : frequencyHz = null,
        noteName = null,
        centsFromNearestNote = null,
        confidence = 0,
        voiced = false;
}

class PitchDetector {
  PitchDetector({
    required this.sampleRate,
    this.minFrequencyHz = 130,
    this.maxFrequencyHz = 1200,
    this.rmsThreshold = 0.008,
    this.confidenceThreshold = 0.62,
  })  : assert(minFrequencyHz > 0),
        assert(maxFrequencyHz > minFrequencyHz),
        assert(sampleRate > 0);

  static const List<String> _noteNames = <String>[
    'C',
    'C#',
    'D',
    'D#',
    'E',
    'F',
    'F#',
    'G',
    'G#',
    'A',
    'A#',
    'B',
  ];

  final int sampleRate;
  final double minFrequencyHz;
  final double maxFrequencyHz;
  final double rmsThreshold;
  final double confidenceThreshold;

  PitchFrameResult processFrame(List<int> frameInt16) {
    if (frameInt16.length < 64) {
      return const PitchFrameResult.unvoiced();
    }

    final int n = frameInt16.length;
    final List<double> x = List<double>.filled(n, 0);
    double mean = 0;
    for (int i = 0; i < n; i++) {
      mean += frameInt16[i];
    }
    mean /= n;

    double rms = 0;
    for (int i = 0; i < n; i++) {
      final double v = (frameInt16[i] - mean) / 32768.0;
      x[i] = v;
      rms += v * v;
    }
    rms = sqrt(rms / n);
    if (!rms.isFinite || rms < rmsThreshold) {
      return const PitchFrameResult.unvoiced();
    }

    final int minLag = max(1, (sampleRate / maxFrequencyHz).floor());
    final int maxLag = min(n - 2, (sampleRate / minFrequencyHz).ceil());
    if (maxLag <= minLag) {
      return const PitchFrameResult.unvoiced();
    }

    double bestScore = -1;
    int bestLag = -1;
    for (int lag = minLag; lag <= maxLag; lag++) {
      double sum = 0;
      double e1 = 0;
      double e2 = 0;
      final int limit = n - lag;
      for (int i = 0; i < limit; i++) {
        final double a = x[i];
        final double b = x[i + lag];
        sum += a * b;
        e1 += a * a;
        e2 += b * b;
      }
      if (e1 <= 1e-12 || e2 <= 1e-12) {
        continue;
      }
      final double score = sum / sqrt(e1 * e2);
      if (score > bestScore) {
        bestScore = score;
        bestLag = lag;
      }
    }

    if (bestLag <= 0 || bestScore < confidenceThreshold) {
      return const PitchFrameResult.unvoiced();
    }

    final double freq = sampleRate / bestLag;
    if (!freq.isFinite || freq <= 0) {
      return const PitchFrameResult.unvoiced();
    }

    final int nearestMidi = frequencyToNearestMidi(freq);
    final double nearestFreq = midiToFrequency(nearestMidi);
    final double cents = 1200.0 * (log(freq / nearestFreq) / ln2);

    return PitchFrameResult(
      frequencyHz: freq,
      noteName: midiToNoteName(nearestMidi),
      centsFromNearestNote: cents,
      confidence: bestScore.clamp(0.0, 1.0),
      voiced: true,
    );
  }

  static int frequencyToNearestMidi(double frequencyHz) {
    final double midi = 69.0 + 12.0 * (log(frequencyHz / 440.0) / ln2);
    return midi.round();
  }

  static double midiToFrequency(int midi) {
    return 440.0 * pow(2.0, (midi - 69) / 12.0).toDouble();
  }

  static String midiToNoteName(int midi) {
    final int index = ((midi % 12) + 12) % 12;
    final int octave = (midi ~/ 12) - 1;
    return '${_noteNames[index]}$octave';
  }

  static double? noteNameToFrequency(String noteName) {
    final RegExp regExp = RegExp(r'^([A-Ga-g])([#b]?)(-?\d+)$');
    final Match? match = regExp.firstMatch(noteName.trim());
    if (match == null) {
      return null;
    }
    final String name = match.group(1)!.toUpperCase();
    final String accidental = match.group(2) ?? '';
    final int octave = int.parse(match.group(3)!);
    final Map<String, int> base = <String, int>{
      'C': 0,
      'D': 2,
      'E': 4,
      'F': 5,
      'G': 7,
      'A': 9,
      'B': 11,
    };
    int semitone = base[name]!;
    if (accidental == '#') {
      semitone += 1;
    } else if (accidental == 'b') {
      semitone -= 1;
    }
    final int midi = (octave + 1) * 12 + semitone;
    return midiToFrequency(midi);
  }
}
