import 'package:firebase_auth/firebase_auth.dart';

class FirebaseAuthDatasource{
  final FirebaseAuth _firebaseAuth;

  FirebaseAuthDatasource(this._firebaseAuth);

  User? getCurrentUser(){
    return _firebaseAuth.currentUser;
  }

  Future<User?> signIn(String email, String password) async{
    final result = await _firebaseAuth.signInWithEmailAndPassword(email: email, password: password);
    return result.user;
  }  Future<User?> signUp(String email, String password, String name) async{
    final result = await _firebaseAuth.createUserWithEmailAndPassword(email: email, password: password,);
    await result.user?.updateDisplayName(name);
    await result.user?.reload();
    final updateUser = _firebaseAuth.currentUser;
    return updateUser;
  }

  Future<void> signOut() async{
    await _firebaseAuth.signOut();
  }

  Future<void> sendPasswordResetEmail(String email) async{
    await _firebaseAuth.sendPasswordResetEmail(email: email);
  }

}