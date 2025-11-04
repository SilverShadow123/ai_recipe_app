import 'package:ai_recipe_app/app/routes/app_routes.dart';
import 'package:ai_recipe_app/core/theme/app_theme.dart';
import 'package:ai_recipe_app/logic/blocs/splash/splash_bloc.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../core/di/locator.dart';

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp.router(
      title: 'AI Recipe App',
      routerConfig: AppRoutes.router,
      theme: AppTheme.light,
      darkTheme: AppTheme.dark,
      themeMode: ThemeMode.system,

    );
  }
}

