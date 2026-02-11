import 'package:flutter/material.dart';

class PitchTargetSelector extends StatelessWidget {
  final List<String> options;
  final String selected;
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
