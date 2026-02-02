import 'dart:async';
import 'package:audioplayers/audioplayers.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_mobx/flutter_mobx.dart';
import 'package:metronomelutter/component/change_sound.dart';
import 'package:metronomelutter/component/game_audio.dart';
import 'package:metronomelutter/config/config.dart';
import 'package:metronomelutter/store/index.dart';
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

class _MyHomePageState extends State<MyHomePage>
    with SingleTickerProviderStateMixin {
  int _nowStep = -1;
  int count = 0;
  bool _isRunning = false;
  Timer? _timer;
  late final AnimationController _animationController;
  late final Future<void> _audioInitFuture;
  bool _audioReady = false;

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
    _audioInitFuture = _initAudio();
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
    super.dispose();
    _animationController.dispose();
    _iosAudio.stop();
    _iosAudio.dispose();
    _player1.dispose();
    _player2.dispose();
    _player3.dispose();
    if (!kIsWeb) {
      WakelockPlus.disable();
    }
  }

  showBeatSetting() {
    showModalBottomSheet(
        backgroundColor: Theme.of(context).colorScheme.surface,
        context: context,
        builder: (BuildContext bc) {
          return Observer(
            builder: (_) => Container(
              // 2排 高度 + 分割线高度
              height: (63 * 2 + 16).toDouble(),

              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.center,
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
                    Divider(
                        // color: Color(0xffcccccc),
                        ),
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
    } else {
      await _audioInitFuture;
      if (!mounted) {
        return;
      }
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
    _timer = Timer(Duration(milliseconds: (60 / appStore.bpm * 1000).toInt()), () {
      count++;
      _playAudio().then((value) => _setNowStep());
      runTimer();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        body: Observer(
      builder: (_) => Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: <Widget>[
            // 顶部工具栏
            Container(
                padding:
                    EdgeInsets.only(top: MediaQuery.of(context).padding.top),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    IconButton(
                      icon: Icon(Icons.settings),
                      color: Theme.of(context).textTheme.headlineSmall?.color ??
                          Theme.of(context).colorScheme.onSurface,
                      onPressed: () async {
                        final result = await Navigator.push(
                          context,
                          MaterialPageRoute(builder: (context) => const Setting()),
                        );
                        print('setting result: $result');
                      },
                    )
                  ],
                )),
            // Text(
            //   '节拍器',
            //   style: Theme.of(context).textTheme.headline3,
            // ),

            SliderRow(appStore.bpm, _setBpmHanlder),

            // 小点
            IndactorRow(_nowStep, appStore.beat),

            // 底部控制区
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                IconButton(
                  icon: Icon(
                    Icons.music_note,
                  ),
                  onPressed: () async {
                    final res = await changeSound(context);
                    if (res != null) {
                      appStore.setSoundType(res);
                    }
                  },
                  color: Theme.of(context).colorScheme.secondary,
                ),

                // 开始/暂停
                IconButton(
                  icon: AnimatedIcon(
                    icon: AnimatedIcons.play_pause,
                    progress: _animationController,
                  ),
                  onPressed: _toggleIsRunning,
                  color: Theme.of(context).colorScheme.secondary,
                ),
                // 拍号
                GestureDetector(
                  onTap: showBeatSetting,
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(120),
                    child: Container(
                      color: Theme.of(context).colorScheme.secondary,
                      width: 50,
                      height: 50,
                      child: Center(
                        child: RichText(
                          textAlign: TextAlign.center,
                          maxLines: 1,
                          // overflow: TextOverflow.ellipsis,
                          textScaler: MediaQuery.textScalerOf(context),
                          text: TextSpan(
                            style: TextStyle(
                                color: Colors.white, fontSize: 16.0, height: 1),
                            children: [
                              TextSpan(text: appStore.beat.toString()),
                              TextSpan(text: '/'),
                              TextSpan(text: appStore.note.toString()),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),

            // 为了让底部留出空间
            SizedBox(
              height: 0,
            ),
            // TimeSignature(appStore.beat, appStore.note),
          ],
        ),
      ),
    ) // This trailing comma makes auto-formatting nicer for build methods.
        );
  }
}
