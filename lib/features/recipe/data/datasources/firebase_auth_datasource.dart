import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';

class FirebaseAuthDatasource {
  final FirebaseAuth _firebaseAuth;
  final GoogleSignIn _googleSignIn;

  FirebaseAuthDatasource(this._firebaseAuth, this._googleSignIn);

  User? getCurrentUser() {
    return _firebaseAuth.currentUser;
  }

  Future<User?> signIn(String email, String password) async {
    final result = await _firebaseAuth.signInWithEmailAndPassword(
      email: email,
      password: password,
    );
    return result.user;
  }

  Future<User?> signUp(String email, String password, String name) async {
    final result = await _firebaseAuth.createUserWithEmailAndPassword(
      email: email,
      password: password,
    );
    await result.user?.updateDisplayName(name);
    await result.user?.reload();
    final updateUser = _firebaseAuth.currentUser;
    return updateUser;
  }

  Future<User?> signInWithGoogle() async {
    if (!_googleSignIn.supportsAuthenticate()) {
      throw UnsupportedError(
        'Google Sign-In authenticate() not supported on this platform',
      );
    }

    final account = await _googleSignIn.authenticate();

    final googleAuth = account.authentication;

    final credential = GoogleAuthProvider.credential(
      idToken: googleAuth.idToken,
    );

    final userCredential = await _firebaseAuth.signInWithCredential(credential);
    return userCredential.user;
  }

  Future<void> signOut() async {
    await _firebaseAuth.signOut();
    await _googleSignIn.signOut();
  }

  Future<void> sendPasswordResetEmail(String email) async {
    await _firebaseAuth.sendPasswordResetEmail(email: email);
  }
}
