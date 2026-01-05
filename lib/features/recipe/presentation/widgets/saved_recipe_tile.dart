import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

import 'saved_recipe_dialog.dart';

class SavedRecipeTile extends StatelessWidget {
  final DocumentReference<Map<String, dynamic>> docRef;
  final String recipeText;
  final String ingredients;
  final String imagePath;
  final DateTime? createdAt;

  const SavedRecipeTile({
    super.key,
    required this.docRef,
    required this.recipeText,
    required this.ingredients,
    required this.imagePath,
    required this.createdAt,
  });

  @override
  Widget build(BuildContext context) {
    final imageFile = imagePath.trim().isEmpty ? null : File(imagePath);
    final hasImage = imageFile != null && imageFile.existsSync();

    final title = recipeText.trim().isEmpty
        ? 'Saved recipe'
        : recipeText.trim().split('\n').first;

    return Card(
      child: ListTile(
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        minVerticalPadding: 12,
        leading: ClipRRect(
          borderRadius: BorderRadius.circular(8),
          child: SizedBox(
            width: 72,
            height: 72,
            child: hasImage
                ? Image.file(
                    imageFile,
                    fit: BoxFit.fill,
                  )
                : Container(
                    color: Theme.of(context)
                        .colorScheme
                        .surfaceContainerHighest,
                    alignment: Alignment.center,
                    child: const Icon(Icons.image_not_supported),
                  ),
          ),
        ),
        title: Text(
          title,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (ingredients.trim().isNotEmpty) ...[
              const SizedBox(height: 4),
              Text(
                ingredients,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
            ],
            if (createdAt != null) ...[
              const SizedBox(height: 6),
              Text(
                'Saved: ${createdAt!.toLocal()}',
                style: Theme.of(context).textTheme.bodySmall,
              ),
            ],
          ],
        ),
        trailing: IconButton(
          icon: const Icon(Icons.delete_outline),
          onPressed: () async {
            final confirmed = await showDialog<bool>(
              context: context,
              builder: (context) {
                return AlertDialog(
                  title: const Text('Delete saved recipe?'),
                  content: const Text(
                    'This will remove it from your saved recipes.',
                  ),
                  actions: [
                    TextButton(
                      onPressed: () => Navigator.pop(context, false),
                      child: const Text('Cancel'),
                    ),
                    TextButton(
                      onPressed: () => Navigator.pop(context, true),
                      child: const Text('Delete'),
                    ),
                  ],
                );
              },
            );

            if (confirmed != true) return;
            if (!context.mounted) return;

            try {
              await docRef.delete();

              if (imageFile != null && await imageFile.exists()) {
                await imageFile.delete();
              }

              if (!context.mounted) return;
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Deleted.')),
              );
            } catch (e) {
              if (!context.mounted) return;
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text('Delete failed: $e')),
              );
            }
          },
        ),
        onTap: () {
          showDialog<void>(
            context: context,
            builder: (context) {
              return SavedRecipeDialog(
                recipeText: recipeText,
                imageFile: hasImage ? imageFile : null,
              );
            },
          );
        },
      ),
    );
  }
}
