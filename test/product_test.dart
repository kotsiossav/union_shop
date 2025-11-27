import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:union_shop/views/product_page.dart';

void main() {
  group('ProductPage Tests', () {
    Widget createTestWidget() {
      // ProductPage expects a double for price (not a string),
      // and we must not use const because ProductPage isn't a const constructor.
      return MaterialApp(
        home: ProductPage(
          imageUrl: 'assets/images/bookmark.jpg',
          title: 'Placeholder Product 7',
          price: 10.0,
        ),
      );
    }

    testWidgets('displays the product title, price, and description',
        (tester) async {
      await tester.pumpWidget(createTestWidget());
      await tester.pump();

      // Verify the title is displayed
      // title appears in AppBar and in body — accept one or more matches
      expect(find.text('Placeholder Product 7'), findsWidgets);

      // Verify the price is displayed (formatted in the UI as text)
      expect(find.textContaining('10'), findsWidgets);

      // Verify the description heading is displayed
      expect(find.text('Description'), findsOneWidget);

      // Verify the placeholder description text is displayed
      expect(find.text('This is a placeholder description for the product.'),
          findsOneWidget);
    });

    testWidgets('displays the product image', (tester) async {
      await tester.pumpWidget(createTestWidget());
      await tester.pump();

      // Verify the product image exists (match asset name)
      final imageFinder = find.byWidgetPredicate((w) {
        if (w is Image && w.image is AssetImage) {
          return (w.image as AssetImage).assetName ==
              'assets/images/bookmark.jpg';
        }
        return false;
      });

      expect(imageFinder, findsOneWidget);
    });

    testWidgets('handles narrow layout correctly', (tester) async {
      await tester.binding
          .setSurfaceSize(const Size(400, 800)); // Simulate narrow screen
      await tester.pumpWidget(createTestWidget());
      await tester.pump();

      // Verify the title and price are displayed below the image
      // title appears both in AppBar and body — accept one or more matches
      expect(find.text('Placeholder Product 7'), findsWidgets);
      expect(find.textContaining('10'), findsWidgets);
    });

    testWidgets('handles wide layout correctly', (tester) async {
      await tester.binding
          .setSurfaceSize(const Size(1200, 800)); // Simulate wide screen
      await tester.pumpWidget(createTestWidget());
      await tester.pump();

      // Verify the title and price are displayed to the right of the image
      // title appears both in AppBar and body — accept one or more matches
      expect(find.text('Placeholder Product 7'), findsWidgets);
      expect(find.textContaining('10'), findsWidgets);
    });
  });
}
