import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

import 'saved_recipe_tile.dart';

class SavedRecipesBody extends StatelessWidget {
  const SavedRecipesBody({super.key});

  @override
  Widget build(BuildContext context) {
    final user = FirebaseAuth.instance.currentUser;

    if (user == null) {
      return const Center(child: Text('Please sign in to see your saved recipes.'));
    }

    return StreamBuilder<QuerySnapshot<Map<String, dynamic>>>(
      stream: FirebaseFirestore.instance
          .collection('users')
          .doc(user.uid)
          .collection('recipes')
          .orderBy('createdAt', descending: true)
          .snapshots(),
      builder: (context, snapshot) {
        if (snapshot.hasError) {
          return Center(
            child: Text('Failed to load saved recipes: ${snapshot.error}'),
          );
        }

        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }

        final docs = snapshot.data?.docs ?? [];
        if (docs.isEmpty) {
          return const Center(child: Text('No saved recipes yet.'));
        }

        return ListView.separated(
          padding: const EdgeInsets.all(12),
          itemCount: docs.length,
          separatorBuilder: (_, __) => const SizedBox(height: 8),
          itemBuilder: (context, index) {
            final data = docs[index].data();
            final recipeText = (data['recipeText'] as String?) ?? '';
            final ingredients = (data['ingredients'] as String?) ?? '';
            final imagePath = (data['imagePath'] as String?) ?? '';

            final createdAtRaw = data['createdAt'];
            DateTime? createdAt;
            if (createdAtRaw is Timestamp) {
              createdAt = createdAtRaw.toDate();
            }

            return SavedRecipeTile(
              docRef: docs[index].reference,
              recipeText: recipeText,
              ingredients: ingredients,
              imagePath: imagePath,
              createdAt: createdAt,
            );
          },
        );
      },
    );
  }
}
