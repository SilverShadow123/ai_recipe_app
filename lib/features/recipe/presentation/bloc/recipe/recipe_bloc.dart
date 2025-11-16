import 'package:ai_recipe_app/features/recipe/domain/usecases/generate_recipe_image_usecase.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../domain/usecases/extract_ingredients_from_image_usecase.dart';
import '../../../domain/usecases/generate_recipe_usecase.dart';
import 'recipe_event.dart';
import 'recipe_state.dart';

class RecipeBloc extends Bloc<RecipeEvent, RecipeState> {
  final GenereateRecipeUseCase generateRecipe;
  final ExtractIngredientsFromImageUsecase extractIngredients;
  final GenerateRecipeImageUsecase generateRecipeImage;

  RecipeBloc(
    this.generateRecipe,
    this.extractIngredients,
    this.generateRecipeImage,
  ) : super(const RecipeState()) {
    on<GenerateRecipeEvent>(_onGenerateRecipe);
    on<ExtractIngredientsFromImageEvent>(_onExtractIngredientsFromImage);
  }

  Future<void> _onGenerateRecipe(
    GenerateRecipeEvent event,
    Emitter<RecipeState> emit,
  ) async {
    if (event.ingredients.isEmpty) {
      emit(state.copyWith(error: "Please enter ingredients."));
      return;
    }

    // Start loading state
    emit(
      state.copyWith(
        isGenerating: true,
        isGeneratingImage: true,
        error: "",
        recipeText: "",
      ),
    );

    try {
      // Generate recipe text
      final recipe = await generateRecipe(event.ingredients, event.notes);
      
      // Update state with recipe text
      emit(
        state.copyWith(
          recipeText: recipe.text,
          isGenerating: false, // Text generation complete
        ),
      );

      // Generate recipe image
      try {
        final imageBytes = await generateRecipeImage(event.ingredients, event.notes);
        emit(
          state.copyWith(
            imageBytes: imageBytes,
            isGeneratingImage: false, // Image generation complete
          ),
        );
      } catch (imageError) {
        // If image generation fails, just log it and continue
        debugPrint('Image generation failed: $imageError');
        emit(
          state.copyWith(
            isGeneratingImage: false,
            error: 'Recipe generated, but image generation failed'
          ),
        );
      }
    } catch (e) {
      emit(state.copyWith(
        isGenerating: false,
        isGeneratingImage: false,
        error: e.toString(),
      ));
    }
  }

  Future<void> _onExtractIngredientsFromImage(
    ExtractIngredientsFromImageEvent event,
    Emitter<RecipeState> emit,
  ) async {
    emit(
      state.copyWith(
        isExtracting: true,
        error: "",
        extractedIngredients: "",
      ),
    );

    try {
      final ingredients = await extractIngredients(event.imageBytes);
      emit(
        state.copyWith(
          isExtracting: false,
          extractedIngredients: ingredients.text,
        ),
      );
    } catch (e) {
      emit(state.copyWith(
        isExtracting: false,
        error: e.toString(),
      ));
    }
  }
}
