import 'package:ai_recipe_app/features/recipe/domain/entities/recipe_entity.dart';

abstract class RecipeRepository{
  Future<RecipeEntity> generateRecipe(String ingredients, String? notes);
}