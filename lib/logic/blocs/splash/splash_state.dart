part of 'splash_bloc.dart';

class SplashState extends Equatable {
  final bool isLoaded;

  const SplashState({this.isLoaded = false});

  SplashState copyWith({bool? isLoaded}) {
    return SplashState(isLoaded: isLoaded ?? this.isLoaded);
  }

  @override
  List<Object?> get props => [isLoaded];
}
