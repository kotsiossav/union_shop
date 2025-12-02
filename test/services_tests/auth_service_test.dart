import 'package:flutter_test/flutter_test.dart';
import 'package:union_shop/services/auth_service.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_auth_mocks/firebase_auth_mocks.dart';

void main() {
  group('AuthService', () {
    late MockFirebaseAuth mockAuth;
    late AuthService authService;

    setUp(() {
      mockAuth = MockFirebaseAuth();
      authService = AuthService(auth: mockAuth);
    });

    group('Initialization', () {
      test('should create AuthService with custom FirebaseAuth instance', () {
        final service = AuthService(auth: mockAuth);
        expect(service, isNotNull);
      });
    });

    group('Current User', () {
      test('should return null when no user is signed in', () {
        expect(authService.currentUser, isNull);
      });

      test('should return current user when signed in', () async {
        await mockAuth.signInWithCustomToken('token');

        expect(authService.currentUser, isNotNull);
        expect(authService.currentUser?.uid, isNotEmpty);
      });
    });

    group('Auth State Changes', () {
      test('should provide auth state changes stream', () {
        expect(authService.authStateChanges, isA<Stream<User?>>());
      });

      test('should emit null when user signs out', () async {
        // Sign in first
        await mockAuth.signInWithCustomToken('token');

        // Sign out
        await authService.signOut();

        // Check the auth state
        final user = await authService.authStateChanges.first;
        expect(user, isNull);
      });

      test('should emit user when signed in', () async {
        await mockAuth.signInWithCustomToken('token');

        // Wait a bit for the stream to emit
        await Future.delayed(const Duration(milliseconds: 50));

        final user = authService.currentUser;
        expect(user, isNotNull);
      });
    });

    group('Sign In with Email', () {
      test('should sign in successfully with valid credentials', () async {
        const email = 'test@example.com';
        const password = 'password123';

        // Create a user first
        await mockAuth.createUserWithEmailAndPassword(
          email: email,
          password: password,
        );

        // Sign out
        await mockAuth.signOut();

        // Sign in
        final result = await authService.signInWithEmail(email, password);

        expect(result, isNotNull);
        expect(result?.user, isNotNull);
        expect(authService.currentUser, isNotNull);
      });

      test('should return UserCredential on successful sign in', () async {
        const email = 'user@example.com';
        const password = 'validPassword';

        // Create user
        await mockAuth.createUserWithEmailAndPassword(
          email: email,
          password: password,
        );
        await mockAuth.signOut();

        final credential = await authService.signInWithEmail(email, password);

        expect(credential, isA<UserCredential>());
        expect(credential?.user?.email, email);
      });

      test('should sign in with any credentials in mock environment', () async {
        const email = 'any@example.com';
        const password = 'anyPassword';

        // MockFirebaseAuth allows any sign in
        final result = await authService.signInWithEmail(email, password);

        expect(result, isNotNull);
        expect(result?.user, isNotNull);
      });
    });

    group('Register with Email', () {
      test('should register successfully with valid email and password',
          () async {
        const email = 'newuser@example.com';
        const password = 'securePassword123';

        final result = await authService.registerWithEmail(email, password);

        expect(result, isNotNull);
        expect(result?.user, isNotNull);
        expect(authService.currentUser, isNotNull);
      });

      test('should return UserCredential on successful registration', () async {
        const email = 'register@example.com';
        const password = 'strongPass123';

        final credential = await authService.registerWithEmail(email, password);

        expect(credential, isA<UserCredential>());
        expect(credential?.user?.email, email);
      });

      test('should set current user after registration', () async {
        const email = 'current@example.com';
        const password = 'password123';

        await authService.registerWithEmail(email, password);

        expect(authService.currentUser, isNotNull);
        expect(authService.currentUser?.email, email);
      });

      test('should allow registration with various email formats in mock',
          () async {
        const email = 'test+tag@example.co.uk';
        const password = 'password123';

        final result = await authService.registerWithEmail(email, password);

        expect(result, isNotNull);
        expect(result?.user?.email, email);
      });
    });

    group('Sign Out', () {
      test('should sign out successfully', () async {
        // Sign in first
        await mockAuth.createUserWithEmailAndPassword(
          email: 'test@example.com',
          password: 'password',
        );

        expect(authService.currentUser, isNotNull);

        // Sign out
        await authService.signOut();

        expect(authService.currentUser, isNull);
      });

      test('should clear current user on sign out', () async {
        const email = 'signout@example.com';
        const password = 'password123';

        await authService.registerWithEmail(email, password);
        expect(authService.currentUser, isNotNull);

        await authService.signOut();
        expect(authService.currentUser, isNull);
      });

      test('should not throw error when signing out while already signed out',
          () async {
        expect(authService.currentUser, isNull);

        expect(() => authService.signOut(), returnsNormally);
      });

      test('should complete successfully', () async {
        await mockAuth.createUserWithEmailAndPassword(
          email: 'user@example.com',
          password: 'pass',
        );

        final signOutFuture = authService.signOut();

        expect(signOutFuture, completes);
      });
    });

    group('Service Methods', () {
      test('should handle authentication operations without errors', () async {
        const email = 'service@example.com';
        const password = 'password123';

        // All operations should complete successfully with mock
        final registerResult =
            await authService.registerWithEmail(email, password);
        expect(registerResult, isNotNull);

        await authService.signOut();
        expect(authService.currentUser, isNull);

        final signInResult = await authService.signInWithEmail(email, password);
        expect(signInResult, isNotNull);
      });
    });

    group('Integration Tests', () {
      test('should complete full registration and sign out flow', () async {
        const email = 'fullflow@example.com';
        const password = 'password123';

        // Register
        final registerResult =
            await authService.registerWithEmail(email, password);
        expect(registerResult?.user, isNotNull);
        expect(authService.currentUser, isNotNull);

        // Sign out
        await authService.signOut();
        expect(authService.currentUser, isNull);
      });

      test('should complete registration, sign out, and sign in flow',
          () async {
        const email = 'complete@example.com';
        const password = 'securePass123';

        // Register
        await authService.registerWithEmail(email, password);
        expect(authService.currentUser, isNotNull);

        // Sign out
        await authService.signOut();
        expect(authService.currentUser, isNull);

        // Sign in
        await authService.signInWithEmail(email, password);
        expect(authService.currentUser, isNotNull);
      });

      test('should handle multiple users sequentially', () async {
        const user1Email = 'user1@example.com';
        const user1Password = 'pass1';
        const user2Email = 'user2@example.com';
        const user2Password = 'pass2';

        // Register user 1
        await authService.registerWithEmail(user1Email, user1Password);
        expect(authService.currentUser, isNotNull);

        // Sign out
        await authService.signOut();
        expect(authService.currentUser, isNull);

        // Register user 2
        await authService.registerWithEmail(user2Email, user2Password);
        expect(authService.currentUser, isNotNull);

        // Verify we can sign out again
        await authService.signOut();
        expect(authService.currentUser, isNull);
      });

      test('should maintain auth state through stream', () async {
        const email = 'stream@example.com';
        const password = 'password';

        final states = <User?>[];
        final subscription = authService.authStateChanges.listen((user) {
          states.add(user);
        });

        // Register
        await authService.registerWithEmail(email, password);
        await Future.delayed(const Duration(milliseconds: 100));

        // Sign out
        await authService.signOut();
        await Future.delayed(const Duration(milliseconds: 100));

        // Sign in
        await authService.signInWithEmail(email, password);
        await Future.delayed(const Duration(milliseconds: 100));

        await subscription.cancel();

        // Should have received multiple state updates
        expect(states.length, greaterThan(0));
      });
    });

    group('Edge Cases', () {
      test('should handle email with special characters', () async {
        const email = 'test+tag@example.co.uk';
        const password = 'password123';

        final result = await authService.registerWithEmail(email, password);
        expect(result?.user, isNotNull);
      });

      test('should handle password with special characters', () async {
        const email = 'special@example.com';
        const password = 'P@ssw0rd!#\$%';

        final result = await authService.registerWithEmail(email, password);
        expect(result?.user, isNotNull);
      });

      test('should handle very long email', () async {
        final longEmail = '${'a' * 100}@example.com';
        const password = 'password123';

        final result = await authService.registerWithEmail(longEmail, password);
        expect(result?.user, isNotNull);
      });
    });
  });
}

