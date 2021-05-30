import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';

const tokenKey = 'token';

class SharedPreferencesManager {
  factory SharedPreferencesManager() => _manager;

  static final _manager = SharedPreferencesManager._internal();

  SharedPreferencesManager._internal();

  SharedPreferences _prefs;

  Future<void> init() async {
    await SharedPreferences.getInstance().then((data) {
      _prefs = data;
    });
  }

  void save(String key, dynamic data) {
    _prefs?.setString(key, data == null ? null : jsonEncode(data));
  }

  void remove(String key) {
    _prefs?.remove(key);
  }

  void saveString({String key, String value}) {
    _prefs?.setString(key, value);
  }

  String getString({String key}) {
    final value = _prefs?.getString(key);
    return value ?? '';
  }
}

final SharedPreferencesManager sharedPreferences = SharedPreferencesManager();
