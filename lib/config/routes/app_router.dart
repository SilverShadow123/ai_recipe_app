import 'package:ai_recipe_app/features/recipe/presentation/pages/login_page.dart';
import 'package:ai_recipe_app/features/recipe/presentation/pages/splash_page.dart';
import 'package:get_it/get_it.dart';
import 'package:go_router/go_router.dart';

import '../../features/recipe/presentation/pages/home_page.dart';

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
      path: '/home',
      name: 'home',
      builder: (context, state) => const HomePage(),
    ),
  ],
);
