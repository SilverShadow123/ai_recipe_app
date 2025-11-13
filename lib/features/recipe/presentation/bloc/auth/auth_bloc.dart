import 'package:ai_recipe_app/features/recipe/domain/entities/user_entity.dart';
import 'package:ai_recipe_app/features/recipe/domain/usecases/get_current_user_usecase.dart';
import 'package:ai_recipe_app/features/recipe/domain/usecases/reset_password_usecase.dart';
import 'package:ai_recipe_app/features/recipe/domain/usecases/sign_in_usecase.dart';
import 'package:ai_recipe_app/features/recipe/domain/usecases/sign_out_usecase.dart';
import 'package:ai_recipe_app/features/recipe/domain/usecases/sign_up_usecase.dart';
import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';

part 'auth_event.dart';

part 'auth_state.dart';

class AuthBloc extends Bloc<AuthEvent, AuthState> {
  final GetCurrentUserUseCase getCurrentUserUseCase;
  final SignInUsecase signInUsecase;
  final SignUpUsecase signUpUsecase;
  final SignOutUsecase signOutUsecase;
  final ResetPasswordUsecase resetPasswordUsecase;

  AuthBloc({
    required this.getCurrentUserUseCase,
    required this.signInUsecase,
    required this.signUpUsecase,
    required this.signOutUsecase,
    required this.resetPasswordUsecase,
  }) : super(AuthInitial()) {
on<LoadCurrentUserEvent>(_loadCurrentUser);
on<SignInEvent>(_signIn);
on<SignUpEvent>(_signUp);
on<SignOutEvent>(_signOut);
on<ResetPasswordEvent>(_resetPassword);

  }

  Future<void> _loadCurrentUser(
    LoadCurrentUserEvent event,
    Emitter<AuthState> emit,
  ) async {
    try{
      final user = await getCurrentUserUseCase();
      if(user != null){
        emit(AuthAuthenticated(user));
      }else{
        emit(AuthUnauthenticated());
      }
    }catch(e){
      emit(AuthError('Failed to get current user'));
    }
  }


  Future<void> _signIn(
    SignInEvent event,
    Emitter<AuthState> emit,
  ) async {
    try{
      final user = await signInUsecase(event.email, event.password);
      if(user != null){
        emit(AuthAuthenticated(user));
      }else{
        emit(AuthError('Failed to sign in'));
      }
    }catch(e){
      emit(AuthError('Sign in error: ${e.toString()}'));
    }

  }
  Future<void> _signUp(
    SignUpEvent event,
    Emitter<AuthState> emit,
  ) async {
    try{
      final user = await signUpUsecase(event.email, event.password, event.name);
      if(user != null){
        emit(AuthAuthenticated(user));
      }else{
        emit(AuthError('Failed to sign up'));
      }
    }catch(e){
      emit(AuthError('Sign up error: ${e.toString()}'));
    }
  }

  Future<void> _signOut(
    SignOutEvent event,
    Emitter<AuthState> emit,
  ) async {
    try {
      await signOutUsecase();
    } catch (e) {
      emit(AuthError('Sign out error: ${e.toString()}'));
    }
  }

  Future<void> _resetPassword(
    ResetPasswordEvent event,
    Emitter<AuthState> emit,
  ) async {
    try{
      await resetPasswordUsecase(event.email);
    }catch(e){
      emit(AuthError('Reset password error: ${e.toString()}'));
    }
  }

}
