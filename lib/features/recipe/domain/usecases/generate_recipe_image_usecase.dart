import 'package:ai_recipe_app/features/recipe/domain/repositories/recipe_repository.dart';

class GenerateRecipeImageUsecase{
  final RecipeRepository repository;
  GenerateRecipeImageUsecase(this.repository);
  Future call(String ingredients, String? notes) {
    return repository.generateRecipeImage(ingredients, notes);
  }
}