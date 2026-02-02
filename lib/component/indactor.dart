import 'package:flutter/material.dart';
import 'package:metronomelutter/config/app_theme.dart';
import 'package:metronomelutter/store/index.dart';

class IndactorRow extends StatelessWidget {
  final int nowStep;
  final int stepLength;

  const IndactorRow(this.nowStep, this.stepLength, {super.key});

  @override
  Widget build(BuildContext context) {
    final ColorScheme scheme = Theme.of(context).colorScheme;
    final bool isDark = Theme.of(context).brightness == Brightness.dark;
    final AppTheme theme =
        AppThemes.all[appStore.themeIndex % AppThemes.all.length];
    final Color primary = theme.primary;
    final Color accent = theme.accent;
    final List<int> steps = List<int>.generate(stepLength, (index) => index);
    // 不满 4 个改用 Row 渲染
    if (stepLength < 4) {
      return Container(
        height: 100,
        child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: steps
                .asMap()
                .entries
                .map((entry) {
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
                      gradient: isActive
                          ? LinearGradient(
                              colors: [
                                primary,
                                accent,
                              ],
                              begin: Alignment.topLeft,
                              end: Alignment.bottomRight,
                            )
                          : null,
                      color: isActive
                          ? null
                          : (isDark
                              ? scheme.onSurface.withOpacity(0.16)
                              : scheme.onSurface.withOpacity(0.12)),
                      boxShadow: isActive
                          ? [
                              BoxShadow(
                                color: primary.withOpacity(0.35),
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
                })
                .toList()),
      );
    }
    return Container(
      height: 100,
      // color: Colors.blueGrey,
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
          final bool isActive = nowStep > -1 && (nowStep % steps.length) == index;
          return Center(
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 160),
              curve: Curves.easeOutCubic,
              width: 36.0,
              height: 36.0,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(12),
                gradient: isActive
                    ? LinearGradient(
                        colors: [
                          primary,
                          accent,
                        ],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      )
                    : null,
                color: isActive
                    ? null
                    : (isDark
                        ? scheme.onSurface.withOpacity(0.16)
                        : scheme.onSurface.withOpacity(0.12)),
                boxShadow: isActive
                    ? [
                        BoxShadow(
                          color: primary.withOpacity(0.35),
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
