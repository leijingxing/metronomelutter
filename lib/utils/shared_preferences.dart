import 'dart:async';

import 'package:shared_preferences/shared_preferences.dart';

/// 用来做shared_preferences的存储,数据存储是异步的,读取是同步的
class SpUtil {
  static SpUtil? _instance;
  static SharedPreferences? _spf;

  SpUtil._();

  Future<void> _init() async {
    _spf = await SharedPreferences.getInstance();
  }

  static Future<SpUtil> getInstance() async {
    final instance = _instance;
    if (instance != null) {
      return instance;
    }
    final created = SpUtil._();
    await created._init();
    _instance = created;
    return created;
  }

  static bool _beforCheck() {
    return _spf == null;
  }

  // 判断是否存在数据
  bool hasKey(String key) {
    final keys = getKeys();
    return keys.contains(key);
  }

  Set<String> getKeys() {
    if (_beforCheck()) return <String>{};
    return _spf!.getKeys();
  }

  Object? get(String key) {
    if (_beforCheck()) return null;
    return _spf!.get(key);
  }

  /// 如果你直接调用getString，主线程会等待加载sp的线程加载完毕
  String? getString(String key) {
    if (_beforCheck()) return null;
    return _spf!.getString(key);
  }

  Future<bool> putString(String key, String value) {
    if (_beforCheck()) return Future.value(false);
    return _spf!.setString(key, value);
  }

  bool? getBool(String key) {
    if (_beforCheck()) return null;
    return _spf!.getBool(key);
  }

  Future<bool> putBool(String key, bool value) {
    if (_beforCheck()) return Future.value(false);
    return _spf!.setBool(key, value);
  }

  int? getInt(String key) {
    if (_beforCheck()) return null;
    return _spf!.getInt(key);
  }

  Future<bool> putInt(String key, int value) {
    if (_beforCheck()) return Future.value(false);
    return _spf!.setInt(key, value);
  }

  double? getDouble(String key) {
    if (_beforCheck()) return null;
    return _spf!.getDouble(key);
  }

  Future<bool> putDouble(String key, double value) {
    if (_beforCheck()) return Future.value(false);
    return _spf!.setDouble(key, value);
  }

  List<String>? getStringList(String key) {
    if (_beforCheck()) return null;
    return _spf!.getStringList(key);
  }

  Future<bool> putStringList(String key, List<String> value) {
    if (_beforCheck()) return Future.value(false);
    return _spf!.setStringList(key, value);
  }

  Object? getDynamic(String key) {
    if (_beforCheck()) return null;
    return _spf!.get(key);
  }

  Future<bool> remove(String key) {
    if (_beforCheck()) return Future.value(false);
    return _spf!.remove(key);
  }

  Future<bool> clear() {
    if (_beforCheck()) return Future.value(false);
    return _spf!.clear();
  }
}

