import 'package:ai_recipe_app/features/recipe/data/datasources/firebase_auth_datasource.dart';
import 'package:ai_recipe_app/features/recipe/data/datasources/recipe_ai_datasource.dart';
import 'package:ai_recipe_app/features/recipe/data/repositories/auth_repository_impl.dart';
import 'package:ai_recipe_app/features/recipe/data/repositories/recipe_repository_impl.dart';
import 'package:ai_recipe_app/features/recipe/domain/repositories/auth_repository.dart';
import 'package:ai_recipe_app/features/recipe/domain/usecases/extract_ingredients_from_image_usecase.dart';
import 'package:ai_recipe_app/features/recipe/domain/usecases/generate_recipe_usecase.dart';
import 'package:ai_recipe_app/features/recipe/domain/usecases/get_current_user_usecase.dart';
import 'package:ai_recipe_app/features/recipe/domain/usecases/reset_password_usecase.dart';
import 'package:ai_recipe_app/features/recipe/domain/usecases/sign_in_usecase.dart';
import 'package:ai_recipe_app/features/recipe/domain/usecases/sign_in_with_google_usecase.dart';
import 'package:ai_recipe_app/features/recipe/domain/usecases/sign_out_usecase.dart';
import 'package:ai_recipe_app/features/recipe/domain/usecases/sign_up_usecase.dart';
import 'package:ai_recipe_app/features/recipe/presentation/bloc/auth/auth_bloc.dart';
import 'package:ai_recipe_app/features/recipe/presentation/bloc/recipe/recipe_bloc.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:get_it/get_it.dart';
import 'package:google_sign_in/google_sign_in.dart';

import 'features/recipe/domain/repositories/recipe_repository.dart';
import 'features/recipe/domain/usecases/generate_recipe_image_usecase.dart';


final sl = GetIt.instance;

Future<void> init() async {

  const serverClientId = '246230566041-f7teceqc5ar0kco9g5c5m0b83f1r0qrb.apps.googleusercontent.com';
  final googleSignIn = GoogleSignIn.instance;
  await googleSignIn.initialize(serverClientId: serverClientId);

  sl.registerLazySingleton<FirebaseAuth>(() => FirebaseAuth.instance);
  sl.registerLazySingleton<GoogleSignIn>(() => googleSignIn);
  sl.registerLazySingleton(() => FirebaseAuthDatasource(sl(), sl()));
  sl.registerLazySingleton<AuthRepo>(
    () => AuthRepositoryImpl(sl<FirebaseAuthDatasource>()),
  );
  sl.registerLazySingleton(() => GetCurrentUserUseCase(sl()));
  sl.registerLazySingleton(() => SignInUsecase(sl()));
  sl.registerLazySingleton(() => SignUpUsecase(sl()));
  sl.registerLazySingleton(() => SignInWithGoogleUsecase(sl()));
  sl.registerLazySingleton(() => SignOutUsecase(sl()));
  sl.registerLazySingleton(() => ResetPasswordUsecase(sl()));
  sl.registerLazySingleton(()=>RecipeAIDatasource());
  sl.registerLazySingleton<RecipeRepository>(() => RecipeRepositoryImpl(sl()));
  sl.registerLazySingleton(()=>GenereateRecipeUseCase(sl()));
  sl.registerLazySingleton(()=>ExtractIngredientsFromImageUsecase(sl()));
  sl.registerLazySingleton(()=>GenerateRecipeImageUsecase(sl()));
  sl.registerLazySingleton(() => RecipeBloc(sl(), sl(), sl()));

  sl.registerFactory(
    () => AuthBloc(
      getCurrentUserUseCase: sl(),
      signInUsecase: sl(),
      signUpUsecase: sl(),
      signInWithGoogleUsecase: sl(),
      signOutUsecase: sl(),
      resetPasswordUsecase: sl(),
    ),
  );

}
