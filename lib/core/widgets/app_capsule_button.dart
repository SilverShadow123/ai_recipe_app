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
    this.borderRadius,
  });

  final String label;
  final VoidCallback? onPressed;
  final IconData? icon;
  final Color? backgroundColor;
  final Color? foregroundColor;
  final bool expanded;
  final bool outlined;
  final Color? borderColor;
  final BorderRadius? borderRadius;

  @override
  Widget build(BuildContext context) {
    final button = outlined ? _buildOutlinedButton() : _buildElevatedButton();

    if (expanded) {
      return SizedBox(width: double.infinity, child: button);
    }
    return button;
  }

  Widget _buildElevatedButton() {
    final style = ElevatedButton.styleFrom(
      backgroundColor: backgroundColor,
      foregroundColor: foregroundColor,
      shape: RoundedRectangleBorder(
        borderRadius: borderRadius ?? BorderRadius.circular(999),
      ),
      padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 24),
      textStyle: const TextStyle(fontWeight: FontWeight.w600,fontSize: 16),
      side: borderColor != null ? BorderSide(color: borderColor!) : null,
    );

    return icon != null
        ? ElevatedButton.icon(
            onPressed: onPressed,
            style: style,
            icon: Icon(icon),
            label: Text(label),
          )
        : ElevatedButton(
            onPressed: onPressed,
            style: style,
            child: Text(label),
          );
  }

  Widget _buildOutlinedButton() {
    final style = OutlinedButton.styleFrom(
      backgroundColor: backgroundColor,
      foregroundColor: foregroundColor,
      side: BorderSide(color: borderColor ?? Colors.grey.withAlpha(50)),
      shape: RoundedRectangleBorder(
        borderRadius: borderRadius ?? BorderRadius.circular(999),
      ),
      padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 24),
      textStyle: const TextStyle(fontWeight: FontWeight.w600),
    );

    return icon != null
        ? OutlinedButton.icon(
            onPressed: onPressed,
            style: style,
            icon: Icon(icon),
            label: Text(label),
          )
        : OutlinedButton(
            onPressed: onPressed,
            style: style,
            child: Text(label),
          );
  }
}
