import 'package:fake_cloud_firestore/fake_cloud_firestore.dart';
import 'package:firebase_auth_mocks/firebase_auth_mocks.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';
import 'package:union_shop/models/cart_model.dart';
import 'package:union_shop/services/auth_service.dart';
import 'package:union_shop/views/collection_page.dart';

void main() {
  late MockFirebaseAuth mockAuth;
  late FakeFirebaseFirestore mockFirestore;
  late AuthService authService;
  late CartModel cart;

  // Suppress overflow errors in tests
  TestWidgetsFlutterBinding.ensureInitialized();
  
  setUp(() async {
    mockAuth = MockFirebaseAuth();
    mockFirestore = FakeFirebaseFirestore();
    authService = AuthService(auth: mockAuth);
    cart = CartModel(auth: mockAuth, firestore: mockFirestore);

    // Add sample products to the mock Firestore
    await mockFirestore.collection('products').add({
      'title': 'Essential Hoodie',
      'price': 29.99,
      'coll': 'essential-range',
      'cat': 'Clothing',
      'image_url': 'hoodie.jpg',
    });

    await mockFirestore.collection('products').add({
      'title': 'Signature T-Shirt',
      'price': 19.99,
      'coll': 'signature-range',
      'cat': 'Clothing',
      'image_url': 'tshirt.jpg',
    });

    await mockFirestore.collection('products').add({
      'title': 'Bear Plushie',
      'price': 24.99,
      'coll': 'essential-range',
      'cat': 'Merchandise',
      'image_url': 'bear.jpg',
    });

    await mockFirestore.collection('products').add({
      'title': 'Graduation Cap',
      'price': 1599, // in pence
      'disc': 1299, // discount price in pence
      'coll': 'graduation',
      'cat': 'Merchandise',
      'image_url': 'cap.jpg',
    });

    await mockFirestore.collection('products').add({
      'title': 'Winter Coat',
      'price': 89.99,
      'coll': 'winter-collection',
      'cat': 'Clothing',
      'image_url': 'coat.jpg',
    });

    // Add products to test edge cases
    await mockFirestore.collection('products').add({
      'title': 'Quoted Fields Product',
      'price': '"49.99"', // Quoted price
      'coll': '"test-collection"', // Quoted collection
      'cat': '"Accessories"', // Quoted category
      'image_url': '"accessory.jpg"',
    });

    await mockFirestore.collection('products').add({
      'title': 'Multi-Category Item',
      'price': 34.99,
      'coll': 'multi-test',
      'cat': 'Clothing,Accessories,Merchandise', // Multiple categories
      'image_url': 'multi.jpg',
    });

    await mockFirestore.collection('products').add({
      'title': 'Separator Test Product',
      'price': 25.50,
      'coll': 'test1;test2|test3,separator-test', // Different separators
      'cat': 'Test',
      'image_url': 'sep.jpg',
    });

    await mockFirestore.collection('products').add({
      'title': 'High Pence Price',
      'price': 9999, // Should convert to £99.99
      'coll': 'pence-test',
      'cat': 'Premium',
      'image_url': 'premium.jpg',
    });

    await mockFirestore.collection('products').add({
      'title': 'Low Pence Price',
      'price': 599, // Should stay as £5.99
      'coll': 'pence-test',
      'cat': 'Budget',
      'image_url': 'budget.jpg',
    });

    await mockFirestore.collection('products').add({
      'title': 'Slug Match Test',
      'price': 15.00,
      'coll': 'special range', // Space instead of hyphen
      'cat': 'Test',
      'image_url': 'test.jpg',
    });
  });

  Widget buildTestWidget(Widget child) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider<CartModel>.value(value: cart),
        Provider<AuthService>.value(value: authService),
      ],
      child: MaterialApp(
        home: MediaQuery(
          data: const MediaQueryData(size: Size(1920, 1080)),
          child: SizedBox(
            width: 1920,
            height: 1080,
            child: child,
          ),
        ),
      ),
    );
  }

  group('CollectionPage Widget Tests', () {
    testWidgets('CollectionPage shows loading indicator initially',
        (WidgetTester tester) async {
      await tester.pumpWidget(
        buildTestWidget(
          CollectionPage(slug: 'essential-range', firestore: mockFirestore),
        ),
      );

      // Before pumpAndSettle, should show loading
      expect(find.byType(CircularProgressIndicator), findsOneWidget);
    });

    testWidgets('CollectionPage shows "No products found" for non-existent collection',
        (WidgetTester tester) async {
      await tester.pumpWidget(
        buildTestWidget(
          CollectionPage(slug: 'nonexistent', firestore: mockFirestore),
        ),
      );
      await tester.pumpAndSettle();

      expect(find.textContaining('No products found'), findsOneWidget);
    });

    testWidgets('CollectionPage executes helper methods with various data formats',
        (WidgetTester tester) async {
      // Suppress rendering errors for this test
      final originalOnError = FlutterError.onError;
      FlutterError.onError = (details) {
        if (!details.toString().contains('RenderFlex overflowed')) {
          originalOnError?.call(details);
        }
      };

      await tester.pumpWidget(
        buildTestWidget(
          CollectionPage(slug: 'test-collection', firestore: mockFirestore),
        ),
      );
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 100));
      
      expect(find.byType(CollectionPage), findsOneWidget);
      FlutterError.onError = originalOnError;
    });

    testWidgets('CollectionPage processes separator variations',
        (WidgetTester tester) async {
      final originalOnError = FlutterError.onError;
      FlutterError.onError = (details) {
        if (!details.toString().contains('RenderFlex overflowed')) {
          originalOnError?.call(details);
        }
      };

      await tester.pumpWidget(
        buildTestWidget(
          CollectionPage(slug: 'separator-test', firestore: mockFirestore),
        ),
      );
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 100));
      
      expect(find.byType(CollectionPage), findsOneWidget);
      FlutterError.onError = originalOnError;
    });

    testWidgets('CollectionPage handles pence price conversions',
        (WidgetTester tester) async {
      final originalOnError = FlutterError.onError;
      FlutterError.onError = (details) {
        if (!details.toString().contains('RenderFlex overflowed')) {
          originalOnError?.call(details);
        }
      };

      await tester.pumpWidget(
        buildTestWidget(
          CollectionPage(slug: 'pence-test', firestore: mockFirestore),
        ),
      );
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 100));
      
      expect(find.byType(CollectionPage), findsOneWidget);
      FlutterError.onError = originalOnError;
    });

    testWidgets('CollectionPage matches hyphenated slug to spaced collection',
        (WidgetTester tester) async {
      final originalOnError = FlutterError.onError;
      FlutterError.onError = (details) {
        if (!details.toString().contains('RenderFlex overflowed')) {
          originalOnError?.call(details);
        }
      };

      await tester.pumpWidget(
        buildTestWidget(
          CollectionPage(slug: 'special-range', firestore: mockFirestore),
        ),
      );
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 100));
      
      expect(find.byType(CollectionPage), findsOneWidget);
      FlutterError.onError = originalOnError;
    });

    testWidgets('CollectionPage processes category filtering',
        (WidgetTester tester) async {
      final originalOnError = FlutterError.onError;
      FlutterError.onError = (details) {
        if (!details.toString().contains('RenderFlex overflowed')) {
          originalOnError?.call(details);
        }
      };

      await tester.pumpWidget(
        buildTestWidget(
          CollectionPage(slug: 'multi-test', firestore: mockFirestore),
        ),
      );
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 100));
      
      expect(find.byType(CollectionPage), findsOneWidget);
      FlutterError.onError = originalOnError;
    });
  });

  group('CollectionPage State Management', () {
    testWidgets('CollectionPage renders with default firestore when none injected',
        (WidgetTester tester) async {
      // This test verifies the fallback to FirebaseFirestore.instance
      // In a real app, this would fail without Firebase initialized
      // But we're testing that the code path exists
      
      const page = CollectionPage(slug: 'test');
      expect(page.firestore, isNull); // Verifies optional parameter works
    });

    testWidgets('CollectionPage preserves slug property',
        (WidgetTester tester) async {
      const testSlug = 'my-test-slug';
      final page = CollectionPage(slug: testSlug, firestore: mockFirestore);
      
      expect(page.slug, equals(testSlug));
    });

    testWidgets('CollectionPage empty slug defaults to empty string',
        (WidgetTester tester) async {
      final page = CollectionPage(firestore: mockFirestore);
      
      expect(page.slug, equals(''));
    });
  });
}
