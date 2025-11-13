import 'package:flutter/material.dart';
import 'package:loading_animation_widget/loading_animation_widget.dart';

class CustomLoadingIndicator extends StatelessWidget {
  const CustomLoadingIndicator({super.key});

  @override
  Widget build(BuildContext context) {
    return LoadingAnimationWidget.discreteCircle(
      color: Colors.orange,
      secondRingColor: Colors.green,
      thirdRingColor: Colors.grey.shade300,
      size: 32,
    );
  }
}
