import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:union_shop/product_page.dart';

void main() {
  group('Product Page Tests', () {
    Widget createTestWidget() {
      return const MaterialApp(
        home: ProductPage(
          imageUrl: 'assets/images/postcard.jpg',
          title: 'Test Product',
          price: '£9.99',
        ),
      );
    }

    testWidgets('should display product page with basic elements', (
      tester,
    ) async {
      await tester.pumpWidget(createTestWidget());
      await tester.pump();

      // Title and price passed into ProductPage
      expect(find.text('Test Product'), findsOneWidget);
      expect(find.text('£9.99'), findsOneWidget);

      // Description heading (from ProductPage)
      expect(find.text('Description'), findsOneWidget);
    });

    testWidgets('should display header icons', (tester) async {
      await tester.pumpWidget(createTestWidget());
      await tester.pump();

      // Check that header icons are present
      expect(find.byIcon(Icons.search), findsOneWidget);
      expect(find.byIcon(Icons.shopping_bag_outlined), findsOneWidget);
      expect(find.byIcon(Icons.menu), findsOneWidget);
    });

    testWidgets('should display footer', (tester) async {
      await tester.pumpWidget(createTestWidget());
      await tester.pump();

      // Check that footer is present
      // Update these to whatever text your AppFooter actually shows
      expect(find.text('Opening Hours'), findsOneWidget);
      expect(find.text('Latest Offers'), findsOneWidget);
    });
  });
}
