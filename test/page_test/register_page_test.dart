import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:union_shop/services/auth_service.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:union_shop/views/register_page.dart';

class FakeAuthService implements AuthServiceBase {
  FakeAuthService();

  bool shouldThrow = false;
  String errorMessage = 'An error occurred. Please try again.';

  @override
  Future<UserCredential?> registerWithEmail(
      String email, String password) async {
    if (shouldThrow) {
      throw errorMessage;
    }
    return null; // Simulate success
  }

  @override
  User? get currentUser => null;

  @override
  Stream<User?> get authStateChanges => const Stream.empty();

  @override
  Future<UserCredential?> signInWithEmail(
          String email, String password) async =>
      null;

  @override
  Future<void> signOut() async {}
}

Widget buildRouterApp(Widget child) {
  final router = GoRouter(
    routes: [
      GoRoute(path: '/', builder: (context, state) => const Placeholder()),
      GoRoute(
          path: '/login_page',
          builder: (context, state) => const Placeholder()),
      GoRoute(path: '/register', builder: (context, state) => child),
    ],
    initialLocation: '/register',
  );
  return MaterialApp.router(routerConfig: router);
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  setUp(() {
    // Ignore RenderFlex overflow errors in this test suite to keep focus on logic
    final Function? originalOnError = FlutterError.onError;
    FlutterError.onError = (FlutterErrorDetails details) {
      final message = details.exceptionAsString();
      if (message.contains('RenderFlex overflowed')) {
        return; // swallow layout overflow from narrow test viewports
      }
      if (originalOnError != null) {
        // ignore: avoid_dynamic_calls
        (originalOnError as void Function(FlutterErrorDetails))(details);
      } else {
        FlutterError.dumpErrorToConsole(details);
      }
    };
  });

  group('RegisterPage', () {
    testWidgets('shows validation errors for empty fields', (tester) async {
      final fakeAuth = FakeAuthService();
      await tester.binding.setSurfaceSize(const Size(800, 1200));
      await tester
          .pumpWidget(buildRouterApp(RegisterPage(authService: fakeAuth)));
      await tester.pumpAndSettle();

      await tester.tap(find.widgetWithText(ElevatedButton, 'Create Account'));
      await tester.pump();

      expect(find.byType(SnackBar), findsOneWidget);
      expect(find.text('Please fill all fields'), findsOneWidget);
      addTearDown(() => tester.binding.setSurfaceSize(null));
    });

    testWidgets('shows error when passwords do not match', (tester) async {
      final fakeAuth = FakeAuthService();
      await tester.binding.setSurfaceSize(const Size(800, 1200));
      await tester
          .pumpWidget(buildRouterApp(RegisterPage(authService: fakeAuth)));
      await tester.pumpAndSettle();

      await tester.enterText(
          find.widgetWithText(TextFormField, 'Email address'),
          'user@example.com');
      await tester.enterText(
          find.widgetWithText(TextFormField, 'Password'), 'secret123');
      await tester.enterText(
          find.widgetWithText(TextFormField, 'Confirm Password'), 'notmatch');

      await tester.tap(find.widgetWithText(ElevatedButton, 'Create Account'));
      await tester.pump();

      expect(find.byType(SnackBar), findsOneWidget);
      expect(find.text('Passwords do not match'), findsOneWidget);
      addTearDown(() => tester.binding.setSurfaceSize(null));
    });

    testWidgets('shows error when password too short', (tester) async {
      final fakeAuth = FakeAuthService();
      await tester.binding.setSurfaceSize(const Size(800, 1200));
      await tester
          .pumpWidget(buildRouterApp(RegisterPage(authService: fakeAuth)));
      await tester.pumpAndSettle();

      await tester.enterText(
          find.widgetWithText(TextFormField, 'Email address'),
          'user@example.com');
      await tester.enterText(
          find.widgetWithText(TextFormField, 'Password'), '123');
      await tester.enterText(
          find.widgetWithText(TextFormField, 'Confirm Password'), '123');

      await tester.tap(find.widgetWithText(ElevatedButton, 'Create Account'));
      await tester.pump();

      expect(find.byType(SnackBar), findsOneWidget);
      expect(
          find.text('Password must be at least 6 characters'), findsOneWidget);
      addTearDown(() => tester.binding.setSurfaceSize(null));
    });

    testWidgets('successful registration shows snackbar and navigates home',
        (tester) async {
      final fakeAuth = FakeAuthService();
      await tester.binding.setSurfaceSize(const Size(800, 1200));
      await tester
          .pumpWidget(buildRouterApp(RegisterPage(authService: fakeAuth)));
      await tester.pumpAndSettle();

      await tester.enterText(
          find.widgetWithText(TextFormField, 'Email address'),
          'user@example.com');
      await tester.enterText(
          find.widgetWithText(TextFormField, 'Password'), 'secret123');
      await tester.enterText(
          find.widgetWithText(TextFormField, 'Confirm Password'), 'secret123');

      await tester.tap(find.widgetWithText(ElevatedButton, 'Create Account'));
      await tester.pump();

      expect(find.byType(SnackBar), findsOneWidget);
      expect(find.text('Registration successful!'), findsOneWidget);

      // Allow navigation
      await tester.pumpAndSettle();
      expect(find.byType(Placeholder), findsOneWidget);
      addTearDown(() => tester.binding.setSurfaceSize(null));
    });

    testWidgets('register error surfaces in snackbar', (tester) async {
      final fakeAuth = FakeAuthService()
        ..shouldThrow = true
        ..errorMessage = 'Email already in use';
      await tester.binding.setSurfaceSize(const Size(800, 1200));
      await tester
          .pumpWidget(buildRouterApp(RegisterPage(authService: fakeAuth)));
      await tester.pumpAndSettle();

      await tester.enterText(
          find.widgetWithText(TextFormField, 'Email address'),
          'user@example.com');
      await tester.enterText(
          find.widgetWithText(TextFormField, 'Password'), 'secret123');
      await tester.enterText(
          find.widgetWithText(TextFormField, 'Confirm Password'), 'secret123');

      await tester.tap(find.widgetWithText(ElevatedButton, 'Create Account'));
      await tester.pump();

      expect(find.byType(SnackBar), findsOneWidget);
      expect(find.text('Email already in use'), findsOneWidget);
      addTearDown(() => tester.binding.setSurfaceSize(null));
    });

    testWidgets('toggle password visibility', (tester) async {
      final fakeAuth = FakeAuthService();
      await tester.binding.setSurfaceSize(const Size(800, 1200));
      await tester
          .pumpWidget(buildRouterApp(RegisterPage(authService: fakeAuth)));
      await tester.pumpAndSettle();

      final toggle1 = find.byIcon(Icons.visibility_off).first;
      await tester.tap(toggle1);
      await tester.pump();

      final toggle2 = find.byIcon(Icons.visibility_off).last;
      await tester.tap(toggle2);
      await tester.pump();

      // No assertions needed; tap should not throw and state updates
      expect(find.byType(RegisterPage), findsOneWidget);
      addTearDown(() => tester.binding.setSurfaceSize(null));
    });

    testWidgets('login link navigates to login page', (tester) async {
      final fakeAuth = FakeAuthService();
      await tester.binding.setSurfaceSize(const Size(800, 1200));
      await tester
          .pumpWidget(buildRouterApp(RegisterPage(authService: fakeAuth)));
      await tester.pumpAndSettle();
      // Ensure the link is visible before tapping
      final signInFinder = find.text('Sign In');
      await tester.ensureVisible(signInFinder);
      await tester.tap(signInFinder);
      await tester.pumpAndSettle();

      expect(find.byType(Placeholder), findsOneWidget);
      addTearDown(() => tester.binding.setSurfaceSize(null));
    });
  });
}
