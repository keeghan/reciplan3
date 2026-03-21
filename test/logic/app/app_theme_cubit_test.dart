import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:reciplan3/logic/app/theme/app_theme_cubit.dart';
import 'package:reciplan3/logic/data/services/preferences_service.dart';

void main() {
  group('AppThemeCubit', () {
    test('reads the initial theme from preferences and persists updates', () async {
      SharedPreferences.setMockInitialValues({
        PreferencesService.themeKey: false,
      });
      final preferences = await SharedPreferences.getInstance();
      final service = PreferencesService(preferences);
      final cubit = AppThemeCubit(service);

      expect(cubit.state, ThemeMode.light);

      await cubit.setDarkMode(true);

      expect(cubit.state, ThemeMode.dark);
      expect(preferences.getBool(PreferencesService.themeKey), isTrue);
      await cubit.close();
    });
  });
}
