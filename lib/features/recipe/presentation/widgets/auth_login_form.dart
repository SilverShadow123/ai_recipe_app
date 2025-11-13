import 'package:flutter/material.dart';

import '../../../../core/constants/app_colors.dart';
import '../../../../core/widgets/app_capsule_button.dart';
import 'auth_additional_providers.dart';
import 'auth_credentials_fields.dart';

class AuthLoginForm extends StatelessWidget {
  const AuthLoginForm({
    super.key,
    required GlobalKey<FormState> formKey,
    required this.textTheme,
  }) : _formKey = formKey;

  final GlobalKey<FormState> _formKey;
  final TextTheme textTheme;

  @override
  Widget build(BuildContext context) {
    return Form(
      key: _formKey,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const AuthCredentialsFields(),
          const SizedBox(height: 28),
          AppCapsuleButton(
            label: 'Login',
            onPressed: () {
              if (_formKey.currentState?.validate() ?? false) {
                // TODO: handle login
              }
            },
          ),
          const SizedBox(height: 16),
          Center(
            child: RichText(
              text: TextSpan(
                text: "Don't have an account? ",
                style: textTheme.bodyMedium?.copyWith(
                  color: Colors.grey.shade600,
                ),
                children: [
                  TextSpan(
                    text: 'Register',
                    style: const TextStyle(
                      color: AppColors.primaryColor,
                      fontWeight: FontWeight.w600,
                    ),
                    recognizer: null,
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 24),
          AuthAdditionalProviders(),
        ],
      ),
    );
  }
}
