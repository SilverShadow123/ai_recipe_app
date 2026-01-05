import 'package:equatable/equatable.dart';
import 'package:flutter/material.dart';

class ThemeSettingsState extends Equatable {
  final double fontSizeFactor;
  final String fontFamily;
  final Color appColor;
  final ThemeData appTheme;

  ThemeSettingsState({
    this.fontSizeFactor = 1.0,
    this.fontFamily = 'Georgia',
    this.appColor = Colors.yellow,
  }) : appTheme = ThemeData(
          colorScheme: ColorScheme.fromSeed(seedColor: Colors.yellow),
        );
        
  ThemeData get currentTheme {
    return ThemeData(
      colorScheme: ColorScheme.fromSeed(seedColor: appColor),
      useMaterial3: true,
      textTheme: TextTheme(
        bodyLarge: const TextStyle().copyWith(fontSize: 16.0 * fontSizeFactor),
        bodyMedium: const TextStyle().copyWith(fontSize: 14.0 * fontSizeFactor),
        titleLarge: const TextStyle().copyWith(fontSize: 20.0 * fontSizeFactor),
        titleMedium: const TextStyle().copyWith(fontSize: 18.0 * fontSizeFactor),
        titleSmall: const TextStyle().copyWith(fontSize: 16.0 * fontSizeFactor),
        headlineLarge: const TextStyle().copyWith(fontSize: 40.0 * fontSizeFactor),
        headlineMedium: const TextStyle().copyWith(fontSize: 34.0 * fontSizeFactor),
        headlineSmall: const TextStyle().copyWith(fontSize: 24.0 * fontSizeFactor),
      ),
    );
  }

  ThemeSettingsState copyWith({
    double? fontSizeFactor,
    String? fontFamily,
    Color? appColor,
  }) {
    return ThemeSettingsState(
      fontSizeFactor: fontSizeFactor ?? this.fontSizeFactor,
      fontFamily: fontFamily ?? this.fontFamily,
      appColor: appColor ?? this.appColor,
    );
  }

  @override
  List<Object> get props => [fontSizeFactor, fontFamily, appColor];
}
