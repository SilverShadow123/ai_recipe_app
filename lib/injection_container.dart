

import 'package:ai_recipe_app/features/recipe/data/datasources/splash_local_datasource.dart';
import 'package:ai_recipe_app/features/recipe/data/repositories/splash_repository_impl.dart';
import 'package:ai_recipe_app/features/recipe/domain/usecases/check_logged_in.dart';
import 'package:ai_recipe_app/features/recipe/presentation/bloc/splash/splash_bloc.dart';
import 'package:get_it/get_it.dart';

import 'features/recipe/domain/repositories/splash_repository.dart';

final sl = GetIt.instance;
Future<void> init() async{
 sl.registerFactory(()=> SplashBloc(sl()));
 sl.registerLazySingleton(() => CheckUserLoggedIn(sl()));
 sl.registerLazySingleton<SplashRepository>(() =>SplashRepositoryImpl(sl()));
 sl.registerLazySingleton(()=> SplashLocalDataSource());
}