import 'package:bloc/bloc.dart';
import 'package:flutter/material.dart';
import 'package:meta/meta.dart';

part 'system_settings_state.dart';

class SystemSettingsCubit extends Cubit<SystemSettingsState> {

  bool themeState = false;

  SystemSettingsCubit() : super(SystemSettingsInitial());

  ThemeMode get getThemeData {
    switch(themeState) {
      case false: return ThemeMode.dark;
      case true: return ThemeMode.light;
      default: return ThemeMode.dark;
    }
  }

  void swapThemeState() {
    themeState = !themeState;
    emit(SystemSettingsSwapThemeState());
  }

}
