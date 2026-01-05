import 'dart:typed_data';
import '../entities/recipe_entity.dart';
import '../entities/saved_recipe_entity.dart';

abstract class RecipeRepository {
  Future<RecipeEntity> generateRecipe(String ingredients, String? notes);

  Future<RecipeEntity> extractIngredientsFromImage(Uint8List imageBytes);

  Future<Uint8List> generateRecipeImage(String ingredients, String? notes);

  Future<void> saveRecipe(SavedRecipeEntity recipe, Uint8List? imageBytes);
}
