import 'dart:async';

import 'package:flutter/material.dart';
import 'package:rhythm_metronome/component/pitch_curve_view.dart';
import 'package:rhythm_metronome/component/pitch_target_selector.dart';
import 'package:rhythm_metronome/config/app_theme.dart';
import 'package:rhythm_metronome/store/index.dart';
import 'package:rhythm_metronome/store/pitch_training_store.dart';
import 'package:rhythm_metronome/utils/global_function.dart';

class PitchTrainingPage extends StatefulWidget {
  const PitchTrainingPage({super.key});

  @override
  State<PitchTrainingPage> createState() => _PitchTrainingPageState();
}

class _PitchTrainingPageState extends State<PitchTrainingPage> {
  late final PitchTrainingStore _store;

  @override
  void initState() {
    super.initState();
    _store = PitchTrainingStore();
  }

  @override
  void dispose() {
    unawaited(_store.close());
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final AppTheme theme =
        AppThemes.all[appStore.themeIndex % AppThemes.all.length];
    final bool isDark = Theme.of(context).brightness == Brightness.dark;
    final Color accent = theme.accent;
    final Color primary = theme.primary;
    final Color panelColor = isDark
        ? const Color(0xFF1B2230).withValues(alpha: 0.9)
        : Colors.white.withValues(alpha: 0.92);
    final Color textSecondary = Theme.of(context).colorScheme.onSurfaceVariant;

    return Scaffold(
      appBar: AppBar(
        title: const Text('实时音准曲线'),
      ),
      body: SafeArea(
        child: AnimatedBuilder(
          animation: _store,
          builder: (BuildContext context, _) {
            final String frequencyText = _store.currentResult.frequencyHz ==
                    null
                ? '--'
                : '${_store.currentResult.frequencyHz!.toStringAsFixed(1)} Hz';
            final String noteText = _store.currentResult.noteName ?? '--';
            final String centsText = _store.currentTargetCents == null
                ? '--'
                : '${_store.currentTargetCents!.toStringAsFixed(1)} c';
            return Padding(
              padding: const EdgeInsets.fromLTRB(16, 12, 16, 16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: panelColor,
                      borderRadius: BorderRadius.circular(14),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          _store.statusText,
                          style: TextStyle(
                            color: textSecondary,
                            fontSize: 12,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Column(
                          children: [
                            Row(
                              children: [
                                Expanded(
                                  child: _ValueBadge(
                                      title: '当前音名', value: noteText),
                                ),
                                const SizedBox(width: 10),
                                Expanded(
                                  child: _ValueBadge(
                                    title: '频率',
                                    value: frequencyText,
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 8),
                            Row(
                              children: [
                                Expanded(
                                  child: _ValueBadge(
                                    title: '偏差',
                                    value: centsText,
                                  ),
                                ),
                                const SizedBox(width: 10),
                                Expanded(
                                  child: _ValueBadge(
                                    title: '目标',
                                    value:
                                        '${_store.targetNote} (${_store.targetFrequencyHz.toStringAsFixed(1)}Hz)',
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 12),
                  Text(
                    '目标音',
                    style: TextStyle(
                      color: textSecondary,
                      fontSize: 13,
                    ),
                  ),
                  const SizedBox(height: 8),
                  PitchTargetSelector(
                    options: PitchTrainingStore.selectableNotes,
                    selected: _store.targetNote,
                    onChanged: _store.setTargetNote,
                  ),
                  const SizedBox(height: 14),
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.fromLTRB(12, 10, 12, 12),
                    decoration: BoxDecoration(
                      color: panelColor,
                      borderRadius: BorderRadius.circular(14),
                    ),
                    child: Column(
                      children: [
                        Row(
                          children: [
                            Text(
                              '+50c',
                              style: TextStyle(
                                fontSize: 11,
                                color: textSecondary,
                              ),
                            ),
                            const Spacer(),
                            Text(
                              '目标线 0c',
                              style: TextStyle(
                                fontSize: 11,
                                color: textSecondary,
                              ),
                            ),
                            const Spacer(),
                            Text(
                              '-50c',
                              style: TextStyle(
                                fontSize: 11,
                                color: textSecondary,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 8),
                        PitchCurveView(
                          values: _store.centsSeries,
                          lineColor: accent,
                          targetColor: primary,
                          gridColor: Theme.of(context)
                              .dividerColor
                              .withValues(alpha: 0.34),
                          rangeCents: 50,
                          height: 230,
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 10),
                  Text(
                    _buildFeedback(_store.currentTargetCents),
                    style: TextStyle(
                      fontSize: 13,
                      color: textSecondary,
                    ),
                  ),
                  const Spacer(),
                  SizedBox(
                    width: double.infinity,
                    child: FilledButton.icon(
                      onPressed: () async {
                        if (_store.isMonitoring) {
                          await _store.stopMonitoring();
                          return;
                        }
                        final String? msg = await _store.startMonitoring();
                        if (msg != null) {
                          $warn(msg);
                        }
                      },
                      icon: Icon(
                          _store.isMonitoring ? Icons.stop : Icons.play_arrow),
                      label: Text(_store.isMonitoring ? '停止监听' : '开始监听'),
                    ),
                  ),
                ],
              ),
            );
          },
        ),
      ),
    );
  }

  String _buildFeedback(double? cents) {
    if (cents == null) {
      return '提示：保持稳定长音，曲线会显示在目标线附近。';
    }
    if (cents.abs() <= 8) {
      return '反馈：接近目标音准';
    }
    if (cents > 0) {
      return '反馈：偏高，尝试放松口风并略微降低气流角度';
    }
    return '反馈：偏低，尝试提高气流支撑并微调口型';
  }
}

class _ValueBadge extends StatelessWidget {
  final String title;
  final String value;

  const _ValueBadge({
    required this.title,
    required this.value,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      constraints: const BoxConstraints(minHeight: 56),
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface.withValues(alpha: 0.6),
        borderRadius: BorderRadius.circular(10),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            title,
            style: TextStyle(
              fontSize: 11,
              color: Theme.of(context).colorScheme.onSurfaceVariant,
            ),
          ),
          const SizedBox(height: 2),
          Text(
            value,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w700,
            ),
          ),
        ],
      ),
    );
  }
}
