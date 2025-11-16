import 'dart:typed_data';

import 'package:ai_recipe_app/features/recipe/data/datasources/recipe_ai_datasource.dart';
import 'package:ai_recipe_app/features/recipe/domain/entities/recipe_entity.dart';
import 'package:ai_recipe_app/features/recipe/domain/repositories/recipe_repository.dart';

class RecipeRepositoryImpl implements RecipeRepository {
  final RecipeAIDatasource datasource;

  RecipeRepositoryImpl(this.datasource);

  @override
  Future<RecipeEntity> generateRecipe(String ingredients, String? notes) async {
    final text = await datasource.generateRecipe(ingredients, notes);
    return RecipeEntity(text: text);
  }

  @override
  Future<RecipeEntity> extractIngredientsFromImage(Uint8List imageBytes) async {
    final ingredients = await datasource.extractIngredientsFromImage(imageBytes);
    return RecipeEntity(text: ingredients);
  }

  @override
  Future generateRecipeImage(String ingredients, String? notes) async {
final imageBytes = await datasource.generateRecipeImage(ingredients, notes);
    return imageBytes;
  }
}
