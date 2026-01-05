import 'dart:typed_data';
import 'package:equatable/equatable.dart';

class RecipeState extends Equatable {
  final bool isGenerating;
  final bool isExtracting;
  final bool isGeneratingImage;
  final bool isSaving;
  final bool saveSuccess;
  final String recipeText;
  final String extractedIngredients;
  final String error;
  final Uint8List? imageBytes;

  const RecipeState({
    this.isGenerating = false,
    this.isExtracting = false,
    this.isGeneratingImage = false,
    this.isSaving = false,
    this.saveSuccess = false,
    this.recipeText = "",
    this.extractedIngredients = "",
    this.error = "",
    this.imageBytes,
  });

  RecipeState copyWith({
    bool? isGenerating,
    bool? isExtracting,
    bool? isGeneratingImage,
    bool? isSaving,
    bool? saveSuccess,
    String? recipeText,
    String? extractedIngredients,
    String? error,
    Uint8List? imageBytes,
  }) {
    return RecipeState(
      isGenerating: isGenerating ?? this.isGenerating,
      isExtracting: isExtracting ?? this.isExtracting,
      isGeneratingImage: isGeneratingImage ?? this.isGeneratingImage,
      isSaving: isSaving ?? this.isSaving,
      saveSuccess: saveSuccess ?? this.saveSuccess,
      recipeText: recipeText ?? this.recipeText,
      extractedIngredients: extractedIngredients ?? this.extractedIngredients,
      error: error ?? this.error,
      imageBytes: imageBytes ?? this.imageBytes,
    );
  }

  @override
  List<Object?> get props => [
    isGenerating,
    isExtracting,
    isGeneratingImage,
    isSaving,
    saveSuccess,
    recipeText,
    extractedIngredients,
    error,
    imageBytes,
  ];
}
