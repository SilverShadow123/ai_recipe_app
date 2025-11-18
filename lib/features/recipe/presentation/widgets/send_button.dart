
import 'package:flutter/material.dart';

class SendButton extends StatelessWidget {
  final bool isLoading;
  final VoidCallback onPressed;

  const SendButton({
    super.key,
    required this.isLoading,
    required this.onPressed,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(left: 8.0),
      child: IconButton(
        icon: isLoading
            ? const SizedBox(
          width: 20,
          height: 20,
          child: CircularProgressIndicator(strokeWidth: 2),
        )
            : const Icon(Icons.send),
        onPressed: isLoading ? null : onPressed,
        padding: const EdgeInsets.all(12),
      ),
    );
  }
}