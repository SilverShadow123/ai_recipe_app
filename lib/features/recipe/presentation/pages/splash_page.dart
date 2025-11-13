import 'package:ai_recipe_app/features/recipe/presentation/bloc/auth/auth_bloc.dart';
import 'package:ai_recipe_app/features/recipe/presentation/widgets/splash_ui.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

class SplashPage extends StatelessWidget {
  const SplashPage({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocListener<AuthBloc, AuthState>(
      listenWhen: (previous, current) =>
      previous.runtimeType != current.runtimeType,
      listener: (context, state) {
        if (state is AuthAuthenticated) {
          _navigateAfterDelay('home', context);
        } else if (state is AuthUnauthenticated) {
          _navigateAfterDelay('login', context);
        }
      },
      child: Scaffold(body: Center(child: SplashUI())),
    );
  }

  void _navigateAfterDelay(String route, BuildContext context) {
    Future.delayed(
        Duration(seconds: 3), () {
      if (context.mounted) {
        context.goNamed(route);
      }
    }
    );
  }
}