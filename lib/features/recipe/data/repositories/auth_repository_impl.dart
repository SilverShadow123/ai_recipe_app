import 'package:ai_recipe_app/features/recipe/data/datasources/firebase_auth_datasource.dart';
import 'package:ai_recipe_app/features/recipe/data/models/user_model.dart';
import 'package:ai_recipe_app/features/recipe/domain/entities/user_entity.dart';
import 'package:ai_recipe_app/features/recipe/domain/repositories/auth_repository.dart';

class AuthRepositoryImpl implements AuthRepo {
  final FirebaseAuthDatasource datasource;

  AuthRepositoryImpl(this.datasource);

  @override
  Future<UserEntity?> getCurrentUser() async {
    final user = datasource.getCurrentUser();
    if (user != null) {
      return UserModel.fromFirebaseUser(user);
    }
    return null;
  }

  @override
  Future<UserEntity?> signIn(String email, String password) async {
    final user = await datasource.signIn(email, password);
    if (user != null) {
      return UserModel.fromFirebaseUser(user);
    }
    return null;
  }

  @override
  Future<UserEntity?> signUp(String email, String password) async {
    final user = await datasource.signUp(email, password);
    if (user != null) {
      return UserModel.fromFirebaseUser(user);
    }
    return null;
  }

  @override
  Future<void> signOut() async {
    await datasource.signOut();
  }

  @override
  Future<void> resetPassword(String email) async{
    await datasource.sendPasswordResetEmail(email);
  }
}
