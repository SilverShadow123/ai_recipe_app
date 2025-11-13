import 'package:ai_recipe_app/core/constants/app_colors.dart';
import 'package:ai_recipe_app/core/widgets/app_capsule_button.dart';
import 'package:flutter/material.dart';
import '../widgets/app_logo.dart';
import '../widgets/auth_login_form.dart';
import '../widgets/auth_page_header.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
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
                  title: 'AI Recipe Assistant',
                  headline: 'Login',
                  subtitle: "Welcome back! Let's get cooking",
                ),
                const SizedBox(height: 32),
                AuthLoginForm(formKey: _formKey),
                const SizedBox(height: 32),
                AppCapsuleButton(
                  label: 'Cook more with less',
                  icon: Icons.restaurant_menu_outlined,
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
