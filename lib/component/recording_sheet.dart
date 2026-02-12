import 'package:flutter/material.dart';
import 'package:flutter_mobx/flutter_mobx.dart';
import 'package:rhythm_metronome/component/waveform_view.dart';
import 'package:rhythm_metronome/config/app_theme.dart';
import 'package:rhythm_metronome/model/recording_clip.dart';
import 'package:rhythm_metronome/store/index.dart';
import 'package:rhythm_metronome/store/recording_store.dart';
import 'package:rhythm_metronome/utils/global_function.dart';

/// 录音底部弹窗，负责录音控制、实时波形预览与历史录音播放。
class RecordingSheet extends StatelessWidget {
  /// 录音业务状态与操作入口。
  final RecordingStore store;

  /// 请求切换节拍器状态；当录音需要跟拍时在启动录音前触发。
  final Future<void> Function() onRequestToggleMetronome;

  /// 返回当前节拍器是否在运行。
  final bool Function() isMetronomeRunning;

  /// 是否以全屏模式展示列表区域。
  final bool isFullscreen;

  /// 切换全屏/半屏显示。
  final VoidCallback onToggleFullscreen;

  const RecordingSheet({
    super.key,
    required this.store,
    required this.onRequestToggleMetronome,
    required this.isMetronomeRunning,
    required this.isFullscreen,
    required this.onToggleFullscreen,
  });

  @override
  Widget build(BuildContext context) {
    final bool isDark = Theme.of(context).brightness == Brightness.dark;
    final AppTheme theme =
        AppThemes.all[appStore.themeIndex % AppThemes.all.length];
    final Color accent = theme.accent;
    final Color primary = theme.primary;
    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(16, 14, 16, 16),
        child: Observer(
          builder: (_) => Column(
            mainAxisSize: isFullscreen ? MainAxisSize.max : MainAxisSize.min,
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
                    onPressed: onToggleFullscreen,
                    icon: Icon(
                      isFullscreen
                          ? Icons.fullscreen_exit_rounded
                          : Icons.fullscreen_rounded,
                    ),
                  ),
                  IconButton(
                    onPressed: () async {
                      // 关闭面板前优先停止录音，避免后台残留录音任务。
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
                padding:
                    const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
                decoration: BoxDecoration(
                  color: isDark
                      ? const Color(0xFF1D2432).withValues(alpha: 0.95)
                      : Colors.white.withValues(alpha: 0.92),
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
                      color: accent.withValues(alpha: 0.45),
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
                    // 主按钮在「开始录音 / 停止录音」之间切换。
                    if (store.isRecording) {
                      final String? msg = await store.stopRecord();
                      if (msg != null) {
                        $warn(msg);
                      }
                      return;
                    }
                    // 开启“录音时播放节拍器”后，先确保节拍器处于运行态。
                    if (store.withMetronome && !isMetronomeRunning()) {
                      await onRequestToggleMetronome();
                    }
                    final String? msg = await store.startRecord();
                    if (msg != null) {
                      $warn(msg);
                    }
                  },
                  style: FilledButton.styleFrom(
                    backgroundColor:
                        store.isRecording ? Colors.redAccent : primary,
                    padding: const EdgeInsets.symmetric(vertical: 12),
                  ),
                  icon: Icon(
                    store.isRecording
                        ? Icons.stop_circle
                        : Icons.fiber_manual_record,
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
              if (isFullscreen)
                Expanded(
                  child: _buildClipList(store, accent),
                )
              else
                ConstrainedBox(
                  constraints: const BoxConstraints(maxHeight: 260),
                  child: _buildClipList(store, accent),
                ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildClipList(RecordingStore store, Color accent) {
    return ListView.separated(
      shrinkWrap: !isFullscreen,
      itemCount: store.clips.length,
      separatorBuilder: (_, __) => const SizedBox(height: 10),
      itemBuilder: (BuildContext context, int index) {
        final RecordingClip clip = store.clips[index];
        return Observer(
          builder: (_) {
            final bool isActive = store.activeClipId == clip.id;
            // 仅活动录音条目绑定全局播放进度，其余条目保持静态显示。
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
    );
  }
}

/// 单条录音项，包含播放控制、波形和进度拖动。
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
    final Color bg = isDark ? const Color(0xFF1A2230) : const Color(0xFFF7FAFF);
    return AnimatedContainer(
      duration: const Duration(milliseconds: 220),
      padding: const EdgeInsets.fromLTRB(12, 12, 10, 10),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: isActive
              ? accent.withValues(alpha: 0.45)
              : Theme.of(context).dividerColor.withValues(alpha: 0.25),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: isDark ? 0.22 : 0.06),
            blurRadius: 14,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              InkWell(
                borderRadius: BorderRadius.circular(24),
                onTap: () {
                  // 单按钮复用三态：播放中=暂停，暂停中=继续，其余=开始播放。
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
                child: Container(
                  width: 38,
                  height: 38,
                  decoration: BoxDecoration(
                    color: accent.withValues(alpha: 0.16),
                    shape: BoxShape.circle,
                  ),
                  child: Icon(
                    isPlaying ? Icons.pause_rounded : Icons.play_arrow_rounded,
                    color: accent,
                    size: 24,
                  ),
                ),
              ),
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.only(left: 10),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        _formatDateTime(clip.createdAt),
                        style: TextStyle(
                          fontSize: 12,
                          color: Theme.of(context).colorScheme.onSurfaceVariant,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        _formatDuration(clip.durationMs),
                        style: const TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              IconButton(
                visualDensity: VisualDensity.compact,
                onPressed: onDeleteTap,
                icon: const Icon(Icons.delete_outline),
              ),
            ],
          ),
          WaveformView(
            peaks: clip.waveformPeaks,
            live: false,
            progress: progress,
            color: accent.withValues(alpha: 0.32),
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
                    thumbShape:
                        const RoundSliderThumbShape(enabledThumbRadius: 6),
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
