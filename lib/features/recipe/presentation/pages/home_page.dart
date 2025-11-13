import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import '../bloc/auth/auth_bloc.dart';

class HomePage extends StatelessWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Home Page'),
        centerTitle: true,
        actions: [
          BlocListener<AuthBloc, AuthState>(
            listener: (context, state) {
              if(state is AuthError){
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text(state.message)),
                );
              }
            },
            child: IconButton(onPressed: () {
              context.read<AuthBloc>().add(SignOutEvent());
              context.goNamed('login');
            }, icon: Icon(Icons.logout)),
          )
        ],
      ),
      body: Center(
        child: Text('Home Page'),
      ),
    );
  }
}
