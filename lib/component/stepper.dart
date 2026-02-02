import 'package:flutter/material.dart';

enum StepperEventType { increase, decrease }

typedef StepperChangeCallback(int val);

// - 3 +
class SyStepper extends StatelessWidget {
  final int value;
  final int min;
  final int max;

  /// 步幅
  final int step;
  final double iconSize;
  final double textSize;
  final StepperChangeCallback? onChange;
  final void Function(StepperEventType type, int nowValue)? manualControl;

  const SyStepper({
    super.key,
    this.value = 1,
    this.onChange,
    this.min = 1,
    this.max = 9999999,
    this.step = 1,
    this.iconSize = 24.0,
    this.textSize = 24.0,
    this.manualControl,
  });

  @override
  Widget build(BuildContext context) {
    final int value = this.value;
    final ThemeData theme = Theme.of(context);
    final StepperChangeCallback? onChange = this.onChange;
    final void Function(StepperEventType type, int nowValue)? manualControl =
        this.manualControl;
    final iconPadding = const EdgeInsets.all(4.0);
    final bool minusBtnDisabled = value <= this.min || value - this.step < this.min || onChange == null;
    final bool addBtnDisabled = value >= this.max || value + this.step > this.max || onChange == null;
    final Color activeColor =
        theme.textTheme.labelLarge?.color ?? theme.colorScheme.onSurface;
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: <Widget>[
        InkWell(
          child: Padding(
            padding: iconPadding,
            child: Icon(
              Icons.remove,
              size: this.iconSize,
              color: minusBtnDisabled ? theme.disabledColor : activeColor,
            ),
          ),
          onTap: minusBtnDisabled
              ? null
              : manualControl != null
                  ? () {
                      manualControl(
                        StepperEventType.decrease,
                        value,
                      );
                    }
                  : () {
                      int newVal = value - this.step;

                      onChange?.call(newVal);
                    },
        ),
        Padding(
          padding: EdgeInsets.symmetric(horizontal: 4.0),
          child: ConstrainedBox(
            child: Center(
                child: Text(
              value.toString(),
              style: TextStyle(
                fontSize: this.textSize,
                // color: Color.fromRGBO(84, 84, 84, 1),
              ),
            )),
            constraints: BoxConstraints(minWidth: this.iconSize),
          ),
        ),
        InkWell(
          child: Padding(
            padding: iconPadding,
            child: Icon(
              Icons.add,
              size: this.iconSize,
              color: addBtnDisabled ? theme.disabledColor : activeColor,
            ),
          ),
          onTap: addBtnDisabled
              ? null
              : manualControl != null
                  ? () {
                      manualControl(
                        StepperEventType.increase,
                        value,
                      );
                    }
                  : () {
                      int newVal = value + this.step;

                      onChange?.call(newVal);
                    },
        ),
      ],
    );
  }
}
