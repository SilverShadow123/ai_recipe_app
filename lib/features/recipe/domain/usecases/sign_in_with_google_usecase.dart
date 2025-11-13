import 'package:ai_recipe_app/features/recipe/domain/entities/user_entity.dart';
import 'package:ai_recipe_app/features/recipe/domain/repositories/auth_repository.dart';

class SignInWithGoogleUsecase {
  final AuthRepo repo;

  SignInWithGoogleUsecase(this.repo);

  Future<UserEntity?> call() async {
    return await repo.signInWithGoogle();
  }
}
