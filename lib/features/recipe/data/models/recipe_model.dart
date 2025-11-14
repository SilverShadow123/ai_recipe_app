import '../../domain/entities/recipe_entity.dart';

class RecipeModel extends RecipeEntity{
  const RecipeModel({required super.text});

  factory RecipeModel.fromText(String text){
    return RecipeModel(text: text);
  }

}
