import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:union_shop/homepage.dart';

// Add this import so ProductCard is visible to the test
import 'package:union_shop/homepage.dart' show ProductCard;

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  testWidgets('HomeScreen renders hero slider, product cards, and footer',
      (tester) async {
    await tester.pumpWidget(
      const MaterialApp(
        home: HomeScreen(),
      ),
    );

    // ---------------------------------------------------------
    // HERO SECTION
    // ---------------------------------------------------------

    // Check first hero slide title
    expect(find.text('Essential Range - Over 20% Off!'), findsOneWidget);

    // Check first hero subtitle
    expect(
      find.text(
        'Over 20% off our essential range.come and grab yours while stock lasts!.',
      ),
      findsOneWidget,
    );

    // Check hero button
    expect(find.text('BROWSE PRODUCTS'), findsOneWidget);

    // HERO IMAGE EXISTS
    expect(
      find.image(
        const AssetImage('assets/images/Pink_Essential_Hoodie_720x.webp'),
      ),
      findsWidgets, // appears in hero + product card
    );

    // ---------------------------------------------------------
    // PRODUCT SECTIONS
    // ---------------------------------------------------------

    // Section titles
    expect(find.text('ESSENTIAL RANGE - OVER 20% OFF!'), findsOneWidget);
    expect(find.text('SIGNATURE RANGE'), findsOneWidget);
    expect(find.text('PORTSMOUTH CITY COLLECTION'), findsOneWidget);
    expect(find.text('OUR RANGE'), findsOneWidget);

    // Product Card Titles
    expect(find.text('Placeholder Product 1'), findsOneWidget);
    expect(find.text('Placeholder Product 2'), findsOneWidget);
    expect(find.text('Placeholder Product 3'), findsOneWidget);
    expect(find.text('Placeholder Product 4'), findsOneWidget);
    expect(find.text('Placeholder Product 5'), findsOneWidget);
    expect(find.text('Placeholder Product 6'), findsOneWidget);
    expect(find.text('Placeholder Product 7'), findsOneWidget);
    expect(find.text('Placeholder Product 8'), findsOneWidget);

    // Product Images
    expect(
      find.image(
        const AssetImage('assets/images/Sage_T-shirt_720x.webp'),
      ),
      findsOneWidget,
    );

    expect(
      find.image(
        const AssetImage('assets/images/SageHoodie_720x.webp'),
      ),
      findsOneWidget,
    );

    expect(
      find.image(
        const AssetImage(
            'assets/images/Signature_T-Shirt_Indigo_Blue_2_720x.webp'),
      ),
      findsOneWidget,
    );

    expect(
      find.image(const AssetImage('assets/images/postcard.jpg')),
      findsWidgets,
    );

    expect(
      find.image(const AssetImage('assets/images/magnet.jpg')),
      findsOneWidget,
    );

    expect(
      find.image(const AssetImage('assets/images/bookmark.jpg')),
      findsOneWidget,
    );

    // ---------------------------------------------------------
    // FOOTER
    // ---------------------------------------------------------
    expect(find.text('Opening Hours'), findsOneWidget);
    expect(find.text('Latest Offers'), findsOneWidget);

    // VIEW ALL button exists
    expect(find.text('VIEW ALL'), findsOneWidget);
  });

  testWidgets('Tapping a ProductCard navigates to /product', (tester) async {
    await tester.pumpWidget(
      MaterialApp(
        home: const HomeScreen(),
        routes: {
          '/product': (_) => const Scaffold(
                body: Center(child: Text('Product Page')),
              ),
        },
      ),
    );

    await tester.pumpAndSettle();

    final titleFinder = find.text('Placeholder Product 1');
    expect(titleFinder, findsOneWidget);

    // Find the internal Scrollable inside the main SingleChildScrollView
    final scrollableFinder = find.descendant(
      of: find.byType(SingleChildScrollView),
      matching: find.byType(Scrollable),
    );

    // Scroll until the product title appears
    await tester.scrollUntilVisible(
      titleFinder,
      300,
      scrollable: scrollableFinder.first,
    );

    await tester.pumpAndSettle();

    // Tap the product
    await tester.tap(titleFinder);
    await tester.pumpAndSettle();

    // Should navigate to test Product Page
    expect(find.text('Product Page'), findsOneWidget);
  });

  testWidgets('Hero slideshow arrows change the current slide', (tester) async {
    await tester.pumpWidget(
      const MaterialApp(
        home: HomeScreen(),
      ),
    );

    // Initial slide should show the first hero title
    expect(find.text('Essential Range - Over 20% Off!'), findsOneWidget);

    // Tap the RIGHT arrow
    final rightArrowFinder =
        find.widgetWithIcon(IconButton, Icons.arrow_forward_ios);
    expect(rightArrowFinder, findsOneWidget);

    await tester.tap(rightArrowFinder);
    await tester.pumpAndSettle();

    // Now the second slide's hero title should be visible
    expect(find.text('Essential Range - Over 20% Off!'), findsNothing);
    expect(find.text('The Print Shack'),
        findsWidgets); // may appear in more than 1 place

    // Tap the RIGHT arrow again (wraps back to first slide)
    await tester.tap(rightArrowFinder);
    await tester.pumpAndSettle();

    // Back to first hero title
    expect(find.text('Essential Range - Over 20% Off!'), findsOneWidget);

    // Tap the LEFT arrow (wraps to last slide)
    final leftArrowFinder =
        find.widgetWithIcon(IconButton, Icons.arrow_back_ios);
    expect(leftArrowFinder, findsOneWidget);

    await tester.tap(leftArrowFinder);
    await tester.pumpAndSettle();

    // Should now be on second slide again (hero title present)
    expect(find.text('Essential Range - Over 20% Off!'), findsNothing);
    expect(find.text('The Print Shack'), findsWidgets);
  });
}
