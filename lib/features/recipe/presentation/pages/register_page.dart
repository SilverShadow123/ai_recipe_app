import 'package:ai_recipe_app/core/constants/app_colors.dart';
import 'package:ai_recipe_app/core/widgets/app_capsule_button.dart';
import 'package:flutter/material.dart';

import '../widgets/app_logo.dart';
import '../widgets/auth_page_header.dart';
import '../widgets/auth_register_form.dart';

class RegisterPage extends StatefulWidget {
  const RegisterPage({super.key});

  @override
  State<RegisterPage> createState() => _RegisterPageState();
}

class _RegisterPageState extends State<RegisterPage> {
  final _formKey = GlobalKey<FormState>();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey.shade50,
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 32),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                AuthPageHeader(
                  logo: const AppLogo(),
                  title: 'Create an Account',
                  subtitle: 'Start cooking smarter with AI',
                ),
                const SizedBox(height: 32),
                AuthRegisterForm(formKey: _formKey),
                const SizedBox(height: 32),
                AppCapsuleButton(
                  label: 'Whip up recipes from your ingredients',
                  icon: Icons.auto_awesome,
                  backgroundColor: AppColors.accentGreen,
                  foregroundColor: Colors.white,
                  onPressed: () {
                    // TODO: CTA action
                  },
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
