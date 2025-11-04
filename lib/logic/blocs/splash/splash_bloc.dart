import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:meta/meta.dart';

part 'splash_event.dart';
part 'splash_state.dart';

class SplashBloc extends Bloc<SplashEvent, SplashState> {
SplashBloc(): super(const SplashState()){
on<StartSplash>(_onStarted);
}


Future<void> _onStarted(StartSplash event, Emitter<SplashState> emit)async{
  await Future.delayed(const Duration(seconds: 2));
  emit(state.copyWith(isLoaded: true));
}
}

