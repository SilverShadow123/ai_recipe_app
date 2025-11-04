import 'package:ai_recipe_app/logic/blocs/splash/splash_bloc.dart';
import 'package:get_it/get_it.dart';

final GetIt locator = GetIt.instance;

void setupLocator(){
  locator.registerFactory<SplashBloc>(()=>SplashBloc());
}