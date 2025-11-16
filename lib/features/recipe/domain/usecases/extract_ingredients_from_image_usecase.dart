import 'dart:typed_data';
import 'dart:async';

import 'package:ai_recipe_app/features/recipe/domain/repositories/recipe_repository.dart';
import 'package:flutter/foundation.dart';

import '../entities/recipe_entity.dart';


class ExtractIngredientsFromImageUsecase {
  final RecipeRepository repository;
  ExtractIngredientsFromImageUsecase(this.repository);
  
  Future<RecipeEntity> call(Uint8List imageBytes) {
    return repository.extractIngredientsFromImage(imageBytes);
  }
}