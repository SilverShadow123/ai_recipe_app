import 'dart:typed_data';

import 'package:equatable/equatable.dart';

abstract class RecipeEvent extends Equatable {
  @override
  List<Object?> get props => [];
}

class GenerateRecipeEvent extends RecipeEvent {
  final String ingredients;
  final String notes;

  GenerateRecipeEvent(this.ingredients, this.notes);

  @override
  List<Object?> get props => [ingredients, notes];
}

class ExtractIngredientsFromImageEvent extends RecipeEvent {
  final Uint8List imageBytes;

  ExtractIngredientsFromImageEvent(this.imageBytes);

  @override
  List<Object?> get props => [imageBytes];
}


