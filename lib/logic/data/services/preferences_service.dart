import 'package:shared_preferences/shared_preferences.dart';

class PreferencesService {
  static const themeKey = 'pref_theme';
  static const hapticsKey = 'pref_haptics';

  final SharedPreferences _preferences;

  PreferencesService(this._preferences);

  bool get isDarkMode => _preferences.getBool(themeKey) ?? true;

  bool get isHapticsEnabled => _preferences.getBool(hapticsKey) ?? true;

  Future<void> setDarkMode(bool value) {
    return _preferences.setBool(themeKey, value);
  }

  Future<void> setHapticsEnabled(bool value) {
    return _preferences.setBool(hapticsKey, value);
  }
}
