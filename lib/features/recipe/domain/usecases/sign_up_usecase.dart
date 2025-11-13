import 'package:ai_recipe_app/features/recipe/domain/entities/user_entity.dart';
import 'package:ai_recipe_app/features/recipe/domain/repositories/auth_repository.dart';

class SignUpUsecase{
  final AuthRepo repo;

  SignUpUsecase(this.repo);

  Future<UserEntity?> call(String email, String password, String name) async{
    return await repo.signUp(email, password, name);
  }
}