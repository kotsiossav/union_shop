import 'package:firebase_auth/firebase_auth.dart';

abstract class AuthServiceBase {
  User? get currentUser;
  Stream<User?> get authStateChanges;
  Future<UserCredential?> signInWithEmail(String email, String password);
  Future<UserCredential?> registerWithEmail(String email, String password);
  Future<void> signOut();
}

class AuthService implements AuthServiceBase {
  final FirebaseAuth _auth;

  AuthService({FirebaseAuth? auth}) : _auth = auth ?? FirebaseAuth.instance;

  // Get current user
  @override
  User? get currentUser => _auth.currentUser;

  // Auth state changes stream
  @override
  Stream<User?> get authStateChanges => _auth.authStateChanges();

  // Sign in with email and password
  @override
  Future<UserCredential?> signInWithEmail(String email, String password) async {
    try {
      final userCredential = await _auth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );
      return userCredential;
    } on FirebaseAuthException catch (e) {
      throw _handleAuthException(e);
    }
  }

  // Register with email and password
  @override
  Future<UserCredential?> registerWithEmail(
      String email, String password) async {
    try {
      final userCredential = await _auth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );
      return userCredential;
    } on FirebaseAuthException catch (e) {
      throw _handleAuthException(e);
    }
  }

  // Sign out
  @override
  Future<void> signOut() async {
    await _auth.signOut();
  }

  // Handle Firebase Auth exceptions
  String _handleAuthException(FirebaseAuthException e) {
    switch (e.code) {
      case 'user-not-found':
        return 'No user found with this email.';
      case 'wrong-password':
        return 'Wrong password provided.';
      case 'email-already-in-use':
        return 'An account already exists with this email.';
      case 'invalid-email':
        return 'The email address is not valid.';
      case 'weak-password':
        return 'The password is too weak.';
      case 'operation-not-allowed':
        return 'Email/password accounts are not enabled.';
      default:
        return 'An error occurred. Please try again.';
    }
  }
}
