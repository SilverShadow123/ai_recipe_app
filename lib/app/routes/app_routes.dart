import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import '../../core/di/locator.dart';
import '../../logic/blocs/splash/splash_bloc.dart';
import '../../presentation/screens/home/home_screen.dart';
import '../../presentation/screens/splash_screen/splash_screen.dart';

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
  );
}
