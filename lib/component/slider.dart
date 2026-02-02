import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:metronomelutter/config/config.dart';
import 'package:metronomelutter/utils/global_function.dart';
import 'package:sleek_circular_slider/sleek_circular_slider.dart';

class SliderRow extends StatefulWidget {
  final int bpm;
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
                // 如果你想只输入数字,需要加上这个
                inputFormatters: <TextInputFormatter>[
                  FilteringTextInputFormatter.allow(RegExp(r'^\d+\.?\d*')),
                ],
                decoration: InputDecoration(
                  hintText: widget.bpm.toString(),
                  filled: true,
                ),
                onSubmitted: (text) {
                  // todo 失败了不关闭弹窗
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
              // animationEnabled: false,
              size: 270,
              infoProperties: InfoProperties(
                modifier: (percentage) => percentage.toInt().toString(),
                bottomLabelText: 'BPM',
                mainLabelStyle: TextStyle(
                  color: Theme.of(context).textTheme.headlineSmall?.color ??
                      Theme.of(context).colorScheme.onSurface,
                  fontSize: 52,
                ),
              ),
              customColors: CustomSliderColors(
                hideShadow: true,
                progressBarColors: const [
                  Color.fromARGB(255, 62, 164, 255),
                  Color.fromARGB(255, 102, 204, 255),
                  Color.fromARGB(255, 142, 244, 255),
                ],
              ),
            ),
            // onChangeStart: (double value) {},
            // onChangeEnd: (double value) {},
            // onChange: (double value) {},
            onChange: _handleSliderChange,
            // onChangeStart: _handleSliderChange,
            // onChangeEnd: _handleSliderChange,
          ),
        ),
      ],
    );
  }
}
