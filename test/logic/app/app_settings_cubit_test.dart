import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:reciplan3/logic/app/settings/app_settings_cubit.dart';
import 'package:reciplan3/logic/data/services/preferences_service.dart';

void main() {
  group('AppSettingsCubit', () {
    test('reads haptics from preferences and persists changes', () async {
      SharedPreferences.setMockInitialValues({
        PreferencesService.hapticsKey: true,
      });
      final preferences = await SharedPreferences.getInstance();
      final service = PreferencesService(preferences);
      final cubit = AppSettingsCubit(service);

      expect(cubit.state.hapticsEnabled, isTrue);

      await cubit.setHapticsEnabled(false);

      expect(cubit.state.hapticsEnabled, isFalse);
      expect(preferences.getBool(PreferencesService.hapticsKey), isFalse);
      await cubit.close();
    });
  });
}
