import 'package:ai_recipe_app/config/routes/app_router.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'config/routes/app_router.dart' as di;
import 'features/recipe/presentation/bloc/auth/auth_bloc.dart';
import 'features/recipe/presentation/bloc/theme_settings/theme_settings_cubit.dart';
import 'features/recipe/presentation/bloc/theme_settings/theme_settings_state.dart';

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider(
          create: (context) => di.sl<AuthBloc>()..add(LoadCurrentUserEvent()),
        ),
        BlocProvider(
          create: (context) => di.sl<ThemeSettingsCubit>(),
        ),
      ],
      child: BlocBuilder<ThemeSettingsCubit, ThemeSettingsState>(
        builder: (context, themeState) {
          return MaterialApp.router(
            debugShowCheckedModeBanner: false,
            theme: themeState.currentTheme,
            routerConfig: appRouter,
          );
        },
      ),
    );
  }
}
