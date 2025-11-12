import 'package:ai_recipe_app/features/recipe/domain/repositories/auth_repository.dart';

class SignOutUsecase{
  final AuthRepo repo;

  SignOutUsecase(this.repo);

  Future<void> call() async{
    return await repo.signOut();
  }
}