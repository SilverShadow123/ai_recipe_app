import 'dart:typed_data';

import 'package:equatable/equatable.dart';

class RecipeState extends Equatable {
  final bool isGenerating;
  final bool isExtracting;
  final bool isGeneratingImage;
  final String recipeText;
  final String extractedIngredients;
  final String error;
  final Uint8List? imageBytes;

  const RecipeState(
   {
     this.isGeneratingImage=false,
     this.imageBytes,
     this.isGenerating = false,
    this.isExtracting = false,
    this.recipeText = "",
    this.extractedIngredients = "",
    this.error = "",
  });

  RecipeState copyWith({
    bool? isGenerating,
    bool? isExtracting,
    bool? isGeneratingImage,
    String? recipeText,
    String? extractedIngredients,
    String? error,
    Uint8List? imageBytes,
  }) {
    return RecipeState(
      isGenerating: isGenerating ?? this.isGenerating,
      isGeneratingImage: isGeneratingImage ?? this.isGeneratingImage,
      imageBytes: imageBytes ?? this.imageBytes,
      isExtracting: isExtracting ?? this.isExtracting,
      recipeText: recipeText ?? this.recipeText,
      extractedIngredients: extractedIngredients ?? this.extractedIngredients,
      error: error ?? this.error,
    );
  }

  @override
  List<Object?> get props => [
    isGenerating,
    isGeneratingImage,
    imageBytes,
    isExtracting,
    recipeText,
    extractedIngredients,
    error,
  ];
}
