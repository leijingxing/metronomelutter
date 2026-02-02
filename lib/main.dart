import 'package:flutter/material.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:metronomelutter/global_data.dart';
import 'package:metronomelutter/pages/home_page.dart';
import 'package:metronomelutter/store/index.dart';

import 'utils/shared_preferences.dart';

void main() async {
  // 确保初始化,否则访问 SharedPreferences 会报错
  WidgetsFlutterBinding.ensureInitialized();

  GlobalData.sp = await SpUtil.getInstance();
  initSoundType();
  initBpm();
  initThemeIndex();

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: '节拍器',
      // 右上角不显示 debug 横幅
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        brightness: Brightness.light,
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.blue),
        useMaterial3: true,
        inputDecorationTheme: InputDecorationTheme(
          filled: true,
          fillColor: Colors.grey.shade50,
        ),
      ),
      darkTheme: ThemeData(
        brightness: Brightness.dark,
        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color.fromRGBO(134, 165, 255, 1),
          brightness: Brightness.dark,
        ),
        useMaterial3: true,
      ),
      themeMode: ThemeMode.system,
      home: const MyHomePage(),
      builder: EasyLoading.init(),
      // home: example01,
    );
  }
}

void initSoundType() {
  final int? soundType = GlobalData.sp.getInt('soundType');
  if (soundType != null) {
    print('get sound type $soundType');
    appStore.setSoundType(soundType);
  }
}

void initBpm() {
  final int? spRes = GlobalData.sp.getInt('bpm');
  if (spRes != null) {
    print('get bpm $spRes');
    appStore.setBpm(spRes);
  }
}

void initThemeIndex() {
  final int? res = GlobalData.sp.getInt('themeIndex');
  if (res != null) {
    appStore.setThemeIndex(res);
  }
}
