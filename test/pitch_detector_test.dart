import 'dart:math';

import 'package:flutter_test/flutter_test.dart';
import 'package:rhythm_metronome/utils/pitch_detector.dart';

void main() {
  group('PitchDetector mapping', () {
    test('noteNameToFrequency A4', () {
      final double? freq = PitchDetector.noteNameToFrequency('A4');
      expect(freq, isNotNull);
      expect((freq! - 440).abs() < 0.0001, isTrue);
    });

    test('midiToNoteName 69', () {
      expect(PitchDetector.midiToNoteName(69), 'A4');
    });
  });

  group('PitchDetector processFrame', () {
    test('detects A4 from sine wave frame', () {
      const int sampleRate = 44100;
      const int frameSize = 2048;
      const double frequency = 440;
      final PitchDetector detector = PitchDetector(sampleRate: sampleRate);
      final List<int> frame = List<int>.generate(frameSize, (int i) {
        final double sample = sin(2 * pi * frequency * i / sampleRate);
        return (sample * 24000).round();
      });

      final PitchFrameResult result = detector.processFrame(frame);
      expect(result.voiced, isTrue);
      expect(result.frequencyHz, isNotNull);
      expect((result.frequencyHz! - frequency).abs() < 8, isTrue);
      expect(result.noteName, 'A4');
    });
  });
}
