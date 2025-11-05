import 'package:get_it/get_it.dart';

import '../../features/splash/presentation/bloc/splash_bloc.dart';

final GetIt locator = GetIt.instance;

void setupLocator(){
  locator.registerFactory<SplashBloc>(()=>SplashBloc());
}