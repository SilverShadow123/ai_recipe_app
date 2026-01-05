import 'dart:convert';
import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'theme_settings_state.dart';

class ThemeSettingsCubit extends Cubit<ThemeSettingsState> {
  static const String _prefsKey = 'theme_settings';
  
  ThemeSettingsCubit() : super(ThemeSettingsState()) {
    _loadSettings();
  }

  Future<void> _loadSettings() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final settingsJson = prefs.getString(_prefsKey);
      
      if (settingsJson != null) {
        final settings = jsonDecode(settingsJson);
        emit(state.copyWith(
          fontSizeFactor: settings['fontSizeFactor'] ?? state.fontSizeFactor,
          fontFamily: settings['fontFamily'] ?? state.fontFamily,
          appColor: settings['appColor'] != null 
              ? Color(settings['appColor']) 
              : state.appColor,
        ));
      }
    } catch (e) {
      print('Error loading theme settings: $e');
    }
  }

  // Save settings to SharedPreferences
  Future<void> _saveSettings() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString(_prefsKey, jsonEncode({
        'fontSizeFactor': state.fontSizeFactor,
        'fontFamily': state.fontFamily,
        'appColor': state.appColor.toARGB32(),
      }));
    } catch (e) {
      print('Error saving theme settings: $e');
    }
  }

  // Update font size factor
  void setFontSizeFactor(double factor) async {
    emit(state.copyWith(fontSizeFactor: factor));
    await _saveSettings();
  }

  // Increase font size factor
  void increaseFontSizeFactor() {
    setFontSizeFactor(state.fontSizeFactor + 0.05);
  }

  // Change font family
  void setFontFamily(String fontFamily) async {
    emit(state.copyWith(fontFamily: fontFamily));
    await _saveSettings();
  }

  // Change app theme color
  void setAppColor(Color color) async {
    emit(state.copyWith(appColor: color));
    await _saveSettings();
  }
}
