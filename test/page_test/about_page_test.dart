import 'package:fake_cloud_firestore/fake_cloud_firestore.dart';
import 'package:firebase_auth_mocks/firebase_auth_mocks.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';
import 'package:union_shop/models/cart_model.dart';
import 'package:union_shop/services/auth_service.dart';
import 'package:union_shop/views/about_page.dart';
import 'package:union_shop/layout.dart' show AppHeader, AppFooter;

void main() {
  late MockFirebaseAuth mockAuth;
  late FakeFirebaseFirestore mockFirestore;
  late AuthService authService;
  late CartModel cart;

  TestWidgetsFlutterBinding.ensureInitialized();

  setUp(() {
    mockAuth = MockFirebaseAuth();
    mockFirestore = FakeFirebaseFirestore();
    authService = AuthService(auth: mockAuth);
    cart = CartModel(auth: mockAuth, firestore: mockFirestore);
  });

  testWidgets('AboutPage renders header, footer, heading and contact email',
      (WidgetTester tester) async {
    await tester.pumpWidget(
      MultiProvider(
        providers: [
          ChangeNotifierProvider<CartModel>.value(value: cart),
          Provider<AuthService>.value(value: authService),
        ],
        child: const MaterialApp(
          home: AboutPage(),
        ),
      ),
    );
    await tester.pumpAndSettle();

    // header and footer
    expect(find.byType(AppHeader), findsOneWidget);
    expect(find.byType(AppFooter), findsOneWidget);

    // main heading
    expect(find.text('About Us'), findsOneWidget);

    // body contains contact email
    final contactFinder = find.byWidgetPredicate((w) {
      if (w is Text) {
        final data = w.data ?? '';
        return data.contains('hello@upsu.net');
      }
      return false;
    }, description: 'Text widget containing contact email');
    expect(contactFinder, findsOneWidget);
  });
}
