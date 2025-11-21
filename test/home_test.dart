import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:union_shop/homepage.dart';
import 'package:union_shop/layout.dart';

void main() {
  testWidgets('HomeScreen shows header, hero text, products section and footer',
      (WidgetTester tester) async {
    await tester.pumpWidget(
      const MaterialApp(
        home: HomeScreen(),
      ),
    );

    // Header banner text from AppHeader
    expect(
      find.text(
        'BIG SALE! OUR ESSENTIAL RANGE HAS DROPPED IN PRICE! OVER 20% OFF! COME GRAB YOURS WHILE STOCK LASTS!',
      ),
      findsOneWidget,
    );

    // Hero section texts
    expect(find.text('Placeholder Hero Title'), findsOneWidget);
    expect(find.text('This is placeholder text for the hero section.'),
        findsOneWidget);

    // Products section title
    expect(find.text('PRODUCTS SECTION'), findsOneWidget);

    // Product cards (by their titles)
    expect(find.text('Placeholder Product 1'), findsOneWidget);
    expect(find.text('Placeholder Product 2'), findsOneWidget);
    expect(find.text('Placeholder Product 3'), findsOneWidget);
    expect(find.text('Placeholder Product 4'), findsOneWidget);

    // Footer content (use some specific footer text)
    expect(find.text('Terms & Conditions of Sale Policy'), findsOneWidget);
  });

  testWidgets('HomeScreen renders AppHeader and AppFooter widgets',
      (WidgetTester tester) async {
    await tester.pumpWidget(
      const MaterialApp(
        home: HomeScreen(),
      ),
    );

    expect(find.byType(AppHeader), findsOneWidget);
    expect(find.byType(AppFooter), findsOneWidget);
  });
}
