import 'package:flutter_bloc/flutter_bloc.dart';

import 'package:reciplan3/logic/data/services/preferences_service.dart';
import 'app_settings_state.dart';

class AppSettingsCubit extends Cubit<AppSettingsState> {
  final PreferencesService _preferencesService;

  AppSettingsCubit(this._preferencesService)
      : super(
          AppSettingsState(
            hapticsEnabled: _preferencesService.isHapticsEnabled,
          ),
        );

  Future<void> setHapticsEnabled(bool value) async {
    await _preferencesService.setHapticsEnabled(value);
    emit(state.copyWith(hapticsEnabled: value));
  }
}
