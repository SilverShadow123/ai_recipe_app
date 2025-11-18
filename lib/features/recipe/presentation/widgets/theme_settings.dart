

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../bloc/theme_settings/theme_settings_cubit.dart';
import '../bloc/theme_settings/theme_settings_state.dart';

class ThemeSettings extends StatelessWidget {
  const ThemeSettings({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<ThemeSettingsCubit, ThemeSettingsState>(
      builder: (context, state) {
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Font Family: ${state.fontFamily}'),
            Text('Font Size: ${(state.fontSizeFactor * 100).round()}%'),
          ],
        );
      },
    );
  }
}