import 'package:flutter/material.dart';

class AppTheme {
  final String name;
  final Color primary;
  final Color accent;
  final Color bgTopLight;
  final Color bgBottomLight;
  final Color bgTopDark;
  final Color bgBottomDark;
  final Color trackLight;
  final Color trackDark;

  const AppTheme({
    required this.name,
    required this.primary,
    required this.accent,
    required this.bgTopLight,
    required this.bgBottomLight,
    required this.bgTopDark,
    required this.bgBottomDark,
    required this.trackLight,
    required this.trackDark,
  });
}

class AppThemes {
  static const List<AppTheme> all = [
    AppTheme(
      name: '清晨蓝',
      primary: Color(0xFF2F6BFF),
      accent: Color(0xFFFF8A5C),
      bgTopLight: Color(0xFFF6F3EF),
      bgBottomLight: Color(0xFFFDFBF8),
      bgTopDark: Color(0xFF0E1117),
      bgBottomDark: Color(0xFF151A22),
      trackLight: Color(0xFFE7E2DA),
      trackDark: Color(0xFF2A3142),
    ),
    AppTheme(
      name: '薄荷绿',
      primary: Color(0xFF1FBF89),
      accent: Color(0xFFFFB25B),
      bgTopLight: Color(0xFFF3F8F6),
      bgBottomLight: Color(0xFFFEFEFD),
      bgTopDark: Color(0xFF0E1414),
      bgBottomDark: Color(0xFF161F1E),
      trackLight: Color(0xFFE4EEE9),
      trackDark: Color(0xFF27302F),
    ),
    AppTheme(
      name: '日落紫橙',
      primary: Color(0xFF6B4EFF),
      accent: Color(0xFFFF7A45),
      bgTopLight: Color(0xFFF8F4FA),
      bgBottomLight: Color(0xFFFEF7F1),
      bgTopDark: Color(0xFF111018),
      bgBottomDark: Color(0xFF1B1824),
      trackLight: Color(0xFFECE2F2),
      trackDark: Color(0xFF2B2537),
    ),
  ];
}
