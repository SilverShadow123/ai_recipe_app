import 'package:equatable/equatable.dart';

class SplashEntity extends Equatable{
  final bool isLoggedIn;
  const SplashEntity({required this.isLoggedIn});

  @override
  List<Object?> get props => [isLoggedIn];
}