import 'package:ai_recipe_app/features/recipe/domain/repositories/auth_repository.dart';

class ResetPasswordUsecase{
  final AuthRepo repo;

  ResetPasswordUsecase(this.repo);

  Future<void> call(String email) async{
    return await repo.resetPassword(email);
  }
}