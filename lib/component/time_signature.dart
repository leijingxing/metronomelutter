import 'package:flutter/material.dart';

/// 拍号显示组件（如 `4/4`、`3/8`）。
class TimeSignature extends StatelessWidget {
  /// 分子（每小节拍数）。
  final int beat;

  /// 分母（以几分音符为一拍）。
  final int note;

  const TimeSignature(this.beat, this.note, {super.key});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Text(beat.toString()),
        Text('/'),
        Text(note.toString()),
      ],
    );
  }
}

