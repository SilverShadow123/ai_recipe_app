import 'package:ai_recipe_app/features/recipe/domain/usecases/check_logged_in.dart';
import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';

part 'splash_event.dart';

part 'splash_state.dart';

class SplashBloc extends Bloc<SplashEvent, SplashState> {
  final CheckUserLoggedIn checkUserLoggedIn;

  SplashBloc(this.checkUserLoggedIn) : super(const SplashState()) {
    on<CheckLoginStatusEvent>(_onCheckLoginStatus);
  }

  Future<void> _onCheckLoginStatus(
    CheckLoginStatusEvent event,
    Emitter<SplashState> emit,
  ) async {
    emit(state.copyWith(isLoading: true, errorMessage: null));

    try {
      final result = await checkUserLoggedIn();
      emit(state.copyWith(isLoading: false, isLoggedIn: result.isLoggedIn));
    } catch (e) {
      emit(state.copyWith(isLoading: false, errorMessage: e.toString()));
    }
  }
}
