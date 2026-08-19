import 'package:shared_preferences/shared_preferences.dart';

class PreferencesService {
  static const themeKey = 'pref_theme';
  static const hapticsKey = 'pref_haptics';
  static const groceryPlanSignatureKey = 'pref_grocery_plan_signature';
  static const groceryCheckedItemsKey = 'pref_grocery_checked_items';

  final SharedPreferences _preferences;

  PreferencesService(this._preferences);

  bool get isDarkMode => _preferences.getBool(themeKey) ?? true;

  bool get isHapticsEnabled => _preferences.getBool(hapticsKey) ?? true;

  String? get groceryPlanSignature =>
      _preferences.getString(groceryPlanSignatureKey);

  Set<String> get groceryCheckedItemKeys =>
      (_preferences.getStringList(groceryCheckedItemsKey) ?? const []).toSet();

  Future<void> setDarkMode(bool value) {
    return _preferences.setBool(themeKey, value);
  }

  Future<void> setHapticsEnabled(bool value) {
    return _preferences.setBool(hapticsKey, value);
  }

  // Saves the grocery plan signature.
  Future<void> setGroceryPlanSignature(String value) async {
    final saved = await _preferences.setString(groceryPlanSignatureKey, value);
    if (!saved) {
      throw StateError('Could not save grocery plan');
    }
  }

  // Saves checked grocery item keys.
  Future<void> setGroceryCheckedItemKeys(Set<String> values) async {
    final sortedValues = values.toList()..sort();
    final saved =
        await _preferences.setStringList(groceryCheckedItemsKey, sortedValues);
    if (!saved) {
      throw StateError('Could not save grocery progress');
    }
  }
}
