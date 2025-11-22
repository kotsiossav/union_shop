import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:union_shop/layout.dart'; // make sure this path is correct

void main() {
  testWidgets('AppHeader renders and reacts to Home and About tap',
      (WidgetTester tester) async {
    bool homeTapped = false;
    bool aboutTapped = false;

    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: AppHeader(
            onHome: () => homeTapped = true,
            onShop: () {},
            onSale: () {},
            onPrintShack: () {},
            onAbout: () => aboutTapped = true,
          ),
        ),
      ),
    );

    // --- BASIC CHECKS ---
    expect(
        find.text(
            "BIG SALE! OUR ESSENTIAL RANGE HAS DROPPED IN PRICE! OVER 20% OFF! COME GRAB YOURS WHILE STOCK LASTS!"),
        findsOneWidget);

    // Navigation labels appear
    expect(find.text("Home"), findsOneWidget);
    expect(find.text("Shop"), findsOneWidget);
    expect(find.text("SALE!"), findsOneWidget);
    expect(find.text("About"), findsOneWidget);

    // --- TAP TEST: Home ---
    await tester.tap(find.text("Home"));
    await tester.pump();
    expect(homeTapped, true);

    // --- TAP TEST: About ---
    await tester.tap(find.text("About"));
    await tester.pump();
    expect(aboutTapped, true);
  });

  testWidgets('AppFooter renders key sections', (WidgetTester tester) async {
    await tester.pumpWidget(
      const MaterialApp(
        home: Scaffold(
          body: AppFooter(),
        ),
      ),
    );

    // --- COLUMN TITLES ---
    expect(find.text("Opening Hours"), findsOneWidget);
    expect(find.text("Help and Information"), findsOneWidget);
    expect(find.text("Latest Offers"), findsOneWidget);

    // --- COMMON TEXT ---
    expect(find.text("Search"), findsOneWidget);
    expect(find.text("Email address"), findsOneWidget);

    // --- CHECK EMAIL FIELD EXISTS ---
    expect(find.byType(TextField), findsOneWidget);

    // --- CHECK SUBSCRIBE BUTTON ---
    expect(find.text("Subscribe"), findsOneWidget);
    expect(find.byType(ElevatedButton), findsOneWidget);
  });
}
