import 'package:ai_recipe_app/features/recipe/presentation/widgets/send_button.dart';
import 'package:flutter/material.dart';

class MessageInput extends StatelessWidget {
  final TextEditingController controller;
  final bool isLoading;
  final Function() onSend;
  final VoidCallback onScreenshot;

  const MessageInput({
    super.key,
    required this.controller,
    required this.isLoading,
    required this.onSend,
    required this.onScreenshot,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        border: Border(
          top: BorderSide(
            color: Theme.of(context).dividerColor,
            width: 0.5,
          ),
        ),
      ),
      child: Row(
        children: [
          Expanded(
            child: TextField(
              controller: controller,
              decoration: InputDecoration(
                hintText: 'Type a message...',
                border: InputBorder.none,
                contentPadding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 12.0),
                hintStyle: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      color: Theme.of(context).hintColor,
                    ),
              ),
              maxLines: null,
              keyboardType: TextInputType.multiline,
              onSubmitted: (_) => onSend(),
            ),
          ),
          IconButton(
            icon: const Icon(Icons.camera_alt),
            onPressed: isLoading ? null : onScreenshot,
          ),
          const SizedBox(width: 4),
          SendButton(
            isLoading: isLoading,
            onPressed: onSend,
          ),
        ],
      ),
    );
  }
}