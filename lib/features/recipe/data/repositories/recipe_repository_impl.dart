import 'dart:typed_data';
import 'package:ai_recipe_app/features/recipe/data/datasources/recipe_ai_datasource.dart';
import 'package:ai_recipe_app/features/recipe/data/datasources/local_image_datasource.dart';
import 'package:ai_recipe_app/features/recipe/data/repositories/recipe_firebase_datasource.dart';
import 'package:ai_recipe_app/features/recipe/domain/entities/recipe_entity.dart';
import 'package:ai_recipe_app/features/recipe/domain/entities/saved_recipe_entity.dart';
import 'package:ai_recipe_app/features/recipe/domain/repositories/recipe_repository.dart';

class RecipeRepositoryImpl implements RecipeRepository {
  final RecipeAIDatasource aiDatasource;
  final RecipeFirestoreDatasource firestoreDatasource;
  final LocalImageDatasource localImageDatasource;

  RecipeRepositoryImpl({
    required this.aiDatasource,
    required this.firestoreDatasource,
    required this.localImageDatasource,
  });

  @override
  Future<RecipeEntity> generateRecipe(String ingredients, String? notes) async {
    final text = await aiDatasource.generateRecipe(ingredients, notes);
    return RecipeEntity(text: text);
  }

  @override
  Future<RecipeEntity> extractIngredientsFromImage(Uint8List imageBytes) async {
    final ingredients = await aiDatasource.extractIngredientsFromImage(imageBytes);
    return RecipeEntity(text: ingredients);
  }

  @override
  Future<Uint8List> generateRecipeImage(String ingredients, String? notes) async {
    return await aiDatasource.generateRecipeImage(ingredients, notes);
  }

  @override
  Future<void> saveRecipe(SavedRecipeEntity recipe, Uint8List? imageBytes) async {
    String? localPath;

    if (imageBytes != null) {
      localPath = await localImageDatasource.saveImage(recipe.id, imageBytes);
    }

    final savedRecipeWithPath = recipe.copyWith(imagePath: localPath);
    await firestoreDatasource.saveRecipe(savedRecipeWithPath);
  }
}
