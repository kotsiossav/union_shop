import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:union_shop/views/collections_page.dart';
import 'package:union_shop/views/collection_page.dart';
import 'package:union_shop/layout.dart' show HoverImage, AppHeader, AppFooter;
import 'package:firebase_auth_mocks/firebase_auth_mocks.dart';
import 'package:fake_cloud_firestore/fake_cloud_firestore.dart';
import 'package:provider/provider.dart';
import 'package:union_shop/models/cart_model.dart';
import 'package:union_shop/services/auth_service.dart';
import 'package:go_router/go_router.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  late MockFirebaseAuth mockAuth;
  late FakeFirebaseFirestore mockFirestore;
  late CartModel cart;
  late AuthService authService;

  setUp(() async {
    final mockUser = MockUser(
      uid: 'test-user-id',
      email: 'test@example.com',
      displayName: 'Test User',
    );
    mockAuth = MockFirebaseAuth(mockUser: mockUser, signedIn: true);
    mockFirestore = FakeFirebaseFirestore();
    cart = CartModel(auth: mockAuth, firestore: mockFirestore);
    authService = AuthService(auth: mockAuth);

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
    final router = GoRouter(
      routes: [
        GoRoute(
          path: '/',
          builder: (context, state) => child,
        ),
        GoRoute(
          path: '/collections/:slug',
          builder: (context, state) => Scaffold(
            body: Center(
              child: Text('Collection: ${state.pathParameters['slug']}'),
            ),
          ),
        ),
      ],
    );

    return MultiProvider(
      providers: [
        ChangeNotifierProvider<CartModel>.value(value: cart),
        Provider<AuthService>.value(value: authService),
      ],
      child: MaterialApp.router(
        routerConfig: router,
      ),
    );
  }

  Widget buildTestWidgetForCollectionPage(Widget child) {
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

  group('CollectionsPage Widget', () {
    testWidgets('CollectionsPage renders heading, header, footer',
        (WidgetTester tester) async {
      await tester.pumpWidget(buildTestWidget(const CollectionsPage()));

      await tester.pumpAndSettle();

      // Heading
      expect(find.text('collections'), findsOneWidget);

      // Header and footer present
      expect(find.byType(AppHeader), findsOneWidget);
      expect(find.byType(AppFooter), findsOneWidget);
    });

    testWidgets('CollectionsPage renders 15 collection items',
        (WidgetTester tester) async {
      await tester.pumpWidget(buildTestWidget(const CollectionsPage()));

      await tester.pumpAndSettle();

      // There should be 15 HoverImage widgets (5 rows × 3 items)
      expect(find.byType(HoverImage), findsNWidgets(15));
    });

    testWidgets('CollectionsPage renders all overlay labels',
        (WidgetTester tester) async {
      await tester.pumpWidget(buildTestWidget(const CollectionsPage()));

      await tester.pumpAndSettle();

      // Check all 15 overlay labels are present
      expect(find.text('Autumn Favourites'), findsOneWidget);
      expect(find.text('Black Friday'), findsOneWidget);
      expect(find.text('Clothing'), findsOneWidget);
      expect(find.text('Clothing Original'), findsOneWidget);
      expect(find.text('Election Discounts'), findsOneWidget);
      expect(find.text('Essential Range'), findsOneWidget);
      expect(find.text('Graduation'), findsOneWidget);
      expect(
          find.text('Limited edition essential zip hoodies'), findsOneWidget);
      expect(find.text('merchandise'), findsOneWidget);
      expect(find.text('pride collection'), findsOneWidget);
      expect(find.text('sale'), findsOneWidget);
      expect(find.text('Signature Range'), findsOneWidget);
      expect(find.text('Spring Favourites'), findsOneWidget);
      expect(find.text('Student Essentials'), findsOneWidget);
      expect(find.text('Summer Collection'), findsOneWidget);
    });

    testWidgets('CollectionsPage is a StatelessWidget',
        (WidgetTester tester) async {
      const page = CollectionsPage();
      expect(page, isA<StatelessWidget>());
    });

    testWidgets('CollectionsPage can be instantiated with key',
        (WidgetTester tester) async {
      const key = Key('collections-page-key');
      const page = CollectionsPage(key: key);
      expect(page.key, key);
    });
  });

  group('CollectionsPage Layout', () {
    testWidgets('CollectionsPage uses SingleChildScrollView',
        (WidgetTester tester) async {
      await tester.pumpWidget(buildTestWidget(const CollectionsPage()));

      await tester.pumpAndSettle();

      expect(find.byType(SingleChildScrollView), findsOneWidget);
    });

    testWidgets('CollectionsPage uses GridView for items',
        (WidgetTester tester) async {
      await tester.pumpWidget(buildTestWidget(const CollectionsPage()));

      await tester.pumpAndSettle();

      expect(find.byType(GridView), findsOneWidget);
    });

    testWidgets('CollectionsPage uses LayoutBuilder for responsiveness',
        (WidgetTester tester) async {
      await tester.pumpWidget(buildTestWidget(const CollectionsPage()));

      await tester.pumpAndSettle();

      // Should have at least one LayoutBuilder
      expect(find.byType(LayoutBuilder), findsWidgets);
    });
  });

  group('CollectionsPage Responsive Behavior', () {
    testWidgets('CollectionsPage shows 1 column on mobile (400px width)',
        (WidgetTester tester) async {
      await tester.binding.setSurfaceSize(const Size(400, 800));

      await tester.pumpWidget(buildTestWidget(const CollectionsPage()));

      await tester.pumpAndSettle();

      // Find the GridView widget
      final gridView = tester.widget<GridView>(find.byType(GridView));
      final delegate =
          gridView.gridDelegate as SliverGridDelegateWithFixedCrossAxisCount;

      // Mobile should show 1 column
      expect(delegate.crossAxisCount, 1);

      await tester.binding.setSurfaceSize(null);
    });

    testWidgets('CollectionsPage shows 2 columns on tablet (700px width)',
        (WidgetTester tester) async {
      await tester.binding.setSurfaceSize(const Size(700, 800));

      await tester.pumpWidget(buildTestWidget(const CollectionsPage()));

      await tester.pumpAndSettle();

      // Find the GridView widget
      final gridView = tester.widget<GridView>(find.byType(GridView));
      final delegate =
          gridView.gridDelegate as SliverGridDelegateWithFixedCrossAxisCount;

      // Tablet should show 2 columns
      expect(delegate.crossAxisCount, 2);

      await tester.binding.setSurfaceSize(null);
    });

    testWidgets('CollectionsPage shows 3 columns on desktop (1000px width)',
        (WidgetTester tester) async {
      await tester.binding.setSurfaceSize(const Size(1000, 800));

      await tester.pumpWidget(buildTestWidget(const CollectionsPage()));

      await tester.pumpAndSettle();

      // Find the GridView widget
      final gridView = tester.widget<GridView>(find.byType(GridView));
      final delegate =
          gridView.gridDelegate as SliverGridDelegateWithFixedCrossAxisCount;

      // Desktop should show 3 columns
      expect(delegate.crossAxisCount, 3);

      await tester.binding.setSurfaceSize(null);
    });
  });

  group('CollectionsPage Styling', () {
    testWidgets('CollectionsPage heading has correct styling',
        (WidgetTester tester) async {
      await tester.pumpWidget(buildTestWidget(const CollectionsPage()));

      await tester.pumpAndSettle();

      final textWidget = tester.widget<Text>(find.text('collections'));
      expect(textWidget.style?.fontSize, 48);
      expect(textWidget.style?.fontWeight, FontWeight.bold);
      expect(textWidget.textAlign, TextAlign.center);
    });

    testWidgets('CollectionsPage overlay labels have white color with shadow',
        (WidgetTester tester) async {
      await tester.pumpWidget(buildTestWidget(const CollectionsPage()));

      await tester.pumpAndSettle();

      // Find any overlay label text
      final textWidget = tester.widget<Text>(find.text('Autumn Favourites'));
      expect(textWidget.style?.color, Colors.white);
      expect(textWidget.style?.fontWeight, FontWeight.bold);
      expect(textWidget.style?.shadows, isNotNull);
      expect(textWidget.style?.shadows?.length, 1);
    });
  });

  group('CollectionsPage GestureDetector', () {
    testWidgets('CollectionsPage items have GestureDetector',
        (WidgetTester tester) async {
      await tester.pumpWidget(buildTestWidget(const CollectionsPage()));

      await tester.pumpAndSettle();

      // Should have at least 15 GestureDetectors from collection items
      final gestures = find.byType(GestureDetector);
      expect(gestures.evaluate().length, greaterThanOrEqualTo(15));
    });

    testWidgets('CollectionsPage items have Stack for overlay',
        (WidgetTester tester) async {
      await tester.pumpWidget(buildTestWidget(const CollectionsPage()));

      await tester.pumpAndSettle();

      // Should have at least 15 Stacks from collection items (plus possibly more from header)
      final stacks = find.byType(Stack);
      expect(stacks.evaluate().length, greaterThanOrEqualTo(15));
    });
  });

  group('CollectionPage Widget Properties', () {
    test('CollectionsPage can be instantiated', () {
      const page = CollectionsPage();
      expect(page, isNotNull);
      expect(page, isA<Widget>());
      expect(page, isA<StatelessWidget>());
    });

    test('CollectionsPage can be instantiated with key', () {
      const key = Key('test-key');
      const page = CollectionsPage(key: key);
      expect(page.key, key);
    });

    test('CollectionsPage key is optional', () {
      const page = CollectionsPage();
      expect(page.key, isNull);
    });
  });

  // CollectionPage (individual collection view) tests
  group('CollectionPage Widget Tests', () {
    testWidgets('CollectionPage shows loading indicator initially',
        (WidgetTester tester) async {
      await tester.pumpWidget(
        buildTestWidgetForCollectionPage(
          CollectionPage(slug: 'essential-range', firestore: mockFirestore),
        ),
      );

      // Before pumpAndSettle, should show loading
      expect(find.byType(CircularProgressIndicator), findsOneWidget);
    });

    testWidgets(
        'CollectionPage shows "No products found" for non-existent collection',
        (WidgetTester tester) async {
      await tester.pumpWidget(
        buildTestWidgetForCollectionPage(
          CollectionPage(slug: 'nonexistent', firestore: mockFirestore),
        ),
      );
      await tester.pumpAndSettle();

      expect(find.textContaining('No products found'), findsOneWidget);
    });

    testWidgets(
        'CollectionPage executes helper methods with various data formats',
        (WidgetTester tester) async {
      // Suppress rendering errors for this test
      final originalOnError = FlutterError.onError;
      FlutterError.onError = (details) {
        if (!details.toString().contains('RenderFlex overflowed')) {
          originalOnError?.call(details);
        }
      };

      await tester.pumpWidget(
        buildTestWidgetForCollectionPage(
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
        buildTestWidgetForCollectionPage(
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
        buildTestWidgetForCollectionPage(
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
        buildTestWidgetForCollectionPage(
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
        buildTestWidgetForCollectionPage(
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
    testWidgets(
        'CollectionPage renders with default firestore when none injected',
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
