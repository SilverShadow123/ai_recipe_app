import 'package:flutter/material.dart';

class LoadingIndicator extends StatelessWidget {
  const LoadingIndicator({super.key, this.message, this.size = 48});

  final String? message;
  final double size;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final indicator = SizedBox(
      width: size,
      height: size,
      child: CircularProgressIndicator(
        strokeWidth: size * 0.12,
        valueColor: AlwaysStoppedAnimation<Color>(colorScheme.primary),
        backgroundColor: colorScheme.primary.withAlpha(100),
      ),
    );

    if (message == null) {
      return indicator;
    }

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        indicator,
        const SizedBox(height: 24),
        Text(
          message!,
          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                color: colorScheme.onSurface,
                fontWeight: FontWeight.bold,
              ),
          textAlign: TextAlign.center,
          softWrap: true,
        ),
      ],
    );
  }
}

