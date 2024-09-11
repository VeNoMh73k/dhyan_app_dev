import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';

class PreferenceHelper {
  static const String isReminderOn = 'isReminderOn';
  static const String reminderHour = 'reminderHour';
  static const String reminderMin = 'reminderMin';

  static SharedPreferences? _prefs;

  static Future<SharedPreferences?> load() async {
    _prefs ??= await SharedPreferences.getInstance();
    return _prefs;
  }

  static Future<void> setString(String key, String value) async {
    await _prefs?.setString(key, value);
  }

  static Future<void> remove(String? key) async {
    if (key != null) {
      await _prefs?.remove(key);
    }
  }

  static bool containsKey(String? key) {
    var doesContain = false;
    if (key != null) {
      doesContain = _prefs?.containsKey(key) ?? false;
    }
    return doesContain;
  }

  static Future<void> setObject<T>(String key, dynamic value) async {
    const encoder = JsonEncoder();
    await _prefs?.setString(key, encoder.convert(value));
  }

  static Future<void> setInt(String key, int value) async {
    await _prefs?.setInt(key, value);
  }

  static Future<void> setDouble(String key, double value) async {
    await _prefs?.setDouble(key, value);
  }

  static Future<void> setBool(String key, bool value) async {
    await _prefs?.setBool(key, value);
  }

  static String? getString(String key, {String? def}) {
    String? val;
    val ??= _prefs?.getString(key);
    val ??= def;
    return val;
  }

  static int? getInt(String key, {int? def}) {
    int? val;
    val ??= _prefs?.getInt(key);
    val ??= def;
    return val;
  }

  static double? getDouble(String key, {double? def}) {
    double? val;
    val ??= _prefs?.getDouble(key);
    val ??= def;
    return val;
  }

  static bool getBool(String key, {bool def = false}) {
    bool? val;
    val ??= _prefs?.getBool(key);
    val ??= def;
    return val;
  }

  static dynamic getObject(String key) {
    final val = getString(key, def: '');
    if (val != null) {
      const decoder = JsonDecoder();
      return decoder.convert(val);
    }
    return '';
  }

  static Future<void> clear() async {
    await _prefs?.clear();
  }

  static Future<void> reload() async {
    await _prefs?.reload();
  }
}
