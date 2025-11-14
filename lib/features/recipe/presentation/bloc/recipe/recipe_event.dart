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
