import 'package:flutter/material.dart';
import 'package:rhythm_metronome/config/app_theme.dart';
import 'package:rhythm_metronome/store/index.dart';

/// 节拍指示器行，根据拍号长度渲染当前激活拍。
class IndactorRow extends StatelessWidget {
  /// 当前拍索引（从 0 开始）。
  final int nowStep;

  /// 总拍数（例如 4/4 的上拍为 4）。
  final int stepLength;

  const IndactorRow(this.nowStep, this.stepLength, {super.key});

  @override
  Widget build(BuildContext context) {
    final bool isDark = Theme.of(context).brightness == Brightness.dark;
    final AppTheme theme =
        AppThemes.all[appStore.themeIndex % AppThemes.all.length];
    final Color activeColor = theme.indicatorActive;
    final Color inactiveColor =
        isDark ? theme.indicatorInactiveDark : theme.indicatorInactiveLight;
    final List<int> steps = List<int>.generate(stepLength, (index) => index);
    // 拍数较少时改用 Row，避免 Grid 在宽屏下留白过大。
    if (stepLength < 4) {
      return Container(
        height: 100,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: steps.asMap().entries.map((entry) {
            final bool isActive =
                nowStep > -1 && (nowStep % steps.length) == entry.key;
            return AnimatedContainer(
              duration: const Duration(milliseconds: 160),
              curve: Curves.easeOutCubic,
              margin: const EdgeInsets.symmetric(horizontal: 10),
              width: 36.0,
              height: 36.0,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(12),
                color: isActive ? activeColor : inactiveColor,
                boxShadow: isActive
                    ? [
                        BoxShadow(
                          color: activeColor.withValues(alpha: 0.35),
                          blurRadius: 12,
                          offset: const Offset(0, 6),
                        ),
                      ]
                    : null,
              ),
              child: AnimatedScale(
                duration: const Duration(milliseconds: 120),
                scale: isActive ? 1.05 : 0.95,
                child: const SizedBox.shrink(),
              ),
            );
          }).toList(),
        ),
      );
    }
    return Container(
      height: 100,
      alignment: Alignment.center,
      child: GridView.builder(
        itemCount: steps.length,
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: steps.length > 4 ? steps.length : 4,
          mainAxisSpacing: 0.0,
          childAspectRatio: 1.0,
        ),
        padding: const EdgeInsets.symmetric(vertical: 0),
        itemBuilder: (BuildContext context, int index) {
          final bool isActive =
              nowStep > -1 && (nowStep % steps.length) == index;
          return Center(
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 160),
              curve: Curves.easeOutCubic,
              width: 36.0,
              height: 36.0,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(12),
                color: isActive ? activeColor : inactiveColor,
                boxShadow: isActive
                    ? [
                        BoxShadow(
                          color: activeColor.withValues(alpha: 0.35),
                          blurRadius: 12,
                          offset: const Offset(0, 6),
                        ),
                      ]
                    : null,
              ),
              child: AnimatedScale(
                duration: const Duration(milliseconds: 120),
                scale: isActive ? 1.05 : 0.95,
                child: const SizedBox.shrink(),
              ),
            ),
          );
        },
      ),
    );
  }
}
