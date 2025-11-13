import 'package:flutter/material.dart';

class AuthPageHeader extends StatelessWidget {
  const AuthPageHeader({
    super.key,
    this.logo,
    required this.title,
    this.headline,
    required this.subtitle,
  });

  final Widget? logo;
  final String title;
  final String? headline;
  final String subtitle;

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        if (logo != null) logo!,
        if (logo != null) const SizedBox(height: 24),
        Text(
          title,
          style: textTheme.titleMedium?.copyWith(
            fontWeight: FontWeight.w600,
            color: Colors.black87,
          ),
        ),
        if (headline != null) ...[
          const SizedBox(height: 12),
          Text(
            headline!,
            style: textTheme.headlineSmall?.copyWith(
              fontWeight: FontWeight.w700,
              color: Colors.black,
            ),
          ),
        ],
        const SizedBox(height: 8),
        Text(
          subtitle,
          style: textTheme.bodyMedium?.copyWith(color: Colors.grey.shade600),
          textAlign: TextAlign.center,
        ),
      ],
    );
  }
}
