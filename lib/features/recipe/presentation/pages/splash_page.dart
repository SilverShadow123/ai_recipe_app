import 'package:ai_recipe_app/features/recipe/presentation/bloc/auth/auth_bloc.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';


class SplashPage extends StatelessWidget {
  const SplashPage({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocListener<AuthBloc, AuthState>(listener: (context, state){
      if(state is AuthAuthenticated){
        context.go('/home');
      }
      if(state is AuthUnauthenticated){
        context.go('/login');
      }
    });
  }
}

