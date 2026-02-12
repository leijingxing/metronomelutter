import 'package:flutter/material.dart';
import 'package:rhythm_metronome/config/app_theme.dart';
import 'package:rhythm_metronome/store/index.dart';

/// 步进器按钮事件类型。
enum StepperEventType { increase, decrease }

/// 步进值变化回调。
typedef StepperChangeCallback(int val);

/// 通用数值步进器，支持最小/最大边界与自定义步幅。
class SyStepper extends StatelessWidget {
  final int value;
  final int min;
  final int max;

  /// 每次增减的步幅。
  final int step;
  final double iconSize;
  final double textSize;
  final StepperChangeCallback? onChange;

  /// 手动控制回调；设置后由外部决定如何处理加减逻辑。
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
    final ColorScheme scheme = theme.colorScheme;
    final bool isDark = theme.brightness == Brightness.dark;
    final AppTheme appTheme =
        AppThemes.all[appStore.themeIndex % AppThemes.all.length];
    final StepperChangeCallback? onChange = this.onChange;
    final void Function(StepperEventType type, int nowValue)? manualControl =
        this.manualControl;
    final bool minusBtnDisabled =
        value <= this.min || value - this.step < this.min || onChange == null;
    final bool addBtnDisabled =
        value >= this.max || value + this.step > this.max || onChange == null;
    final Color minusColor = appTheme.accent;
    final Color plusColor = appTheme.primary;
    final Color cardColor = isDark ? const Color(0xFF1B2230) : Colors.white;
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: <Widget>[
        _StepperButton(
          icon: Icons.remove,
          color: minusColor,
          disabled: minusBtnDisabled,
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
                      final int newVal = value - this.step;
                      onChange(newVal);
                    },
        ),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 10),
          decoration: BoxDecoration(
            color: cardColor,
            borderRadius: BorderRadius.circular(14),
            border:
                Border.all(color: scheme.outlineVariant.withValues(alpha: 0.4)),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: isDark ? 0.2 : 0.08),
                blurRadius: 10,
                offset: const Offset(0, 6),
              ),
            ],
          ),
          child: AnimatedDefaultTextStyle(
            duration: const Duration(milliseconds: 150),
            style: theme.textTheme.titleLarge?.copyWith(
                  fontSize: textSize,
                  fontWeight: FontWeight.w700,
                  letterSpacing: 1.0,
                ) ??
                TextStyle(
                  fontSize: textSize,
                  fontWeight: FontWeight.w700,
                ),
            child: Text(value.toString()),
          ),
        ),
        _StepperButton(
          icon: Icons.add,
          color: plusColor,
          disabled: addBtnDisabled,
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
                      final int newVal = value + this.step;
                      onChange(newVal);
                    },
        ),
      ],
    );
  }
}

/// 步进器圆形按钮。
class _StepperButton extends StatelessWidget {
  final IconData icon;
  final Color color;
  final bool disabled;
  final VoidCallback? onTap;

  const _StepperButton({
    required this.icon,
    required this.color,
    required this.disabled,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final ColorScheme scheme = Theme.of(context).colorScheme;
    final Color bg = disabled ? scheme.surfaceContainerHighest : color;
    final Color fg =
        disabled ? scheme.onSurface.withValues(alpha: 0.4) : Colors.white;
    return Material(
      color: bg,
      shape: const CircleBorder(),
      elevation: disabled ? 0 : 6,
      shadowColor: color.withValues(alpha: 0.35),
      child: InkWell(
        customBorder: const CircleBorder(),
        onTap: onTap,
        child: SizedBox(
          width: 46,
          height: 46,
          child: Icon(
            icon,
            size: 22,
            color: fg,
          ),
        ),
      ),
    );
  }
}
