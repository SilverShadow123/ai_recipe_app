import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../domain/usecases/generate_recipe_usecase.dart';
import 'recipe_event.dart';
import 'recipe_state.dart';

class RecipeBloc extends Bloc<RecipeEvent, RecipeState> {
  final GenereateRecipeUseCase generateRecipe;

  RecipeBloc(this.generateRecipe) : super(const RecipeState()) {
    on<GenerateRecipeEvent>(_onGenerateRecipe);
  }

  Future<void> _onGenerateRecipe(
      GenerateRecipeEvent event,
      Emitter<RecipeState> emit,
      ) async {
    if (event.ingredients.isEmpty) {
      emit(state.copyWith(error: "Please enter ingredients."));
      return;
    }

    emit(state.copyWith(isLoading: true, error: "", recipeText: ""));

    try {
      final recipe = await generateRecipe(event.ingredients, event.notes);
      emit(state.copyWith(isLoading: false, recipeText: recipe.text));
    } catch (e) {
      emit(state.copyWith(isLoading: false, error: e.toString()));
    }
  }
}
