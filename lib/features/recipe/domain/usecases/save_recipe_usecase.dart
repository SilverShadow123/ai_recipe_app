import 'dart:typed_data';
import '../entities/saved_recipe_entity.dart';
import '../repositories/recipe_repository.dart';

class SaveRecipeUseCase {
  final RecipeRepository repository;

  SaveRecipeUseCase(this.repository);

  Future<void> call(
      SavedRecipeEntity recipe,
      Uint8List? imageBytes,
      ) {
    return repository.saveRecipe(recipe, imageBytes);
  }
}
