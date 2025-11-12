import 'package:ai_recipe_app/features/recipe/domain/entities/user_entity.dart';
import 'package:ai_recipe_app/features/recipe/domain/repositories/auth_repository.dart';

class SignInUsecase{
  final AuthRepo repo;

  SignInUsecase(this.repo);

  Future<UserEntity?> call(String email, String password) async{
    return await repo.signIn(email, password);
  }
}