import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:rhythm_metronome/config/app_theme.dart';
import 'package:rhythm_metronome/config/config.dart';
import 'package:rhythm_metronome/store/index.dart';
import 'package:rhythm_metronome/utils/global_function.dart';
import 'package:sleek_circular_slider/sleek_circular_slider.dart';

/// BPM 圆形滑块组件，支持拖拽与手动输入两种设置方式。
class SliderRow extends StatefulWidget {
  final int bpm;

  /// BPM 更新回调，调用方负责写入 store。
  final ValueChanged<int> setBpmHandler;

  const SliderRow(this.bpm, this.setBpmHandler, {super.key});

  @override
  State<SliderRow> createState() => _SliderRowState();
}

class _SliderRowState extends State<SliderRow> {
  late final TextEditingController _textController;

  @override
  void initState() {
    super.initState();
    _textController = TextEditingController();
  }

  @override
  void dispose() {
    _textController.dispose();
    super.dispose();
  }

  void _handleSliderChange(double value) {
    widget.setBpmHandler(value.toInt());
  }

  void _handleSetBpmConfirm(String text) {
    double? bpm;
    try {
      bpm = double.parse(text);
    } catch (e) {
      print('转换失败 $text ');
    }
    if (bpm != null) {
      if (bpm < Config.BPM_MIN || bpm > Config.BPM_MAX) {
        $warn('BPM 支持 ${Config.BPM_MIN} -  ${Config.BPM_MAX}');
        return;
      }
      _handleSliderChange(bpm);
    }
  }

  @override
  Widget build(BuildContext context) {
    final bool isDark = Theme.of(context).brightness == Brightness.dark;
    final AppTheme theme =
        AppThemes.all[appStore.themeIndex % AppThemes.all.length];
    final Color primary = theme.primary;
    final Color track = isDark ? theme.trackDark : theme.trackLight;
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceAround,
      children: [
        GestureDetector(
          onTap: () {
            _textController.text = widget.bpm.toString();
            $confirm(
              '',
              context,
              title: 'BPM',
              customBody: TextField(
                controller: _textController,
                keyboardType: TextInputType.number,
                // 仅允许输入数字和小数点，避免无效字符导致解析失败。
                inputFormatters: <TextInputFormatter>[
                  FilteringTextInputFormatter.allow(RegExp(r'^\d+\.?\d*')),
                ],
                decoration: InputDecoration(
                  hintText: widget.bpm.toString(),
                  filled: true,
                ),
                onSubmitted: (text) {
                  // 回车后先关闭弹窗，再走统一的范围校验逻辑。
                  Navigator.of(context).pop();
                  _handleSetBpmConfirm(text);
                },
              ),
              btnOkOnPress: () => _handleSetBpmConfirm(_textController.text),
            );
          },
          child: SleekCircularSlider(
            min: Config.BPM_MIN.toDouble(),
            max: Config.BPM_MAX.toDouble(),
            initialValue: widget.bpm.toDouble(),
            appearance: CircularSliderAppearance(
              size: 270,
              startAngle: 160,
              angleRange: 220,
              animDurationMultiplier: 0.8,
              customWidths: CustomSliderWidths(
                trackWidth: 10,
                progressBarWidth: 16,
                shadowWidth: 20,
                handlerSize: 8,
              ),
              infoProperties: InfoProperties(
                modifier: (percentage) => percentage.toInt().toString(),
                bottomLabelText: 'BPM',
                mainLabelStyle: TextStyle(
                  color: Theme.of(context).textTheme.headlineSmall?.color ??
                      Theme.of(context).colorScheme.onSurface,
                  fontSize: 54,
                  fontWeight: FontWeight.w700,
                  letterSpacing: 1.0,
                ),
                bottomLabelStyle: TextStyle(
                  color: Theme.of(context)
                      .colorScheme
                      .onSurface
                      .withValues(alpha: 0.6),
                  fontSize: 14,
                  letterSpacing: 1.2,
                  fontWeight: FontWeight.w600,
                ),
              ),
              customColors: CustomSliderColors(
                trackColor: track,
                progressBarColors: [
                  theme.barStart,
                  theme.barMid,
                  theme.barEnd,
                ],
                shadowColor: primary,
                shadowMaxOpacity: 0.22,
                dotColor: Colors.white,
                dynamicGradient: true,
              ),
            ),
            onChange: _handleSliderChange,
          ),
        ),
      ],
    );
  }
}
