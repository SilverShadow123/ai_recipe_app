import 'dart:typed_data';
import 'package:equatable/equatable.dart';

abstract class RecipeEvent extends Equatable {
  const RecipeEvent();

  @override
  List<Object?> get props => [];
}

class GenerateRecipeEvent extends RecipeEvent {
  final String ingredients;
  final String notes;

  const GenerateRecipeEvent(this.ingredients, this.notes);

  @override
  List<Object?> get props => [ingredients, notes];
}

class ExtractIngredientsFromImageEvent extends RecipeEvent {
  final Uint8List imageBytes;

  const ExtractIngredientsFromImageEvent(this.imageBytes);

  @override
  List<Object?> get props => [imageBytes];
}

class SaveRecipeEvent extends RecipeEvent {
  final String ingredients;

  const SaveRecipeEvent(this.ingredients);

  @override
  List<Object?> get props => [ingredients];
}
