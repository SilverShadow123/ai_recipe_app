import '../entities/splash_entity.dart';
import '../repositories/splash_repository.dart';

class CheckUserLoggedIn{
  final SplashRepository repository;
  CheckUserLoggedIn(this.repository);

  Future<SplashEntity> call() async {
    return await repository.checkUserLoggedIn();

  }
}