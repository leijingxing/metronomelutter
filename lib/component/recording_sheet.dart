import 'package:flutter/material.dart';
import 'package:flutter_mobx/flutter_mobx.dart';
import 'package:rhythm_metronome/component/waveform_view.dart';
import 'package:rhythm_metronome/config/app_theme.dart';
import 'package:rhythm_metronome/model/recording_clip.dart';
import 'package:rhythm_metronome/store/index.dart';
import 'package:rhythm_metronome/store/recording_store.dart';
import 'package:rhythm_metronome/utils/global_function.dart';

class RecordingSheet extends StatelessWidget {
  final RecordingStore store;
  final Future<void> Function() onRequestToggleMetronome;
  final bool Function() isMetronomeRunning;

  const RecordingSheet({
    super.key,
    required this.store,
    required this.onRequestToggleMetronome,
    required this.isMetronomeRunning,
  });

  @override
  Widget build(BuildContext context) {
    final bool isDark = Theme.of(context).brightness == Brightness.dark;
    final AppTheme theme = AppThemes.all[appStore.themeIndex % AppThemes.all.length];
    final Color accent = theme.accent;
    final Color primary = theme.primary;
    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(16, 14, 16, 16),
        child: Observer(
          builder: (_) => Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  const Expanded(
                    child: Text(
                      '录音',
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),
                  IconButton(
                    onPressed: () async {
                      if (store.isRecording) {
                        final String? msg = await store.stopRecord();
                        if (msg != null) {
                          $warn(msg);
                        }
                      }
                      store.closeSheet();
                      Navigator.pop(context);
                    },
                    icon: const Icon(Icons.close),
                  ),
                ],
              ),
              Row(
                children: [
                  Expanded(
                    child: Text(
                      '录音时播放节拍器',
                      style: TextStyle(
                        fontSize: 14,
                        color: Theme.of(context).colorScheme.onSurfaceVariant,
                      ),
                    ),
                  ),
                  Switch(
                    value: store.withMetronome,
                    onChanged: (bool value) {
                      store.setWithMetronome(value);
                    },
                  ),
                ],
              ),
              const SizedBox(height: 10),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
                decoration: BoxDecoration(
                  color: isDark
                      ? const Color(0xFF1D2432).withOpacity(0.95)
                      : Colors.white.withOpacity(0.92),
                  borderRadius: BorderRadius.circular(14),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      store.isRecording
                          ? '录音中 ${_formatDuration(store.recordElapsedMs)}'
                          : '实时波形预览',
                      style: TextStyle(
                        fontSize: 13,
                        color: Theme.of(context).colorScheme.onSurfaceVariant,
                      ),
                    ),
                    const SizedBox(height: 8),
                    WaveformView(
                      peaks: store.livePeaks.toList(growable: false),
                      live: true,
                      color: accent.withOpacity(0.45),
                      progressColor: accent,
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 12),
              SizedBox(
                width: double.infinity,
                child: FilledButton.icon(
                  onPressed: () async {
                    if (store.isRecording) {
                      final String? msg = await store.stopRecord();
                      if (msg != null) {
                        $warn(msg);
                      }
                      return;
                    }
                    if (store.withMetronome && !isMetronomeRunning()) {
                      await onRequestToggleMetronome();
                    }
                    final String? msg = await store.startRecord();
                    if (msg != null) {
                      $warn(msg);
                    }
                  },
                  style: FilledButton.styleFrom(
                    backgroundColor: store.isRecording ? Colors.redAccent : primary,
                    padding: const EdgeInsets.symmetric(vertical: 12),
                  ),
                  icon: Icon(
                    store.isRecording ? Icons.stop_circle : Icons.fiber_manual_record,
                  ),
                  label: Text(store.isRecording ? '停止录音' : '开始录音'),
                ),
              ),
              const SizedBox(height: 14),
              Text(
                '历史录音',
                style: TextStyle(
                  color: Theme.of(context).colorScheme.onSurfaceVariant,
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: 8),
              if (store.clips.isEmpty)
                Padding(
                  padding: const EdgeInsets.only(bottom: 10),
                  child: Text(
                    '暂无录音，点击上方按钮开始录制',
                    style: TextStyle(
                      color: Theme.of(context).colorScheme.onSurfaceVariant,
                    ),
                  ),
                ),
              ConstrainedBox(
                constraints: const BoxConstraints(maxHeight: 260),
                child: ListView.separated(
                  shrinkWrap: true,
                  itemCount: store.clips.length,
                  separatorBuilder: (_, __) => const SizedBox(height: 8),
                  itemBuilder: (BuildContext context, int index) {
                    final RecordingClip clip = store.clips[index];
                    return Observer(
                      builder: (_) {
                        final bool isActive = store.activeClipId == clip.id;
                        return _ClipItem(
                          clip: clip,
                          accent: accent,
                          isActive: isActive,
                          isPlaying: isActive && store.isPlaying,
                          isPaused: isActive && store.isPaused,
                          progress: isActive ? store.playbackProgress : 0,
                          positionMs: isActive ? store.playbackPositionMs : 0,
                          durationMs: isActive ? store.playbackDurationMs : clip.durationMs,
                          onPlayTap: () async {
                            debugPrint(
                              '[RecordingSheet] onPlayTap clipId=${clip.id} isActive=$isActive isPlaying=${store.isPlaying} isPaused=${store.isPaused}',
                            );
                            final String? msg = await store.playClip(clip.id);
                            debugPrint(
                              '[RecordingSheet] onPlayTap done clipId=${clip.id} msg=$msg activeClipId=${store.activeClipId} isPlaying=${store.isPlaying} isPaused=${store.isPaused} progress=${store.playbackProgress}',
                            );
                            if (msg != null) {
                              $warn(msg);
                            }
                          },
                          onPauseTap: () async {
                            debugPrint(
                              '[RecordingSheet] onPauseTap clipId=${clip.id} activeClipId=${store.activeClipId} isPlaying=${store.isPlaying}',
                            );
                            await store.pausePlay();
                            debugPrint(
                              '[RecordingSheet] onPauseTap done clipId=${clip.id} isPlaying=${store.isPlaying} isPaused=${store.isPaused} progress=${store.playbackProgress}',
                            );
                          },
                          onResumeTap: () async {
                            debugPrint(
                              '[RecordingSheet] onResumeTap clipId=${clip.id} activeClipId=${store.activeClipId} isPaused=${store.isPaused}',
                            );
                            await store.resumePlay();
                            debugPrint(
                              '[RecordingSheet] onResumeTap done clipId=${clip.id} isPlaying=${store.isPlaying} isPaused=${store.isPaused} progress=${store.playbackProgress}',
                            );
                          },
                          onSeek: (double value) async {
                            debugPrint(
                              '[RecordingSheet] onSeek clipId=${clip.id} value=$value activeClipId=${store.activeClipId} durationMs=${store.playbackDurationMs}',
                            );
                            await store.seekToProgress(value);
                            debugPrint(
                              '[RecordingSheet] onSeek done clipId=${clip.id} positionMs=${store.playbackPositionMs} progress=${store.playbackProgress}',
                            );
                          },
                          onDeleteTap: () async {
                            debugPrint(
                              '[RecordingSheet] onDeleteTap clipId=${clip.id} activeClipId=${store.activeClipId}',
                            );
                            await store.deleteClip(clip.id);
                            debugPrint(
                              '[RecordingSheet] onDeleteTap done clipId=${clip.id} clipsCount=${store.clips.length}',
                            );
                          },
                        );
                      },
                    );
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _ClipItem extends StatelessWidget {
  final RecordingClip clip;
  final Color accent;
  final bool isActive;
  final bool isPlaying;
  final bool isPaused;
  final double progress;
  final int positionMs;
  final int durationMs;
  final VoidCallback onPlayTap;
  final VoidCallback onPauseTap;
  final VoidCallback onResumeTap;
  final Future<void> Function(double value) onSeek;
  final VoidCallback onDeleteTap;

  const _ClipItem({
    required this.clip,
    required this.accent,
    required this.isActive,
    required this.isPlaying,
    required this.isPaused,
    required this.progress,
    required this.positionMs,
    required this.durationMs,
    required this.onPlayTap,
    required this.onPauseTap,
    required this.onResumeTap,
    required this.onSeek,
    required this.onDeleteTap,
  });

  @override
  Widget build(BuildContext context) {
    final bool isDark = Theme.of(context).brightness == Brightness.dark;
    final Color bg = isDark ? const Color(0xFF1A2230) : const Color(0xFFF8FAFF);
    return Container(
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  '${_formatDateTime(clip.createdAt)}  ·  ${_formatDuration(clip.durationMs)}',
                  style: TextStyle(
                    fontSize: 12,
                    color: Theme.of(context).colorScheme.onSurfaceVariant,
                  ),
                ),
              ),
              IconButton(
                onPressed: () {
                  if (isPlaying) {
                    onPauseTap();
                    return;
                  }
                  if (isPaused) {
                    onResumeTap();
                    return;
                  }
                  onPlayTap();
                },
                icon: Icon(
                  isPlaying
                      ? Icons.pause_circle_filled
                      : (isPaused ? Icons.play_circle_fill : Icons.play_circle_fill),
                  color: accent,
                ),
              ),
              IconButton(
                onPressed: onDeleteTap,
                icon: const Icon(Icons.delete_outline),
              ),
            ],
          ),
          WaveformView(
            peaks: clip.waveformPeaks,
            live: false,
            progress: progress,
            color: accent.withOpacity(0.32),
            progressColor: accent,
            height: 56,
          ),
          const SizedBox(height: 4),
          Row(
            children: [
              Expanded(
                child: SliderTheme(
                  data: SliderTheme.of(context).copyWith(
                    trackHeight: 2.6,
                    thumbShape: const RoundSliderThumbShape(enabledThumbRadius: 6),
                  ),
                  child: Slider(
                    min: 0,
                    max: 1,
                    value: progress.clamp(0.0, 1.0),
                    onChanged: isActive
                        ? (double value) {
                            onSeek(value);
                          }
                        : null,
                  ),
                ),
              ),
              SizedBox(
                width: 90,
                child: Text(
                  '${_formatDuration(positionMs)} / ${_formatDuration(durationMs)}',
                  textAlign: TextAlign.right,
                  style: TextStyle(
                    fontSize: 11,
                    color: Theme.of(context).colorScheme.onSurfaceVariant,
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

String _formatDuration(int durationMs) {
  final int totalSec = durationMs ~/ 1000;
  final int minute = totalSec ~/ 60;
  final int second = totalSec % 60;
  final String mm = minute.toString().padLeft(2, '0');
  final String ss = second.toString().padLeft(2, '0');
  return '$mm:$ss';
}

String _formatDateTime(DateTime dt) {
  final String month = dt.month.toString().padLeft(2, '0');
  final String day = dt.day.toString().padLeft(2, '0');
  final String hour = dt.hour.toString().padLeft(2, '0');
  final String minute = dt.minute.toString().padLeft(2, '0');
  return '$month-$day $hour:$minute';
}
