import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:union_shop/homepage.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  testWidgets('HomeScreen renders all main UI sections', (tester) async {
    await tester.pumpWidget(
      const MaterialApp(
        home: HomeScreen(),
      ),
    );

    // HEADER (banner)
    expect(
      find.text(
        'BIG SALE! OUR ESSENTIAL RANGE HAS DROPPED IN PRICE! OVER 20% OFF! COME GRAB YOURS WHILE STOCK LASTS!',
      ),
      findsOneWidget,
    );

    // HERO SECTION (text only)
    expect(find.text('Placeholder Hero Title'), findsOneWidget);
    expect(find.text('This is placeholder text for the hero section.'),
        findsOneWidget);
    expect(find.text('BROWSE PRODUCTS'), findsOneWidget);

    // PRODUCTS SECTION TITLE
    expect(find.text('PRODUCTS SECTION'), findsOneWidget);

    // PRODUCT ITEMS
    expect(find.text('Placeholder Product 1'), findsOneWidget);
    expect(find.text('Placeholder Product 2'), findsOneWidget);
    expect(find.text('Placeholder Product 3'), findsOneWidget);
    expect(find.text('Placeholder Product 4'), findsOneWidget);

    // FOOTER
    expect(find.text('Opening Hours'), findsOneWidget);
    expect(find.text('Latest Offers'), findsOneWidget);
  });
}
