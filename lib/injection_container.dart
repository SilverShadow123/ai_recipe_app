import 'package:ai_recipe_app/features/recipe/data/datasources/firebase_auth_datasource.dart';
import 'package:ai_recipe_app/features/recipe/data/repositories/auth_repository_impl.dart';
import 'package:ai_recipe_app/features/recipe/domain/repositories/auth_repository.dart';
import 'package:ai_recipe_app/features/recipe/domain/usecases/get_current_user_usecase.dart';
import 'package:ai_recipe_app/features/recipe/domain/usecases/reset_password_usecase.dart';
import 'package:ai_recipe_app/features/recipe/domain/usecases/sign_in_usecase.dart';
import 'package:ai_recipe_app/features/recipe/domain/usecases/sign_up_usecase.dart';
import 'package:ai_recipe_app/features/recipe/presentation/bloc/auth/auth_bloc.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:get_it/get_it.dart';


final sl = GetIt.instance;

Future<void> init() async {

  sl.registerLazySingleton<FirebaseAuth>(() => FirebaseAuth.instance);
  sl.registerLazySingleton(() => FirebaseAuthDatasource(sl()));
  sl.registerLazySingleton<AuthRepo>(
    () => AuthRepositoryImpl(sl<FirebaseAuthDatasource>()),
  );
  sl.registerLazySingleton(() => GetCurrentUserUseCase(sl()));
  sl.registerLazySingleton(() => SignInUsecase(sl()));
  sl.registerLazySingleton(() => SignUpUsecase(sl()));
  sl.registerLazySingleton(() => SignUpUsecase(sl()));
  sl.registerLazySingleton(() => ResetPasswordUsecase(sl()));
  sl.registerFactory(
    () => AuthBloc(
      getCurrentUserUseCase: sl(),
      signInUsecase: sl(),
      signUpUsecase: sl(),
      signOutUsecase: sl(),
      resetPasswordUsecase: sl(),
    ),
  );

}
