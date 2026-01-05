import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../../domain/entities/saved_recipe_entity.dart';

class RecipeFirestoreDatasource {
  final FirebaseFirestore firestore;
  final FirebaseAuth auth;

  RecipeFirestoreDatasource({
    required this.firestore,
    required this.auth,
  });

  Future<void> saveRecipe(SavedRecipeEntity recipe) async {
    final uid = auth.currentUser!.uid;

    await firestore
        .collection('users')
        .doc(uid)
        .collection('recipes')
        .doc(recipe.id)
        .set({
      'recipeText': recipe.recipeText,
      'ingredients': recipe.ingredients,
      'imagePath': recipe.imagePath, // LOCAL PATH
      'createdAt': FieldValue.serverTimestamp(),
    });
  }
}
