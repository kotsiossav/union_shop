import 'package:fake_cloud_firestore/fake_cloud_firestore.dart';
import 'package:firebase_auth_mocks/firebase_auth_mocks.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';
import 'package:union_shop/layout.dart';
import 'package:union_shop/models/cart_model.dart';
import 'package:union_shop/services/auth_service.dart';
import 'package:union_shop/views/print_shack/print-shack_about.dart';

void main() {
  late FakeFirebaseFirestore fakeFirestore;
  late MockFirebaseAuth mockAuth;
  late AuthService authService;
  late CartModel cartModel;

  setUp(() {
    fakeFirestore = FakeFirebaseFirestore();
    mockAuth = MockFirebaseAuth(signedIn: false);
    authService = AuthService(auth: mockAuth);
    cartModel = CartModel(auth: mockAuth, firestore: fakeFirestore);
  });

  Widget createTestWidget(Widget child) {
    return MultiProvider(
      providers: [
        Provider<AuthService>.value(value: authService),
        ChangeNotifierProvider<CartModel>.value(value: cartModel),
      ],
      child: MaterialApp(home: child),
    );
  }

  group('PrintShackAbout Widget Rendering', () {
    testWidgets('renders with AppBar containing title',
        (WidgetTester tester) async {
      await tester.pumpWidget(createTestWidget(const PrintShackAbout()));

      expect(find.byType(AppBar), findsOneWidget);
      expect(find.widgetWithText(AppBar, 'Print Shack'), findsOneWidget);
    });

    testWidgets('displays AppHeader', (WidgetTester tester) async {
      await tester.pumpWidget(createTestWidget(const PrintShackAbout()));

      expect(find.byType(AppHeader), findsOneWidget);
    });

    testWidgets('displays AppFooter', (WidgetTester tester) async {
      await tester.pumpWidget(createTestWidget(const PrintShackAbout()));

      expect(find.byType(AppFooter), findsOneWidget);
    });

    testWidgets('displays main heading', (WidgetTester tester) async {
      await tester.pumpWidget(createTestWidget(const PrintShackAbout()));

      expect(
          find.text('Make It Yours at The Union Print Shack'), findsOneWidget);
    });

    testWidgets('displays all section headings', (WidgetTester tester) async {
      await tester.pumpWidget(createTestWidget(const PrintShackAbout()));

      expect(find.text('Uni Gear or Your Gear - We\'ll Personalise It'),
          findsOneWidget);
      expect(find.text('Simple Pricing, No Surprises'), findsOneWidget);
      expect(find.text('Personalisation Terms & Conditions'), findsOneWidget);
      expect(find.text('Ready to Make It Yours?'), findsOneWidget);
    });

    testWidgets('displays pricing information', (WidgetTester tester) async {
      await tester.pumpWidget(createTestWidget(const PrintShackAbout()));

      expect(find.textContaining('£3'), findsOneWidget);
      expect(find.textContaining('£5'), findsOneWidget);
      expect(find.textContaining('one line of text'), findsOneWidget);
      expect(find.textContaining('small chest logo'), findsOneWidget);
    });

    testWidgets('displays service features', (WidgetTester tester) async {
      await tester.pumpWidget(createTestWidget(const PrintShackAbout()));

      expect(find.textContaining('heat-pressed customisation'), findsOneWidget);
      expect(find.textContaining('uni-branded clothing'), findsOneWidget);
      expect(find.textContaining('three working days'), findsOneWidget);
    });

    testWidgets('displays terms and conditions', (WidgetTester tester) async {
      await tester.pumpWidget(createTestWidget(const PrintShackAbout()));

      expect(find.textContaining('not responsible for any spelling errors'),
          findsOneWidget);
      expect(find.textContaining('Refunds are not provided'), findsOneWidget);
    });

    testWidgets('content is scrollable', (WidgetTester tester) async {
      await tester.pumpWidget(createTestWidget(const PrintShackAbout()));

      expect(find.byType(SingleChildScrollView), findsOneWidget);
    });

    testWidgets('uses proper layout structure', (WidgetTester tester) async {
      await tester.pumpWidget(createTestWidget(const PrintShackAbout()));

      expect(find.byType(Scaffold), findsOneWidget);
      expect(find.byType(Column), findsWidgets);
      expect(find.byType(Expanded), findsAtLeastNWidgets(1));
    });

    testWidgets('all text content is visible', (WidgetTester tester) async {
      await tester.pumpWidget(createTestWidget(const PrintShackAbout()));

      // Main heading
      expect(
          find.text('Make It Yours at The Union Print Shack'), findsOneWidget);

      // Call to action
      expect(
          find.textContaining('Pop in or get in touch today'), findsOneWidget);
      expect(find.textContaining('The Union Print Shack'), findsWidgets);
    });

    testWidgets('displays proper spacing with SizedBox widgets',
        (WidgetTester tester) async {
      await tester.pumpWidget(createTestWidget(const PrintShackAbout()));

      expect(find.byType(SizedBox), findsWidgets);
    });
  });
}
