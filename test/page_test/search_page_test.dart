// ignore_for_file: unused_import
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:fake_cloud_firestore/fake_cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import 'package:firebase_auth_mocks/firebase_auth_mocks.dart';
import 'package:union_shop/models/cart_model.dart';
import 'package:union_shop/services/auth_service.dart';
import 'package:union_shop/views/search_page.dart';

Widget buildRouterApp(Widget child) {
  final router = GoRouter(
    routes: [
      GoRoute(path: '/', builder: (context, state) => const Placeholder()),
      GoRoute(
          path: '/collections/:collection/products/:slug',
          builder: (context, state) => const Placeholder()),
      GoRoute(path: '/search', builder: (context, state) => child),
    ],
    initialLocation: '/search',
  );
  return MaterialApp.router(routerConfig: router);
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  late FakeFirebaseFirestore mockFirestore;
  late MockFirebaseAuth mockAuth;
  late AuthService authService;
  late CartModel cart;

  setUp(() {
    mockFirestore = FakeFirebaseFirestore();
    mockAuth = MockFirebaseAuth();
    authService = AuthService(auth: mockAuth);
    cart = CartModel(auth: mockAuth, firestore: mockFirestore);
  });

  Widget wrapWithProviders(Widget child) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider<CartModel>.value(value: cart),
        Provider<AuthService>.value(value: authService),
      ],
      child: buildRouterApp(child),
    );
  }

  group('SearchPage', () {
    testWidgets('shows prompt before searching', (tester) async {
      await tester
          .pumpWidget(wrapWithProviders(SearchPage(firestore: mockFirestore)));
      await tester.pumpAndSettle();

      expect(find.text('Enter a search term to find products'), findsOneWidget);
      expect(find.text('No products found matching your search'), findsNothing);
    });

    testWidgets('initialQuery triggers search and shows results count',
        (tester) async {
      await mockFirestore.collection('products').add({
        'title': 'Bear Tee',
        'image_url': 'assets/images/Bear.avif',
        'price': 12.5,
        'cat': 'Clothing',
        'coll': 'essential, apparel',
      });
      await mockFirestore.collection('products').add({
        'title': 'Mug',
        'image_url': 'assets/images/logo.avif',
        'price': 8.0,
        'cat': 'Merchandise',
        'coll': 'accessories',
      });

      await tester.pumpWidget(wrapWithProviders(SearchPage(
        firestore: mockFirestore,
        initialQuery: 'bear',
        fetchProducts: () => mockFirestore.collection('products').get(),
      )));

      // Allow async search to complete
      await tester.pumpAndSettle();
      // Results rendered
      expect(find.text('Bear Tee'), findsOneWidget);
      expect(find.text('Category: Clothing'), findsOneWidget);
      expect(find.text('£12.50'), findsOneWidget);
    });

    testWidgets('manual search shows no results message', (tester) async {
      await tester.pumpWidget(wrapWithProviders(SearchPage(
        firestore: mockFirestore,
        fetchProducts: () => mockFirestore.collection('products').get(),
      )));
      await tester.pumpAndSettle();

      await tester.enterText(find.byType(TextField).first, 'unknown');
      await tester.tap(find.widgetWithText(ElevatedButton, 'Search'));
      await tester.pump();

      // Finish async work
      await tester.pumpAndSettle();
      expect(
          find.text('No products found matching your search'), findsOneWidget);
    });

    testWidgets('discount price renders both current and original',
        (tester) async {
      await mockFirestore.collection('products').add({
        'title': 'Sale Hoodie',
        'image_url': 'assets/images/Bear.avif',
        'price': 25.0,
        'disc_price': 19.99,
        'cat': 'Clothing',
        'coll': 'sale, apparel',
      });

      await tester.pumpWidget(wrapWithProviders(SearchPage(
        firestore: mockFirestore,
        initialQuery: 'sale',
        fetchProducts: () => mockFirestore.collection('products').get(),
      )));

      await tester.pump();
      await tester.pumpAndSettle();

      expect(find.text('Sale Hoodie'), findsOneWidget);
      expect(find.text('£19.99'), findsOneWidget);
      expect(find.text('£25.00'), findsOneWidget);
    });

    testWidgets('tapping a result navigates to product route', (tester) async {
      await mockFirestore.collection('products').add({
        'title': 'Graduation Cap',
        'image_url': 'assets/images/logo.avif',
        'price': 30,
        'cat': 'Accessories',
        'coll': 'graduation',
      });

      await tester.pumpWidget(wrapWithProviders(SearchPage(
        firestore: mockFirestore,
        initialQuery: 'graduation',
        fetchProducts: () => mockFirestore.collection('products').get(),
      )));
      await tester.pump();
      await tester.pumpAndSettle();

      // Tap the result
      await tester.tap(find.text('Graduation Cap'));
      await tester.pumpAndSettle();

      // Landed on placeholder route
      expect(find.byType(Placeholder), findsOneWidget);
    });

    testWidgets('shows error snackbar on firestore failure', (tester) async {
      await tester.pumpWidget(wrapWithProviders(SearchPage(
        initialQuery: 'any',
        fetchProducts: () async => throw Exception('firestore error'),
      )));
      await tester.pump();
      await tester.pump();

      // Error snackbar should appear
      expect(find.byType(SnackBar), findsOneWidget);
      expect(find.textContaining('Error searching'), findsOneWidget);
    });
  });
}
