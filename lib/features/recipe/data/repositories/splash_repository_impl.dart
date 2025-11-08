import 'package:ai_recipe_app/features/recipe/data/datasources/splash_local_datasource.dart';
import 'package:ai_recipe_app/features/recipe/domain/entities/splash_entity.dart';

import '../../domain/repositories/splash_repository.dart';

class SplashRepositoryImpl implements SplashRepository{
  final SplashLocalDataSource localDataSource;
  SplashRepositoryImpl(this.localDataSource);
  @override
  Future<SplashEntity> checkUserLoggedIn() async{
    final loggedIn = await localDataSource.isUserLoggedIn();
    return SplashEntity(isLoggedIn: loggedIn);
  }

}