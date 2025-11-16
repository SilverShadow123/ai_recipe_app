import 'package:ai_recipe_app/core/widgets/bottom_navigation_shell.dart';
import 'package:ai_recipe_app/features/recipe/presentation/bloc/bottom_navigation/bottom_nav_cubit.dart';
import 'package:ai_recipe_app/features/recipe/presentation/bloc/recipe/recipe_bloc.dart';
import 'package:ai_recipe_app/features/recipe/presentation/pages/home_page.dart';
import 'package:ai_recipe_app/features/recipe/presentation/pages/login_page.dart';
import 'package:ai_recipe_app/features/recipe/presentation/pages/register_page.dart';
import 'package:ai_recipe_app/features/recipe/presentation/pages/saved_page.dart';
import 'package:ai_recipe_app/features/recipe/presentation/pages/settings_page.dart';
import 'package:ai_recipe_app/features/recipe/presentation/pages/splash_page.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:get_it/get_it.dart';
import 'package:go_router/go_router.dart';

final sl = GetIt.instance;

final appRouter = GoRouter(
  initialLocation: '/',
  routes: [
    GoRoute(
      path: '/',
      name: 'splash',
      builder: (constext, state) => const SplashPage(),
    ),
    GoRoute(
      path: '/login',
      name: 'login',
      builder: (context, state) => const LoginPage(),
    ),
    GoRoute(
      path: '/register',
      name: 'register',
      builder: (context, state) => const RegisterPage(),
    ),
    ShellRoute(
      builder: (context, state, child) {
        return MultiBlocProvider(
          providers: [
            BlocProvider<RecipeBloc>(
              create: (_) => sl<RecipeBloc>(),
            ),
            BlocProvider<BottomNavCubit>(
              create: (_) => sl<BottomNavCubit>(),
            ),
          ],
          child: BottomNavigationShell(child: child),
        );
      },
      routes: [
        GoRoute(
          path: '/home',
          name: 'home',
          pageBuilder: (context, state) => const MaterialPage(
            child: HomePage(),
          ),
        ),
        GoRoute(
          path: '/saved',
          name: 'saved',
          pageBuilder: (context, state) => const MaterialPage(
            child: SavedPage(),
          ),
        ),
        GoRoute(
          path: '/settings',
          name: 'settings',
          pageBuilder: (context, state) => const MaterialPage(
            child: SettingsPage(),
          ),
        ),
      ],
    ),
  ],
);
