import 'package:ai_recipe_app/features/recipe/domain/entities/recipe_entity.dart';
import 'package:ai_recipe_app/features/recipe/domain/repositories/recipe_repository.dart';

class GenereateRecipeUseCase {
  final RecipeRepository repository;
  GenereateRecipeUseCase(this.repository);

  Future<RecipeEntity> call(String ingredients, String? notes) {
    return repository.generateRecipe(ingredients, notes);
  }
}