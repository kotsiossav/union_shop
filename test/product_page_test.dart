import 'package:fake_cloud_firestore/fake_cloud_firestore.dart';
import 'package:firebase_auth_mocks/firebase_auth_mocks.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';
import 'package:union_shop/models/cart_model.dart';
import 'package:union_shop/services/auth_service.dart';
import 'package:union_shop/views/product_page.dart';

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

  Widget createTestWidget({
    String imageUrl = 'assets/images/Bear.avif',
    String title = 'Test Product',
    double price = 29.99,
    String category = 'Clothing',
  }) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider<CartModel>.value(value: cart),
        Provider<AuthService>.value(value: authService),
      ],
      child: MaterialApp(
        home: ProductPage(
          imageUrl: imageUrl,
          title: title,
          price: price,
          category: category,
          cart: cart,
        ),
      ),
    );
  }

  group('ProductPage Widget Tests', () {
    testWidgets('displays product title, price, and description',
        (tester) async {
      await tester.pumpWidget(createTestWidget());
      await tester.pumpAndSettle();

      expect(find.text('Test Product'), findsWidgets);
      expect(find.text('\$29.99'), findsOneWidget);
      expect(find.text('Description'), findsOneWidget);
      expect(find.text('This is a placeholder description for the product.'),
          findsOneWidget);
    });

    testWidgets('displays product image with asset', (tester) async {
      await tester.pumpWidget(createTestWidget());
      await tester.pumpAndSettle();

      final imageFinder = find.byKey(const Key('product_image'));
      expect(imageFinder, findsOneWidget);
    });

    testWidgets('displays product image with network URL', (tester) async {
      await tester.pumpWidget(createTestWidget(
        imageUrl: 'https://example.com/image.jpg',
      ));
      await tester.pumpAndSettle();

      // Network images will fail in tests but widget should still render
      final imageFinder = find.byKey(const Key('product_image'));
      expect(imageFinder, findsOneWidget);
    });

    testWidgets('quantity starts at 1', (tester) async {
      await tester.pumpWidget(createTestWidget());
      await tester.pumpAndSettle();

      expect(find.text('1'), findsWidgets);
    });

    testWidgets('increment button increases quantity', (tester) async {
      await tester.pumpWidget(createTestWidget());
      await tester.pumpAndSettle();

      // Scroll to the quantity controls
      await tester.dragUntilVisible(
        find.byIcon(Icons.add_circle_outline),
        find.byType(SingleChildScrollView),
        const Offset(0, -50),
      );

      final incrementButton = find.byIcon(Icons.add_circle_outline);
      await tester.tap(incrementButton.first);
      await tester.pump();

      expect(find.text('2'), findsWidgets);
    });

    testWidgets('decrement button decreases quantity', (tester) async {
      await tester.pumpWidget(createTestWidget());
      await tester.pumpAndSettle();

      // Scroll to quantity controls
      await tester.dragUntilVisible(
        find.byIcon(Icons.add_circle_outline),
        find.byType(SingleChildScrollView),
        const Offset(0, -50),
      );

      // First increment to 2
      final incrementButton = find.byIcon(Icons.add_circle_outline);
      await tester.tap(incrementButton.first);
      await tester.pump();

      // Then decrement back to 1
      final decrementButton = find.byIcon(Icons.remove_circle_outline);
      await tester.tap(decrementButton.first);
      await tester.pump();

      expect(find.text('1'), findsWidgets);
    });

    testWidgets('decrement button does not go below 1', (tester) async {
      await tester.pumpWidget(createTestWidget());
      await tester.pumpAndSettle();

      // Scroll to quantity controls
      await tester.dragUntilVisible(
        find.byIcon(Icons.remove_circle_outline),
        find.byType(SingleChildScrollView),
        const Offset(0, -50),
      );

      final decrementButton = find.byIcon(Icons.remove_circle_outline);
      await tester.tap(decrementButton.first);
      await tester.pump();

      expect(find.text('1'), findsWidgets);
    });

    testWidgets('quantity can be edited via text field', (tester) async {
      await tester.pumpWidget(createTestWidget());
      await tester.pumpAndSettle();

      // Scroll to increment button first to bring quantity controls into view
      await tester.dragUntilVisible(
        find.byIcon(Icons.add_circle_outline).first,
        find.byType(SingleChildScrollView),
        const Offset(0, -50),
      );

      final textField = find.byType(TextField).first;
      await tester.enterText(textField, '5');
      await tester.testTextInput.receiveAction(TextInputAction.done);
      await tester.pump();

      expect(find.text('5'), findsWidgets);
    });

    testWidgets('text field rejects non-numeric input', (tester) async {
      await tester.pumpWidget(createTestWidget());
      await tester.pumpAndSettle();

      // Scroll to increment button first to bring quantity controls into view
      await tester.dragUntilVisible(
        find.byIcon(Icons.add_circle_outline).first,
        find.byType(SingleChildScrollView),
        const Offset(0, -50),
      );

      final textField = find.byType(TextField).first;
      await tester.enterText(textField, 'abc');
      await tester.testTextInput.receiveAction(TextInputAction.done);
      await tester.pump();

      expect(find.text('1'), findsWidgets);
    });

    testWidgets('shows color and size dropdowns for Clothing category',
        (tester) async {
      await tester.pumpWidget(createTestWidget(category: 'Clothing'));
      await tester.pumpAndSettle();

      // Scroll to find Color text
      await tester.dragUntilVisible(
        find.text('Color'),
        find.byType(SingleChildScrollView),
        const Offset(0, -50),
      );

      expect(find.text('Color'), findsWidgets);
      expect(find.text('Size'), findsWidgets);
    });

    testWidgets('does not show color/size dropdowns for non-Clothing category',
        (tester) async {
      await tester.pumpWidget(createTestWidget(category: 'Merchandise'));
      await tester.pumpAndSettle();

      expect(find.text('Color'), findsNothing);
      expect(find.text('Size'), findsNothing);
    });

    testWidgets('color dropdown changes value', (tester) async {
      await tester.pumpWidget(createTestWidget(category: 'Clothing'));
      await tester.pumpAndSettle();

      // Scroll to color dropdown
      await tester.dragUntilVisible(
        find.text('Color'),
        find.byType(SingleChildScrollView),
        const Offset(0, -50),
      );

      final colorDropdown = find.byType(DropdownButton<String>).first;
      await tester.tap(colorDropdown);
      await tester.pumpAndSettle();

      await tester.tap(find.text('White').last);
      await tester.pumpAndSettle();

      expect(find.text('White'), findsWidgets);
    });

    testWidgets('size dropdown changes value', (tester) async {
      await tester.pumpWidget(createTestWidget(category: 'Clothing'));
      await tester.pumpAndSettle();

      // Scroll to size dropdown
      await tester.dragUntilVisible(
        find.text('Size'),
        find.byType(SingleChildScrollView),
        const Offset(0, -50),
      );

      final sizeDropdown = find.byType(DropdownButton<String>).last;
      await tester.tap(sizeDropdown);
      await tester.pumpAndSettle();

      await tester.tap(find.text('L').last);
      await tester.pumpAndSettle();

      expect(find.text('L'), findsWidgets);
    });

    testWidgets('add to cart button adds product to cart', (tester) async {
      await tester.pumpWidget(createTestWidget());
      await tester.pumpAndSettle();

      expect(cart.items.length, 0);

      // Scroll to add to cart button
      await tester.dragUntilVisible(
        find.text('Add to cart'),
        find.byType(SingleChildScrollView),
        const Offset(0, -50),
      );

      final addButton = find.text('Add to cart');
      await tester.tap(addButton.first);
      await tester.pump();

      expect(cart.items.length, 1);
      expect(cart.items.values.first.title, 'Test Product');
      expect(cart.items.values.first.price, 29.99);
    });

    testWidgets('add to cart with quantity 3 adds 3 items', (tester) async {
      await tester.pumpWidget(createTestWidget());
      await tester.pumpAndSettle();

      // Scroll to quantity controls
      await tester.dragUntilVisible(
        find.byIcon(Icons.add_circle_outline),
        find.byType(SingleChildScrollView),
        const Offset(0, -50),
      );

      // Set quantity to 3
      final incrementButton = find.byIcon(Icons.add_circle_outline);
      await tester.tap(incrementButton.first);
      await tester.pump();
      await tester.tap(incrementButton.first);
      await tester.pump();

      // Scroll to add to cart button
      await tester.dragUntilVisible(
        find.text('Add to cart'),
        find.byType(SingleChildScrollView),
        const Offset(0, -50),
      );

      final addButton = find.text('Add to cart');
      await tester.tap(addButton.first);
      await tester.pump();

      expect(cart.items.length, 1); // One unique product
      expect(cart.totalQuantity, 3); // Total quantity is 3
    });

    testWidgets('add to cart shows snackbar confirmation', (tester) async {
      await tester.pumpWidget(createTestWidget());
      await tester.pumpAndSettle();

      // Scroll to add to cart button
      await tester.dragUntilVisible(
        find.text('Add to cart'),
        find.byType(SingleChildScrollView),
        const Offset(0, -50),
      );

      final addButton = find.text('Add to cart');
      await tester.tap(addButton.first);
      await tester.pump();

      expect(find.byType(SnackBar), findsOneWidget);
      expect(find.text('Added 1 × Test Product to cart'), findsOneWidget);
    });

    testWidgets('adds clothing items with color and size', (tester) async {
      await tester.pumpWidget(createTestWidget(category: 'Clothing'));
      await tester.pumpAndSettle();

      // Scroll to color dropdown
      await tester.dragUntilVisible(
        find.text('Color'),
        find.byType(SingleChildScrollView),
        const Offset(0, -50),
      );

      // Change color to White
      final colorDropdown = find.byType(DropdownButton<String>).first;
      await tester.tap(colorDropdown);
      await tester.pumpAndSettle();
      await tester.tap(find.text('White').last);
      await tester.pumpAndSettle();

      // Change size to L
      final sizeDropdown = find.byType(DropdownButton<String>).last;
      await tester.tap(sizeDropdown);
      await tester.pumpAndSettle();
      await tester.tap(find.text('L').last);
      await tester.pumpAndSettle();

      // Scroll to add to cart button
      await tester.dragUntilVisible(
        find.text('Add to cart'),
        find.byType(SingleChildScrollView),
        const Offset(0, -50),
      );

      // Add to cart
      final addButton = find.text('Add to cart');
      await tester.tap(addButton.first);
      await tester.pump();

      expect(cart.items.length, 1);
      expect(cart.items.values.first.color, 'White');
      expect(cart.items.values.first.size, 'L');
    });

    testWidgets('narrow layout displays correctly', (tester) async {
      await tester.binding.setSurfaceSize(const Size(400, 800));
      await tester.pumpWidget(createTestWidget());
      await tester.pumpAndSettle();

      expect(find.text('Test Product'), findsWidgets);
      expect(find.text('\$29.99'), findsOneWidget);
      expect(find.byType(ProductPage), findsOneWidget);

      addTearDown(() => tester.binding.setSurfaceSize(null));
    });

    testWidgets('wide layout displays correctly', (tester) async {
      await tester.binding.setSurfaceSize(const Size(1200, 800));
      await tester.pumpWidget(createTestWidget());
      await tester.pumpAndSettle();

      expect(find.text('Test Product'), findsWidgets);
      expect(find.text('\$29.99'), findsOneWidget);
      expect(find.byType(ProductPage), findsOneWidget);

      addTearDown(() => tester.binding.setSurfaceSize(null));
    });

    testWidgets('multiple increments work correctly', (tester) async {
      await tester.pumpWidget(createTestWidget());
      await tester.pumpAndSettle();

      // Scroll to quantity controls
      await tester.dragUntilVisible(
        find.byIcon(Icons.add_circle_outline),
        find.byType(SingleChildScrollView),
        const Offset(0, -50),
      );

      final incrementButton = find.byIcon(Icons.add_circle_outline);

      // Increment 5 times
      for (int i = 0; i < 5; i++) {
        await tester.tap(incrementButton.first);
        await tester.pump();
      }

      expect(find.text('6'), findsWidgets);
    });

    testWidgets('text field rejects non-numeric input', (tester) async {
      await tester.pumpWidget(createTestWidget());
      await tester.pumpAndSettle();

      // Scroll to increment button first to bring quantity controls into view
      await tester.dragUntilVisible(
        find.byIcon(Icons.add_circle_outline).first,
        find.byType(SingleChildScrollView),
        const Offset(0, -50),
      );

      final textField = find.byType(TextField).first;

      // Try to enter letters (should be filtered by digitsOnly formatter)
      await tester.enterText(textField, 'abc');
      await tester.pump();

      // Should remain empty or default
      expect(find.text('abc'), findsNothing);
    });

    testWidgets('product page has AppBar with title', (tester) async {
      await tester.pumpWidget(createTestWidget());
      await tester.pumpAndSettle();

      expect(find.byType(AppBar), findsOneWidget);
      expect(find.text('Test Product'), findsWidgets);
    });

    testWidgets('default color is Black for clothing', (tester) async {
      await tester.pumpWidget(createTestWidget(category: 'Clothing'));
      await tester.pumpAndSettle();

      // Scroll to color dropdown
      await tester.dragUntilVisible(
        find.text('Color'),
        find.byType(SingleChildScrollView),
        const Offset(0, -50),
      );

      expect(find.text('Black'), findsWidgets);
    });

    testWidgets('default size is S for clothing', (tester) async {
      await tester.pumpWidget(createTestWidget(category: 'Clothing'));
      await tester.pumpAndSettle();

      // Scroll to size dropdown
      await tester.dragUntilVisible(
        find.text('Size'),
        find.byType(SingleChildScrollView),
        const Offset(0, -50),
      );

      expect(find.text('S'), findsWidgets);
    });

    testWidgets('displays correct price format with dollar sign',
        (tester) async {
      await tester.pumpWidget(createTestWidget(price: 99.99));
      await tester.pumpAndSettle();

      expect(find.text('\$99.99'), findsOneWidget);
    });

    testWidgets('all color options are available', (tester) async {
      await tester.pumpWidget(createTestWidget(category: 'Clothing'));
      await tester.pumpAndSettle();

      // Scroll to color dropdown
      await tester.dragUntilVisible(
        find.text('Color'),
        find.byType(SingleChildScrollView),
        const Offset(0, -50),
      );

      final colorDropdown = find.byType(DropdownButton<String>).first;
      await tester.tap(colorDropdown);
      await tester.pumpAndSettle();

      // Check all colors are present
      expect(find.text('Black'), findsWidgets);
      expect(find.text('White'), findsWidgets);
      expect(find.text('Navy'), findsWidgets);
      expect(find.text('Red'), findsWidgets);
    });

    testWidgets('all size options are available', (tester) async {
      await tester.pumpWidget(createTestWidget(category: 'Clothing'));
      await tester.pumpAndSettle();

      // Scroll to size dropdown
      await tester.dragUntilVisible(
        find.text('Size'),
        find.byType(SingleChildScrollView),
        const Offset(0, -50),
      );

      final sizeDropdown = find.byType(DropdownButton<String>).last;
      await tester.tap(sizeDropdown);
      await tester.pumpAndSettle();

      // Check all sizes are present
      expect(find.text('S'), findsWidgets);
      expect(find.text('M'), findsWidgets);
      expect(find.text('L'), findsWidgets);
      expect(find.text('XL'), findsWidgets);
    });
  });
}
