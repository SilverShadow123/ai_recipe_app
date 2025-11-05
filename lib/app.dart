import 'package:ai_recipe_app/core/config/routes/app_routes.dart';
import 'package:ai_recipe_app/core/theme/app_theme.dart';
import 'package:flutter/material.dart';


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

