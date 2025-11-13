import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../bloc/auth/auth_bloc.dart';
import '../../../../core/widgets/app_capsule_button.dart';

class AuthAdditionalProviders extends StatelessWidget {
  const AuthAdditionalProviders({super.key});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: AppCapsuleButton(
            label: 'Google',
            icon: Icons.g_translate,
            outlined: true,
            foregroundColor: Colors.grey.shade700,
            borderColor: Colors.grey.withAlpha(51),
            backgroundColor: Colors.white,
            onPressed: () {
              context.read<AuthBloc>().add(const SignInWithGoogleEvent());
            },
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: AppCapsuleButton(
            label: 'Apple',
            icon: Icons.apple,
            outlined: true,
            foregroundColor: Colors.grey.shade800,
            borderColor: Colors.grey.withAlpha(51),
            backgroundColor: Colors.white,
            onPressed: () {
              // TODO: implement Apple sign-in
            },
          ),
        ),
      ],
    );
  }
}
