import 'package:flutter/material.dart';
import 'package:metronomelutter/config/app_theme.dart';
import 'package:metronomelutter/store/index.dart';

Future<int?> changeSound(BuildContext context) async {
  final AppTheme theme = AppThemes.all[appStore.themeIndex % AppThemes.all.length];
  final Color primary = theme.primary;

  final int? i = await showModalBottomSheet<int>(
    context: context,
    showDragHandle: true,
    backgroundColor: Theme.of(context).colorScheme.surface,
    shape: const RoundedRectangleBorder(
      borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
    ),
    builder: (BuildContext context) {
      final options = <Map<String, dynamic>>[
        {'label': '音效一', 'value': 0},
        {'label': '音效二', 'value': 1},
        {'label': 'woodblocks', 'value': 2},
        {'label': 'beep', 'value': 3},
        {'label': 'beep2', 'value': 4},
        {'label': '牛铃', 'value': 5},
        {'label': '钟', 'value': 6},
        // 高 bpm 时一些手机声音播放不完全
        {'label': '鼓', 'value': 7},
      ];

      return SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(16, 8, 16, 16),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Align(
                alignment: Alignment.centerLeft,
                child: Text(
                  '请选择音效',
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.w700,
                        letterSpacing: 0.6,
                      ),
                ),
              ),
              const SizedBox(height: 12),
              Wrap(
                spacing: 10,
                runSpacing: 10,
                children: options.map((opt) {
                  return ChoiceChip(
                    label: Text(opt['label'] as String),
                    selected: false,
                    onSelected: (_) => Navigator.pop(context, opt['value'] as int),
                    selectedColor: primary.withOpacity(0.18),
                    backgroundColor: Theme.of(context).colorScheme.surfaceVariant,
                    labelStyle: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          color: Theme.of(context).colorScheme.onSurface,
                        ),
                  );
                }).toList(),
              ),
            ],
          ),
        ),
      );
    },
  );
  return i;
}
