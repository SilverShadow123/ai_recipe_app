import 'package:ai_recipe_app/features/recipe/domain/entities/user_entity.dart';

abstract class AuthRepo{
  Future<UserEntity?> getCurrentUser();
  Future<UserEntity?> signIn(String email, String password);
  Future<UserEntity?> signUp(String email, String password, String name);
  Future<UserEntity?> signInWithGoogle();
  Future<void> signOut();
  Future<void> resetPassword(String email);
}