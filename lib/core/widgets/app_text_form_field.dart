import 'package:flutter/material.dart';

class AppTextFormField extends StatelessWidget {
  const AppTextFormField({
    super.key,
    required this.label,
    required this.hintText,
    this.prefixIcon,
    this.suffix,
    this.obscureText = false,
    this.keyboardType,
    this.controller,
    this.validator,
    this.onChanged,
    this.textInputAction,
    this.autofillHints,
    this.border, this.maxLines,
  });

  final String label;
  final String hintText;
  final IconData? prefixIcon;
  final Widget? suffix;
  final bool obscureText;
  final TextInputType? keyboardType;
  final TextEditingController? controller;
  final FormFieldValidator<String>? validator;
  final ValueChanged<String>? onChanged;
  final TextInputAction? textInputAction;
  final Iterable<String>? autofillHints;
  final InputBorder? border;
  final int? maxLines;

  @override
  Widget build(BuildContext context) {
    final labelStyle = Theme.of(context).textTheme.labelLarge?.copyWith(
          fontWeight: FontWeight.w600,
          color: Colors.grey.shade700,
        );

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: labelStyle),
        const SizedBox(height: 8),
        TextFormField(

          controller: controller,
          maxLines: maxLines,
          keyboardType: keyboardType,
          obscureText: obscureText,
          decoration: InputDecoration(
            hintText: hintText,
            prefixIcon: prefixIcon != null
                ? Icon(prefixIcon, color: Colors.grey.shade500)
                : null,
            suffixIcon: suffix,
            border: border,
            enabledBorder: border,
            focusedBorder: border,
            disabledBorder: border,
            errorBorder: border,
            focusedErrorBorder: border,
          ),
          validator: validator,
          onChanged: onChanged,
          textInputAction: textInputAction,
          autofillHints: autofillHints,
        ),
      ],
    );
  }
}
