import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:union_shop/product_page.dart';

void main() {
  group('ProductPage Tests', () {
    Widget createTestWidget() {
      return const MaterialApp(
        home: ProductPage(
          imageUrl: 'assets/images/bookmark.jpg',
          title: 'Placeholder Product 7',
          price: '£10.00',
        ),
      );
    }

    testWidgets('displays the product title, price, and description',
        (tester) async {
      await tester.pumpWidget(createTestWidget());
      await tester.pump();

      // Verify the title is displayed
      expect(find.text('Placeholder Product 7'), findsOneWidget);

      // Verify the price is displayed
      expect(find.text('£10.00'), findsOneWidget);

      // Verify the description heading is displayed
      expect(find.text('Description'), findsOneWidget);

      // Verify the placeholder description text is displayed
      expect(find.text('This is a placeholder description for the product.'),
          findsOneWidget);
    });

    testWidgets('displays the product image', (tester) async {
      await tester.pumpWidget(createTestWidget());
      await tester.pump();

      // Verify the product image widget exists using the key
      expect(find.byKey(const Key('product_image')), findsOneWidget);
    });

    testWidgets('handles narrow layout correctly', (tester) async {
      await tester.binding
          .setSurfaceSize(const Size(400, 800)); // Simulate narrow screen
      await tester.pumpWidget(createTestWidget());
      await tester.pump();

      // Verify the title and price are displayed below the image
      expect(find.text('Placeholder Product 7'), findsOneWidget);
      expect(find.text('£10.00'), findsOneWidget);
    });

    testWidgets('handles wide layout correctly', (tester) async {
      await tester.binding
          .setSurfaceSize(const Size(1200, 800)); // Simulate wide screen
      await tester.pumpWidget(createTestWidget());
      await tester.pump();

      // Verify the title and price are displayed to the right of the image
      expect(find.text('Placeholder Product 7'), findsOneWidget);
      expect(find.text('£10.00'), findsOneWidget);
    });
  });
}
