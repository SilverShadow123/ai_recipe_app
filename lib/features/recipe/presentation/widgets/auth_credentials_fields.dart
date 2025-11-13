import 'package:ai_recipe_app/core/widgets/app_text_form_field.dart';
import 'package:flutter/material.dart';

class AuthCredentialsFields extends StatefulWidget {
  const AuthCredentialsFields({
    super.key,
    this.emailController,
    this.passwordController,
    this.emailValidator,
    this.passwordValidator,
  });

  final TextEditingController? emailController;
  final TextEditingController? passwordController;
  final String? Function(String?)? emailValidator;
  final String? Function(String?)? passwordValidator;

  @override
  State<AuthCredentialsFields> createState() => _AuthCredentialsFieldsState();
}

class _AuthCredentialsFieldsState extends State<AuthCredentialsFields> {
  bool _obscurePassword = true;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        AppTextFormField(
          controller: widget.emailController,
          label: 'Email',
          hintText: 'name@email.com',
          prefixIcon: Icons.mail_outline,
          keyboardType: TextInputType.emailAddress,
          textInputAction: TextInputAction.next,
          autofillHints: const [AutofillHints.email],
          validator: widget.emailValidator ?? _defaultEmailValidator,
        ),
        const SizedBox(height: 20),
        AppTextFormField(
          controller: widget.passwordController,
          label: 'Password',
          hintText: '••••••••',
          prefixIcon: Icons.lock_outline,
          obscureText: _obscurePassword,
          textInputAction: TextInputAction.done,
          autofillHints: const [AutofillHints.password],
          suffix: IconButton(
            onPressed: () {
              setState(() {
                _obscurePassword = !_obscurePassword;
              });
            },
            icon: Icon(
              _obscurePassword
                  ? Icons.visibility_outlined
                  : Icons.visibility_off_outlined,
              color: Colors.grey.shade500,
            ),
          ),
          validator: widget.passwordValidator ?? _defaultPasswordValidator,
        ),
      ],
    );
  }

  String? _defaultEmailValidator(String? value) {
    if (value == null || value.isEmpty) {
      return 'Please enter your email';
    }
    return null;
  }

  String? _defaultPasswordValidator(String? value) {
    if (value == null || value.isEmpty) {
      return 'Please enter your password';
    }
    return null;
  }
}
