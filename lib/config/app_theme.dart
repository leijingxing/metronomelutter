import 'package:flutter/material.dart';

class AppTheme {
  final String name;
  final Color primary;
  final Color accent;
  final Color indicatorActive;
  final Color indicatorInactiveLight;
  final Color indicatorInactiveDark;
  final Color bgTopLight;
  final Color bgBottomLight;
  final Color bgTopDark;
  final Color bgBottomDark;
  final Color trackLight;
  final Color trackDark;
  final Color barStart;
  final Color barMid;
  final Color barEnd;

  const AppTheme({
    required this.name,
    required this.primary,
    required this.accent,
    required this.indicatorActive,
    required this.indicatorInactiveLight,
    required this.indicatorInactiveDark,
    required this.bgTopLight,
    required this.bgBottomLight,
    required this.bgTopDark,
    required this.bgBottomDark,
    required this.trackLight,
    required this.trackDark,
    required this.barStart,
    required this.barMid,
    required this.barEnd,
  });
}

class AppThemes {
  static const List<AppTheme> all = [
    AppTheme(
      name: '清晨蓝',
      primary: Color(0xFF2F6BFF),
      accent: Color(0xFFFF8A5C),
      indicatorActive: Color(0xFF2F6BFF),
      indicatorInactiveLight: Color(0xFFCBD7FF),
      indicatorInactiveDark: Color(0xFF2E3854),
      bgTopLight: Color(0xFFF6F3EF),
      bgBottomLight: Color(0xFFFDFBF8),
      bgTopDark: Color(0xFF0E1117),
      bgBottomDark: Color(0xFF151A22),
      trackLight: Color(0xFFE7E2DA),
      trackDark: Color(0xFF2A3142),
      barStart: Color(0xFF2F6BFF),
      barMid: Color(0xFF6FA8FF),
      barEnd: Color(0xFFFF8A5C),
    ),
    AppTheme(
      name: '薄荷绿',
      primary: Color(0xFF1FBF89),
      accent: Color(0xFFFFB25B),
      indicatorActive: Color(0xFF1FBF89),
      indicatorInactiveLight: Color(0xFFCFEFE3),
      indicatorInactiveDark: Color(0xFF2A3A36),
      bgTopLight: Color(0xFFF3F8F6),
      bgBottomLight: Color(0xFFFEFEFD),
      bgTopDark: Color(0xFF0E1414),
      bgBottomDark: Color(0xFF161F1E),
      trackLight: Color(0xFFE4EEE9),
      trackDark: Color(0xFF27302F),
      barStart: Color(0xFF1FBF89),
      barMid: Color(0xFF5FD7AE),
      barEnd: Color(0xFFFFB25B),
    ),
    AppTheme(
      name: '日落紫橙',
      primary: Color(0xFF6B4EFF),
      accent: Color(0xFFFF7A45),
      indicatorActive: Color(0xFF6B4EFF),
      indicatorInactiveLight: Color(0xFFD6CCFF),
      indicatorInactiveDark: Color(0xFF342F4A),
      bgTopLight: Color(0xFFF8F4FA),
      bgBottomLight: Color(0xFFFEF7F1),
      bgTopDark: Color(0xFF111018),
      bgBottomDark: Color(0xFF1B1824),
      trackLight: Color(0xFFECE2F2),
      trackDark: Color(0xFF2B2537),
      barStart: Color(0xFF6B4EFF),
      barMid: Color(0xFFA18BFF),
      barEnd: Color(0xFFFF7A45),
    ),
  ];
}
