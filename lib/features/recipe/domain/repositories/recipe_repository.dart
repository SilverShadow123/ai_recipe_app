import 'dart:typed_data';
import 'dart:async';

import 'package:ai_recipe_app/features/recipe/domain/entities/recipe_entity.dart';
import 'package:flutter/foundation.dart';

abstract class RecipeRepository {
  Future<RecipeEntity> generateRecipe(String ingredients, String? notes);
  Future<RecipeEntity> extractIngredientsFromImage(Uint8List imageBytes);
  Future generateRecipeImage(String ingredients, String? notes);
}