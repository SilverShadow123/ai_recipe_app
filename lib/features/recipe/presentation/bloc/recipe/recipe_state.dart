import 'package:equatable/equatable.dart';

class RecipeState extends Equatable {
  final bool isLoading;
  final String recipeText;
  final String error;

  const RecipeState({
    this.isLoading = false,
    this.recipeText = "",
    this.error = "",
  });

  RecipeState copyWith({
    bool? isLoading,
    String? recipeText,
    String? error,
  }) {
    return RecipeState(
      isLoading: isLoading ?? this.isLoading,
      recipeText: recipeText ?? this.recipeText,
      error: error ?? this.error,
    );
  }

  @override
  List<Object?> get props => [isLoading, recipeText, error];
}
