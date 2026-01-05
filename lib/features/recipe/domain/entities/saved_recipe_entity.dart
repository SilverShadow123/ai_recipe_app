class SavedRecipeEntity {
  final String id;
  final String recipeText;
  final String ingredients;
  final String? imagePath;
  final DateTime createdAt;

  const SavedRecipeEntity({
    required this.id,
    required this.recipeText,
    required this.ingredients,
    required this.createdAt,
    this.imagePath,
  });

  SavedRecipeEntity copyWith({
    String? imagePath,
  }) {
    return SavedRecipeEntity(
      id: id,
      recipeText: recipeText,
      ingredients: ingredients,
      createdAt: createdAt,
      imagePath: imagePath ?? this.imagePath,
    );
  }
}
