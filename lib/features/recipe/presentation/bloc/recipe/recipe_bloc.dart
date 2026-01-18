import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../domain/entities/saved_recipe_entity.dart';
import '../../../domain/usecases/extract_ingredients_from_image_usecase.dart';
import '../../../domain/usecases/generate_recipe_image_usecase.dart';
import '../../../domain/usecases/generate_recipe_usecase.dart';
import '../../../domain/usecases/save_recipe_usecase.dart';
import 'recipe_event.dart';
import 'recipe_state.dart';

class RecipeBloc extends Bloc<RecipeEvent, RecipeState> {
  final GenereateRecipeUseCase generateRecipe;
  final ExtractIngredientsFromImageUsecase extractIngredients;
  final GenerateRecipeImageUsecase generateRecipeImage;
  final SaveRecipeUseCase saveRecipe;

  RecipeBloc({
    required this.generateRecipe,
    required this.extractIngredients,
    required this.generateRecipeImage,
    required this.saveRecipe,
  }) : super(const RecipeState()) {
    on<GenerateRecipeEvent>(_onGenerateRecipe);
    on<ExtractIngredientsFromImageEvent>(_onExtractIngredientsFromImage);
    on<SaveRecipeEvent>(_onSaveRecipe);
  }

  Future<void> _onGenerateRecipe(
      GenerateRecipeEvent event, Emitter<RecipeState> emit) async {
    if (event.ingredients.isEmpty) {
      emit(state.copyWith(error: "Please enter ingredients."));
      return;
    }

    emit(state.copyWith(
      isGenerating: true,
      isGeneratingImage: true,
      error: "",
      recipeText: "",
      saveSuccess: false,
    ));

    try {
      // Generate recipe text
      final recipe = await generateRecipe(event.ingredients, event.notes);

      emit(state.copyWith(
        recipeText: recipe.text,
        isGenerating: false,
      ));

      // Generate recipe image
      try {
        final imageBytes =
        await generateRecipeImage(event.ingredients, event.notes);
        emit(state.copyWith(
          imageBytes: imageBytes,
          isGeneratingImage: false,
        ));
      } catch (imageError) {
        debugPrint('Image generation failed: $imageError');
        emit(state.copyWith(
          isGeneratingImage: false,
          error: 'Recipe generated, but image generation failed',
        ));
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
      Emitter<RecipeState> emit) async {
    emit(state.copyWith(
      isExtracting: true,
      error: "",
      extractedIngredients: "",
    ));

    try {
      final ingredients = await extractIngredients(event.imageBytes);
      emit(state.copyWith(
        isExtracting: false,
        extractedIngredients: ingredients.text,
      ));
    } catch (e) {
      emit(state.copyWith(
        isExtracting: false,
        error: e.toString(),
      ));
    }
  }

  Future<void> _onSaveRecipe(
      SaveRecipeEvent event, Emitter<RecipeState> emit) async {
    if (state.recipeText.isEmpty) {
      emit(state.copyWith(error: 'No recipe to save'));
      return;
    }

    emit(state.copyWith(
      isSaving: true,
      saveSuccess: false,
      error: "",
    ));

    try {
      // Convert RecipeEntity -> SavedRecipeEntity
      final savedRecipe = SavedRecipeEntity(
        id: DateTime.now().millisecondsSinceEpoch.toString(),
        recipeText: state.recipeText,
        ingredients: event.ingredients,
        createdAt: DateTime.now(),
      );

      // Repository handles saving locally for image and Firestore for text
      await saveRecipe(
        savedRecipe,
        state.imageBytes,
      );

      emit(state.copyWith(
        isSaving: false,
        saveSuccess: true,
      ));
    } catch (e) {
      emit(state.copyWith(
        isSaving: false,
        error: e.toString(),
      ));
    }
  }
}
