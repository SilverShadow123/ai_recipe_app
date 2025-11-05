import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import '../../../features/splash/presentation/bloc/splash_bloc.dart';
import '../../di/locator.dart';
import '../../../features/home/presentation/pages/home_screen.dart';
import '../../../features/splash/presentation/pages/splash_screen.dart';

class AppRoutes {
  AppRoutes();

  static final GoRouter router = GoRouter(
    initialLocation: '/',
    routes: [
      GoRoute(
        path: '/',
        builder: (context, state) => BlocProvider(
          create: (_) => locator<SplashBloc>(),
          child: const SplashScreen(),
        ),
        name: 'splash',
      ),
      GoRoute(
        path: '/home',
        builder: (context, state) => const HomeScreen(),
        name: 'home',
      ),
    ],
    errorBuilder: (context, state) => Scaffold(
      body: Center(
        child: Text(
          'Route not found: ${state.error}',
          style: const TextStyle(color: Colors.red, fontSize: 24),
        ),
      ),
    ),
  );
}
