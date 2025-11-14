import 'package:ai_recipe_app/features/recipe/presentation/pages/login_page.dart';
import 'package:ai_recipe_app/features/recipe/presentation/pages/splash_page.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:get_it/get_it.dart';
import 'package:go_router/go_router.dart';

import '../../features/recipe/presentation/pages/home_page.dart';
import '../../features/recipe/presentation/pages/register_page.dart';
import '../../features/recipe/presentation/bloc/recipe/recipe_bloc.dart';

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
      builder: (context, state) => BlocProvider(
        create: (_) => sl<RecipeBloc>(),
        child: HomePage(),
      ),
    ),
    GoRoute(
      path: '/register',
      name: 'register',
      builder: (context, state) => const RegisterPage(),
    )
  ],
);
