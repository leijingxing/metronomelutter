import 'package:flutter/material.dart';

/// 音高目标选择器，横向展示可选音名列表。
class PitchTargetSelector extends StatelessWidget {
  /// 候选音名（例如 `A4`、`C#4`）。
  final List<String> options;

  /// 当前已选音名。
  final String selected;

  /// 点击某个候选项后触发。
  final ValueChanged<String> onChanged;

  const PitchTargetSelector({
    super.key,
    required this.options,
    required this.selected,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Row(
        children: options.map((String note) {
          final bool isSelected = note == selected;
          return Padding(
            padding: const EdgeInsets.only(right: 8),
            child: ChoiceChip(
              label: Text(note),
              selected: isSelected,
              onSelected: (_) => onChanged(note),
            ),
          );
        }).toList(growable: false),
      ),
    );
  }
}
