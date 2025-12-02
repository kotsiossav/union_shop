import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:union_shop/views/sign_in_page.dart';
import 'package:union_shop/services/auth_service.dart';
import 'package:firebase_auth_mocks/firebase_auth_mocks.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  late MockFirebaseAuth mockAuth;
  late AuthService authService;

  setUp(() {
    mockAuth = MockFirebaseAuth(signedIn: false);
    authService = AuthService(auth: mockAuth);
  });

  group('SignInPage UI Elements', () {
    testWidgets('shows logo image at top', (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: SignInPage(authService: authService),
        ),
      );
      await tester.pumpAndSettle();

      // Logo present
      final images = tester.widgetList<Image>(find.byType(Image));
      final hasLogoAsset = images.any((img) {
        final provider = img.image;
        return provider is AssetImage &&
            provider.assetName.contains('logo2.png');
      });
      expect(hasLogoAsset, isTrue);
    });

    testWidgets('shows Sign in heading', (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: SignInPage(authService: authService),
        ),
      );
      await tester.pumpAndSettle();

      expect(find.text('Sign in'), findsOneWidget);
    });

    testWidgets('shows email and password fields', (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: SignInPage(authService: authService),
        ),
      );
      await tester.pumpAndSettle();

      expect(
          find.widgetWithText(TextFormField, 'Email address'), findsOneWidget);
      expect(find.widgetWithText(TextFormField, 'Password'), findsOneWidget);
    });

    testWidgets('shows Sign In button', (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: SignInPage(authService: authService),
        ),
      );
      await tester.pumpAndSettle();

      expect(find.widgetWithText(ElevatedButton, 'Sign In'), findsOneWidget);
    });

    testWidgets('has password visibility toggle', (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: SignInPage(authService: authService),
        ),
      );
      await tester.pumpAndSettle();

      expect(find.byIcon(Icons.visibility_off), findsOneWidget);
    });
  });

  group('SignInPage Interactions', () {
    testWidgets('can enter email and password', (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: SignInPage(authService: authService),
        ),
      );
      await tester.pumpAndSettle();

      await tester.enterText(
        find.widgetWithText(TextFormField, 'Email address'),
        'test@example.com',
      );
      await tester.enterText(
        find.widgetWithText(TextFormField, 'Password'),
        'password123',
      );
      await tester.pumpAndSettle();

      expect(find.text('test@example.com'), findsOneWidget);
      expect(find.text('password123'), findsOneWidget);
    });

    testWidgets('sign in button is enabled when not loading',
        (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: SignInPage(authService: authService),
        ),
      );
      await tester.pumpAndSettle();

      final buttonFinder = find.widgetWithText(ElevatedButton, 'Sign In');
      final button = tester.widget<ElevatedButton>(buttonFinder);

      expect(button.onPressed, isNotNull);
    });
  });

  group('SignInPage Styling', () {
    testWidgets('has correct background color', (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: SignInPage(authService: authService),
        ),
      );
      await tester.pumpAndSettle();

      final scaffold = tester.widget<Scaffold>(find.byType(Scaffold));
      expect(scaffold.backgroundColor, Colors.grey[100]);
    });

    testWidgets('button has correct colors', (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: SignInPage(authService: authService),
        ),
      );
      await tester.pumpAndSettle();

      final button = tester.widget<ElevatedButton>(
        find.widgetWithText(ElevatedButton, 'Sign In'),
      );

      final style = button.style!;
      expect(
        style.backgroundColor?.resolve({}),
        const Color(0xFF4d2963),
      );
      expect(
        style.foregroundColor?.resolve({}),
        Colors.white,
      );
    });
  });
}
