part of 'splash_bloc.dart';

class SplashState extends Equatable{
  final bool isLoading;
  final bool? isLoggedIn;
  final String? errorMessage;


  const SplashState({this.isLoading = false, this.isLoggedIn, this.errorMessage});

  SplashState copyWith({bool? isLoading, bool? isLoggedIn, String? errorMessage}){
    return SplashState(
      isLoading: isLoading ?? this.isLoading,
      isLoggedIn: isLoggedIn ?? this.isLoggedIn,
      errorMessage: errorMessage ?? this.errorMessage,
    );
  }

  @override
  List<Object?> get props => [isLoading, isLoggedIn, errorMessage];

}
