import 'dart:async';
import 'dart:io';
import 'dart:math';
import 'package:audioplayers/audioplayers.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_mobx/flutter_mobx.dart';
import 'package:rhythm_metronome/component/change_sound.dart';
import 'package:rhythm_metronome/component/game_audio.dart';
import 'package:rhythm_metronome/component/home_visuals.dart';
import 'package:rhythm_metronome/component/recording_sheet.dart';
import 'package:rhythm_metronome/component/score_overlay_card.dart';
import 'package:rhythm_metronome/component/score_sheet_manage_sheet.dart';
import 'package:rhythm_metronome/config/app_theme.dart';
import 'package:rhythm_metronome/config/config.dart';
import 'package:rhythm_metronome/model/score_sheet.dart';
import 'package:rhythm_metronome/store/index.dart';
import 'package:rhythm_metronome/utils/global_function.dart';
import 'package:rhythm_metronome/utils/score_sheet_service.dart';
import 'package:quick_actions/quick_actions.dart';
import 'package:wakelock_plus/wakelock_plus.dart';

import './setting.dart';
import '../component/indactor.dart';
import '../component/slider.dart';
import '../component/stepper.dart';

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key});

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> with TickerProviderStateMixin {
  int _nowStep = -1;
  int count = 0;
  bool _isRunning = false;
  Timer? _timer;
  late final AnimationController _animationController;
  late final AnimationController _cloudController;
  late final AnimationController _burstController;
  late final Future<void> _audioInitFuture;
  bool _audioReady = false;
  final List<CloudBurst> _bursts = [];
  final Random _random = Random();
  final ScoreSheetService _scoreSheetService = ScoreSheetService();
  final TransformationController _scoreTransformController =
      TransformationController();
  List<ScoreSheet> _scoreSheets = <ScoreSheet>[];
  String? _selectedScoreSheetId;

  // ios 用,防止内存泄漏 todo iOS 也要三个播放器
  final GameAudio _iosAudio = GameAudio(1);

  // Android 用
  // 用一个播放器会导致高 BPM 的时候节奏不均匀, 因为音频是有时长的, 上一个音频还没有播放完毕就开始播放下一个, 就会导致这种节奏不均匀的问题
  // 两个用于播放 soundType2,另外一个用于 soundType1
  late final AudioPlayer _player1;
  late final AudioPlayer _player2;
  late final AudioPlayer _player3;

  String shortcut = 'no action set';

  @override
  void initState() {
    super.initState();
    if (!kIsWeb) {
      // 设定桌面图标长按 BEGIN
      const QuickActions quickActions = QuickActions();
      quickActions.initialize((String shortcutType) {
        setState(() {
          shortcut = shortcutType;
          _toggleIsRunning();
        });
      });
      quickActions.setShortcutItems(<ShortcutItem>[
        // NOTE: This first action icon will only work on iOS.
        // In a real world project keep the same file name for both platforms.
        const ShortcutItem(
          type: 'start',
          localizedTitle: '开始',
          icon: 'play',
        ),
        // NOTE: This second action icon will only work on Android.
        // In a real world project keep the same file name for both platforms.
        // const ShortcutItem(type: 'action_two', localizedTitle: '播放 Action two', icon: 'ic_launcher'),
      ]);
      // 设定桌面图标长按 END

      WakelockPlus.enable();
    }

    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 300),
    );
    _cloudController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 16),
    )..repeat(reverse: true);
    _burstController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 2),
    )..addListener(_onBurstTick);
    _audioInitFuture = _initAudio();
    recordingStore.init();
    unawaited(_initScoreSheets());
    if (!kIsWeb) {
      WakelockPlus.toggle(enable: appStore.keepScreenOn);
    }
    // Timer(Duration(milliseconds: 1000), () {
    //   showBeatSetting();
    // });
  }

  Future<void> _initAudio() async {
    await _initPlayers();
    await _iosAudio.init();
    _audioReady = true;
  }

  Future<void> _initPlayers() async {
    _player1 = AudioPlayer();
    _player2 = AudioPlayer();
    _player3 = AudioPlayer();
    await Future.wait([
      _player1.setPlayerMode(PlayerMode.lowLatency),
      _player2.setPlayerMode(PlayerMode.lowLatency),
      _player3.setPlayerMode(PlayerMode.lowLatency),
      _player1.setReleaseMode(ReleaseMode.stop),
      _player2.setReleaseMode(ReleaseMode.stop),
      _player3.setReleaseMode(ReleaseMode.stop),
    ]);
  }

  @override
  void dispose() {
    _timer?.cancel();
    _animationController.dispose();
    _cloudController.dispose();
    _burstController.dispose();
    _scoreTransformController.dispose();
    _iosAudio.stop();
    _iosAudio.dispose();
    _player1.dispose();
    _player2.dispose();
    _player3.dispose();
    unawaited(recordingStore.dispose());
    if (!kIsWeb) {
      WakelockPlus.disable();
    }
    super.dispose();
  }

  showBeatSetting() {
    showModalBottomSheet(
        backgroundColor: Theme.of(context).colorScheme.surface,
        context: context,
        builder: (BuildContext bc) {
          return Observer(
            builder: (_) => SafeArea(
              child: Padding(
                padding:
                    const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    SyStepper(
                      value: appStore.beat,
                      step: 1,
                      iconSize: 24,
                      textSize: 36,
                      min: Config.BEAT_MIN,
                      max: Config.BEAT_MAX,
                      onChange: (b) {
                        appStore.setBeat(b);
                      },
                    ),
                    const SizedBox(height: 14),
                    Divider(
                      height: 1,
                      thickness: 1,
                    ),
                    const SizedBox(height: 14),
                    SyStepper(
                      value: appStore.note,
                      step: 1,
                      iconSize: 24,
                      textSize: 36,
                      min: Config.NOTE_MIN,
                      max: Config.NOTE_MAX,
                      manualControl: (type, nowValue) {
                        if (type == StepperEventType.increase) {
                          appStore.noteIncrease();
                        } else {
                          appStore.noteDecrease();
                        }
                      },
                      // 无用,为了能正常显示 不可用状态
                      onChange: (i) {},
                    ),
                  ],
                ),
              ),
            ),
          );
        });
  }

  void _setBpmHanlder(int val) {
    appStore.setBpm(val);
  }

  Future<void> _toggleIsRunning() async {
    if (_isRunning) {
      _timer?.cancel();
      _animationController.reverse();
      _stopAllAudio();
      _burstController.stop();
      _bursts.clear();
    } else {
      await _audioInitFuture;
      if (!mounted) {
        return;
      }
      _burstController.repeat();
      runTimer();
      _animationController.forward();
    }
    setState(() {
      _isRunning = !_isRunning;
    });
  }

  void _setNowStep() {
    setState(() {
      _nowStep++;
    });
    if (_isRunning) {
      _spawnCloudBurst();
    }
  }

  void _stopAllAudio() {
    if (_isIOS) {
      _iosAudio.stop();
    } else {
      _player1.stop();
      _player2.stop();
      _player3.stop();
    }
  }

  Future<void> _playAudio() async {
    if (!_audioReady) {
      return;
    }
    final int nextStep = _nowStep + 1;
    final int soundType = appStore.soundType;
    if (nextStep % appStore.beat == 0) {
      if (_isIOS) {
        return _iosAudio.play('metronome$soundType-1.wav');
      } else {
        await _player1.stop();
        await _player1.play(
          AssetSource('metronome$soundType-1.wav'),
          mode: PlayerMode.lowLatency,
        );
        return;
      }
    } else {
      if (_isIOS) {
        return _iosAudio.play('metronome$soundType-2.wav');
      } else {
        // 交替使用播放器
        if (count % 2 == 0) {
          await _player2.stop();
          await _player2.play(
            AssetSource('metronome$soundType-2.wav'),
            mode: PlayerMode.lowLatency,
          );
          return;
        } else {
          await _player3.stop();
          await _player3.play(
            AssetSource('metronome$soundType-2.wav'),
            mode: PlayerMode.lowLatency,
          );
          return;
        }
      }
    }
  }

  bool get _isIOS => !kIsWeb && defaultTargetPlatform == TargetPlatform.iOS;

  void runTimer() {
    _timer =
        Timer(Duration(milliseconds: (60 / appStore.bpm * 1000).toInt()), () {
      count++;
      _playAudio().then((value) => _setNowStep());
      runTimer();
    });
  }

  void _spawnCloudBurst() {
    final int now = DateTime.now().millisecondsSinceEpoch;
    final double x = 0.15 + _random.nextDouble() * 0.7;
    final double y = 0.18 + _random.nextDouble() * 0.5;
    final double radius = 60 + _random.nextDouble() * 80;
    final double driftX = (_random.nextDouble() - 0.5) * 30;
    final double driftY = (_random.nextDouble() - 0.5) * 20;
    final AppTheme theme =
        AppThemes.all[appStore.themeIndex % AppThemes.all.length];
    final Color color =
        Color.lerp(theme.primary, theme.accent, _random.nextDouble()) ??
            theme.primary;
    _bursts.add(CloudBurst(
      center: Offset(x, y),
      radius: radius,
      startMs: now,
      durationMs: 900 + _random.nextInt(400),
      driftX: driftX,
      driftY: driftY,
      color: color,
    ));
  }

  void _onBurstTick() {
    if (!mounted) {
      return;
    }
    final int now = DateTime.now().millisecondsSinceEpoch;
    _bursts.removeWhere((b) => now - b.startMs > b.durationMs);
    if (_bursts.isNotEmpty) {
      setState(() {});
    }
  }

  Future<void> _openRecordingSheet() async {
    recordingStore.openSheet();
    final String? result = await showModalBottomSheet<String>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Theme.of(context).colorScheme.surface,
      builder: (BuildContext context) {
        return RecordingSheet(
          store: recordingStore,
          onRequestToggleMetronome: _toggleIsRunning,
          isMetronomeRunning: () => _isRunning,
          isFullscreen: false,
          onToggleFullscreen: () {
            Navigator.pop(context, 'fullscreen');
          },
        );
      },
    );
    recordingStore.closeSheet();
    if (!mounted) {
      return;
    }
    if (result == 'fullscreen') {
      await _openRecordingFullscreen();
    }
  }

  Future<void> _openRecordingFullscreen() async {
    final String? result = await Navigator.push<String>(
      context,
      MaterialPageRoute<String>(
        fullscreenDialog: true,
        builder: (BuildContext context) {
          return Scaffold(
            backgroundColor: Theme.of(context).colorScheme.surface,
            body: RecordingSheet(
              store: recordingStore,
              onRequestToggleMetronome: _toggleIsRunning,
              isMetronomeRunning: () => _isRunning,
              isFullscreen: true,
              onToggleFullscreen: () {
                Navigator.pop(context, 'sheet');
              },
            ),
          );
        },
      ),
    );
    if (!mounted) {
      return;
    }
    if (result == 'sheet') {
      await _openRecordingSheet();
    }
  }

  ScoreSheet? get _selectedScoreSheet {
    final String? selectedId = _selectedScoreSheetId;
    if (selectedId == null || selectedId.isEmpty) {
      return null;
    }
    for (final ScoreSheet sheet in _scoreSheets) {
      if (sheet.id == selectedId) {
        return sheet;
      }
    }
    return null;
  }

  Future<void> _initScoreSheets() async {
    final List<ScoreSheet> loaded = await _scoreSheetService.loadSheets();
    final List<ScoreSheet> valid = <ScoreSheet>[];
    bool changed = false;
    for (final ScoreSheet sheet in loaded) {
      final bool existsAll = kIsWeb
          ? sheet.imagePaths.isNotEmpty
          : (sheet.imagePaths.isNotEmpty &&
              await Future.wait(
                sheet.imagePaths.map((String path) => File(path).exists()),
              ).then((List<bool> values) => values.every((bool e) => e)));
      if (!existsAll) {
        changed = true;
        continue;
      }
      valid.add(sheet);
    }
    if (changed) {
      await _scoreSheetService.saveSheets(valid);
    }
    final String? savedSelectedId = _scoreSheetService.loadSelectedId();
    String? resolvedSelectedId = savedSelectedId;
    if (savedSelectedId != null &&
        !valid.any((ScoreSheet e) => e.id == savedSelectedId)) {
      resolvedSelectedId = null;
      await _scoreSheetService.saveSelectedId(null);
    }
    if (!mounted) {
      return;
    }
    setState(() {
      _scoreSheets = valid;
      _selectedScoreSheetId = resolvedSelectedId;
      _scoreTransformController.value = Matrix4.identity();
    });
  }

  Future<void> _openScoreSheetDialog() async {
    if (kIsWeb) {
      $warn('Web 暂不支持谱子图片导入');
      return;
    }
    await showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Theme.of(context).colorScheme.surface,
      builder: (BuildContext context) {
        return ScoreSheetManageSheet(
          service: _scoreSheetService,
          selectedId: _selectedScoreSheetId,
          onSelectionChanged: (String? selectedId) {
            _selectedScoreSheetId = selectedId;
          },
        );
      },
    );
    await _initScoreSheets();
  }

  Future<void> _clearSelectedScoreSheet() async {
    await _scoreSheetService.saveSelectedId(null);
    if (!mounted) {
      return;
    }
    setState(() {
      _selectedScoreSheetId = null;
      _scoreTransformController.value = Matrix4.identity();
    });
  }

  @override
  Widget build(BuildContext context) {
    final ColorScheme scheme = Theme.of(context).colorScheme;
    final TextTheme textTheme = Theme.of(context).textTheme;
    final bool isDark = Theme.of(context).brightness == Brightness.dark;
    final AppTheme theme =
        AppThemes.all[appStore.themeIndex % AppThemes.all.length];
    final Color primary = theme.primary;
    final Color accent = theme.accent;
    final Color bgTop = isDark ? theme.bgTopDark : theme.bgTopLight;
    final Color bgBottom = isDark ? theme.bgBottomDark : theme.bgBottomLight;

    return Scaffold(
      body: Observer(
        builder: (_) => Stack(
          children: [
            // 背景层
            AnimatedBuilder(
              animation: _cloudController,
              builder: (context, child) {
                final double t = _cloudController.value;
                final Alignment begin = Alignment.lerp(
                      Alignment.topLeft,
                      Alignment.topRight,
                      t,
                    ) ??
                    Alignment.topLeft;
                final Alignment end = Alignment.lerp(
                      Alignment.bottomRight,
                      Alignment.bottomLeft,
                      t,
                    ) ??
                    Alignment.bottomRight;
                return Container(
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: begin,
                      end: end,
                      colors: [
                        Color.lerp(bgTop, primary.withValues(alpha: 0.06), t) ??
                            bgTop,
                        Color.lerp(
                                bgBottom, accent.withValues(alpha: 0.06), t) ??
                            bgBottom,
                      ],
                    ),
                  ),
                );
              },
            ),
            // 节拍云彩散开效果
            Positioned.fill(
              child: IgnorePointer(
                child: AnimatedBuilder(
                  animation: _burstController,
                  builder: (context, child) {
                    return CustomPaint(
                      painter: CloudBurstPainter(
                        bursts: _bursts,
                        nowMs: DateTime.now().millisecondsSinceEpoch,
                      ),
                    );
                  },
                ),
              ),
            ),
            // 背景点缀
            AnimatedPositioned(
              duration: const Duration(milliseconds: 700),
              curve: Curves.easeOutCubic,
              top: _isRunning ? -60 : -90,
              right: _isRunning ? -10 : -50,
              child: GlowOrb(color: primary.withValues(alpha: 0.22), size: 200),
            ),
            AnimatedPositioned(
              duration: const Duration(milliseconds: 700),
              curve: Curves.easeOutCubic,
              bottom: _isRunning ? -70 : -120,
              left: _isRunning ? -30 : -70,
              child: GlowOrb(color: accent.withValues(alpha: 0.22), size: 240),
            ),
            SafeArea(
              child: Column(
                children: [
                  Padding(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                    child: Row(
                      children: [
                        Expanded(
                          child: Text(
                            '律动节拍',
                            style: textTheme.headlineSmall?.copyWith(
                              fontWeight: FontWeight.w700,
                              letterSpacing: 1.2,
                            ),
                          ),
                        ),
                        IconButton(
                          icon: const Icon(Icons.library_music_outlined),
                          color: textTheme.headlineSmall?.color ??
                              scheme.onSurface,
                          tooltip: '谱子',
                          onPressed: _openScoreSheetDialog,
                        ),
                        IconButton(
                          icon: const Icon(Icons.settings),
                          color: textTheme.headlineSmall?.color ??
                              scheme.onSurface,
                          onPressed: () async {
                            final result = await Navigator.push(
                              context,
                              MaterialPageRoute(
                                  builder: (context) => const Setting()),
                            );
                            print('setting result: $result');
                          },
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 6),
                  AnimatedOpacity(
                    opacity: _isRunning ? 1 : 0.9,
                    duration: const Duration(milliseconds: 350),
                    curve: Curves.easeOut,
                    child: SliderRow(appStore.bpm, _setBpmHanlder),
                  ),
                  const SizedBox(height: 12),
                  IndactorRow(_nowStep, appStore.beat),
                  const Spacer(),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 18),
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 10, vertical: 14),
                      decoration: BoxDecoration(
                        color: isDark
                            ? const Color(0xFF1B2230).withValues(alpha: 0.92)
                            : Colors.white.withValues(alpha: 0.9),
                        borderRadius: BorderRadius.circular(20),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black
                                .withValues(alpha: isDark ? 0.25 : 0.08),
                            blurRadius: 22,
                            offset: const Offset(0, 12),
                          ),
                        ],
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceAround,
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          RoundIconButton(
                            icon: Icons.music_note,
                            color: accent,
                            onPressed: () async {
                              final res = await changeSound(context);
                              if (res != null) {
                                appStore.setSoundType(res);
                              }
                            },
                          ),
                          RoundIconButton(
                            icon: Icons.mic,
                            color: isDark
                                ? scheme.secondaryContainer
                                : scheme.secondary,
                            onPressed: _openRecordingSheet,
                          ),
                          // 开始/暂停
                          AnimatedBuilder(
                            animation: _animationController,
                            builder: (context, child) {
                              final scale =
                                  1.0 + (_animationController.value * 0.06);
                              return Transform.scale(
                                scale: scale,
                                child: child,
                              );
                            },
                            child: RoundIconButton(
                              icon: null,
                              color: primary,
                              onPressed: _toggleIsRunning,
                              child: AnimatedIcon(
                                icon: AnimatedIcons.play_pause,
                                progress: _animationController,
                                color: Colors.white,
                                size: 28,
                              ),
                            ),
                          ),
                          // 拍号
                          GestureDetector(
                            onTap: showBeatSetting,
                            child: Container(
                              width: 56,
                              height: 56,
                              decoration: BoxDecoration(
                                color: accent,
                                borderRadius: BorderRadius.circular(16),
                                boxShadow: [
                                  BoxShadow(
                                    color: accent.withValues(alpha: 0.35),
                                    blurRadius: 16,
                                    offset: const Offset(0, 7),
                                  ),
                                ],
                              ),
                              child: Center(
                                child: RichText(
                                  textAlign: TextAlign.center,
                                  maxLines: 1,
                                  textScaler: MediaQuery.textScalerOf(context),
                                  text: TextSpan(
                                    style: const TextStyle(
                                      color: Colors.white,
                                      fontSize: 16.0,
                                      height: 1,
                                      fontWeight: FontWeight.w600,
                                    ),
                                    children: [
                                      TextSpan(text: appStore.beat.toString()),
                                      const TextSpan(text: '/'),
                                      TextSpan(text: appStore.note.toString()),
                                    ],
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),
                ],
              ),
            ),
            if (_selectedScoreSheet != null)
              Positioned.fill(
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(16, 72, 16, 108),
                  child: ScoreOverlayCard(
                    sheet: _selectedScoreSheet!,
                    transformController: _scoreTransformController,
                    onClose: _clearSelectedScoreSheet,
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}
