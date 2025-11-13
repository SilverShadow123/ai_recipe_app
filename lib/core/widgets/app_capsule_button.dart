import 'package:flutter/material.dart';

class AppCapsuleButton extends StatelessWidget {
  const AppCapsuleButton({
    super.key,
    required this.label,
    required this.onPressed,
    this.icon,
    this.backgroundColor,
    this.foregroundColor,
    this.expanded = true,
    this.outlined = false,
    this.borderColor,
  });

  final String label;
  final VoidCallback? onPressed;
  final IconData? icon;
  final Color? backgroundColor;
  final Color? foregroundColor;
  final bool expanded;
  final bool outlined;
  final Color? borderColor;

  @override
  Widget build(BuildContext context) {
    final button = outlined ? _outlinedButton(context) : _filledButton(context);

    if (expanded) {
      return SizedBox(width: double.infinity, child: button);
    }
    return button;
  }

  Widget _filledButton(BuildContext context) {
    final themeStyle = Theme.of(context).elevatedButtonTheme.style;
    final baseStyle = themeStyle ?? ElevatedButton.styleFrom();

    final style = baseStyle.copyWith(
      backgroundColor: backgroundColor != null
          ? WidgetStatePropertyAll<Color>(backgroundColor!)
          : null,
      foregroundColor: foregroundColor != null
          ? WidgetStatePropertyAll<Color>(foregroundColor!)
          : null,
    );

    if (icon != null) {
      return ElevatedButton.icon(
        onPressed: onPressed,
        style: style,
        icon: Icon(icon),
        label: Text(label),
      );
    }

    return ElevatedButton(
      onPressed: onPressed,
      style: style,
      child: Text(label),
    );
  }

  Widget _outlinedButton(BuildContext context) {
    final themeStyle = Theme.of(context).outlinedButtonTheme.style;
    final baseStyle = themeStyle ?? OutlinedButton.styleFrom();

    final style = baseStyle.copyWith(
      backgroundColor: backgroundColor != null
          ? WidgetStatePropertyAll<Color>(backgroundColor!)
          : null,
      foregroundColor: foregroundColor != null
          ? WidgetStatePropertyAll<Color>(foregroundColor!)
          : null,
      side: WidgetStatePropertyAll<BorderSide>(
        BorderSide(color: borderColor ?? Colors.grey.withAlpha(50)),
      ),
    );

    if (icon != null) {
      return OutlinedButton.icon(
        onPressed: onPressed,
        style: style,
        icon: Icon(icon),
        label: Text(label),
      );
    }

    return OutlinedButton(
      onPressed: onPressed,
      style: style,
      child: Text(label),
    );
  }
}
