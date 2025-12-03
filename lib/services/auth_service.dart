import 'package:firebase_auth/firebase_auth.dart';

// Abstract base class defining the authentication service interface
// Allows for dependency injection and easier testing with mock implementations
abstract class AuthServiceBase {
  User? get currentUser;
  Stream<User?> get authStateChanges;
  Future<UserCredential?> signInWithEmail(String email, String password);
  Future<UserCredential?> registerWithEmail(String email, String password);
  Future<void> signOut();
}

// Concrete implementation of authentication service using Firebase Auth
// Handles user sign-in, registration, and session management
class AuthService implements AuthServiceBase {
  final FirebaseAuth _auth;

  // Constructor with optional dependency injection for testing
  AuthService({FirebaseAuth? auth}) : _auth = auth ?? FirebaseAuth.instance;

  // Get currently signed-in user (null if not authenticated)
  @override
  User? get currentUser => _auth.currentUser;

  // Stream of authentication state changes
  // Emits whenever user signs in or out
  @override
  Stream<User?> get authStateChanges => _auth.authStateChanges();

  // Sign in existing user with email and password
  // Returns UserCredential on success
  // Throws user-friendly error message on failure
  @override
  Future<UserCredential?> signInWithEmail(String email, String password) async {
    try {
      final userCredential = await _auth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );
      return userCredential;
    } on FirebaseAuthException catch (e) {
      // Convert Firebase error code to readable message
      throw _handleAuthException(e);
    }
  }

  // Register new user with email and password
  // Creates new account in Firebase Authentication
  // Returns UserCredential on success
  // Throws user-friendly error message on failure
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

  // Sign out current user
  // Clears authentication session
  @override
  Future<void> signOut() async {
    await _auth.signOut();
  }

  // Convert Firebase Auth exception codes to user-friendly error messages
  // Returns appropriate message based on error type
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
