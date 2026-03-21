import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'package:reciplan3/logic/data/services/preferences_service.dart';

class AppThemeCubit extends Cubit<ThemeMode> {
  final PreferencesService _preferencesService;

  AppThemeCubit(this._preferencesService)
      : super(
          _preferencesService.isDarkMode ? ThemeMode.dark : ThemeMode.light,
        );

  Future<void> setDarkMode(bool isDarkMode) async {
    await _preferencesService.setDarkMode(isDarkMode);
    emit(isDarkMode ? ThemeMode.dark : ThemeMode.light);
  }
}
