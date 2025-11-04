import 'package:ai_recipe_app/core/di/locator.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'app/app.dart';
import 'logic/blocs/splash/splash_bloc.dart';

void main() {
  setupLocator();
  WidgetsFlutterBinding.ensureInitialized();
  runApp(
    MultiBlocProvider(
      providers: [BlocProvider(create: (_) => locator<SplashBloc>())],
      child: const MyApp(),

    ),
  );
}
