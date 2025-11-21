import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:union_shop/homepage.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  testWidgets('HomeScreen renders all UI + local images', (tester) async {
    await tester.pumpWidget(
      const MaterialApp(
        home: HomeScreen(),
      ),
    );

    // HERO SECTION TEXT
    expect(find.text('Placeholder Hero Title'), findsOneWidget);
    expect(find.text('This is placeholder text for the hero section.'),
        findsOneWidget);
    expect(find.text('BROWSE PRODUCTS'), findsOneWidget);

    // ✅ HERO IMAGE TEST (local asset)
    expect(
      find.image(
          const AssetImage('assets/images/Pink_Essential_Hoodie_720x.webp')),
      findsOneWidget,
    );

    // PRODUCTS SECTION TITLE
    expect(find.text('PRODUCTS SECTION'), findsOneWidget);

    // PRODUCT ITEMS
    expect(find.text('Placeholder Product 1'), findsOneWidget);
    expect(find.text('Placeholder Product 2'), findsOneWidget);
    expect(find.text('Placeholder Product 3'), findsOneWidget);
    expect(find.text('Placeholder Product 4'), findsOneWidget);

    // ✅ PRODUCT CARD IMAGE TESTS (local assets)
    expect(
      find.image(
          const AssetImage('assets/images/Pink_Essential_Hoodie_720x.webp')),
      findsWidgets, // appears in hero + product 1
    );

    expect(
      find.image(const AssetImage('assets/images/Sage_T-shirt_720x.webp')),
      findsOneWidget,
    );

    expect(
      find.image(const AssetImage('assets/images/SageHoodie_720x.webp')),
      findsOneWidget,
    );

    expect(
      find.image(const AssetImage(
          'assets/images/Signature_T-Shirt_Indigo_Blue_2_720x.webp')),
      findsOneWidget,
    );

    // FOOTER
    expect(find.text('Opening Hours'), findsOneWidget);
    expect(find.text('Latest Offers'), findsOneWidget);
  });
}
