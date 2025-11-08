import 'package:ai_recipe_app/features/recipe/domain/entities/splash_entity.dart';

abstract class SplashRepository{
  Future<SplashEntity> checkUserLoggedIn();
}