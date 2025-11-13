import 'package:ai_recipe_app/features/recipe/presentation/widgets/app_logo.dart';
import 'package:flutter/material.dart';

import 'custom_loading_indicator.dart';

class SplashUI extends StatelessWidget {
  const SplashUI({super.key});

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      spacing: 16,
      children: [
        AppLogo(),
        const Text(
          'AI Recipe Assistant',
          style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
        ),
        Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Text(
              'Smart Cooking Starts Here',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w500,
                color: Colors.grey,
              ),
            ),
            const SizedBox(width: 8),
            Icon(Icons.fastfood_outlined, color: Colors.grey),
          ],
        ),
        CustomLoadingIndicator(),
      ],
    );
  }
}
