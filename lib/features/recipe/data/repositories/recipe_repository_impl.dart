import 'package:ai_recipe_app/features/recipe/data/datasources/recipe_ai_datasource.dart';
import 'package:ai_recipe_app/features/recipe/data/models/recipe_model.dart';
import 'package:ai_recipe_app/features/recipe/domain/entities/recipe_entity.dart';
import 'package:ai_recipe_app/features/recipe/domain/repositories/recipe_repository.dart';

class RecipeRepositoryImpl implements RecipeRepository {
  final RecipeAIDatasource datasource;

  RecipeRepositoryImpl(this.datasource);

  @override
  Future<RecipeEntity> generateRecipe(String ingredients, String? notes) async {
    final text = await datasource.generateRecipe(ingredients, notes);
    return RecipeModel.fromText(text);
  }
}
