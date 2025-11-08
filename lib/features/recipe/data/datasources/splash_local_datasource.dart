class SplashLocalDataSource {
  Future<bool> isUserLoggedIn() async{
    await Future.delayed(const Duration(seconds: 2));
    return false;
  }
}