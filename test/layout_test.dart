import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:union_shop/layout.dart'; // make sure this path is correct

void main() {
  testWidgets('AppHeader renders and navigates Home and About',
      (WidgetTester tester) async {
    final router = GoRouter(routes: [
      GoRoute(
        path: '/',
        builder: (context, state) => const Scaffold(
          body: Column(
            children: [
              AppHeader(),
              Text('HOME_PAGE'),
            ],
          ),
        ),
      ),
      GoRoute(
        path: '/about',
        builder: (context, state) => const Scaffold(
          body: Column(
            children: [
              AppHeader(),
              Text('ABOUT_PAGE'),
            ],
          ),
        ),
      ),
      // include other routes the header may reference to avoid unknown route errors
      GoRoute(
        path: '/collections',
        builder: (context, state) => const Scaffold(
            body: Column(children: [AppHeader(), Text('COLLECTIONS')])),
      ),
      GoRoute(
        path: '/sale',
        builder: (context, state) => const Scaffold(
            body: Column(children: [AppHeader(), Text('SALE_PAGE')])),
      ),
      GoRoute(
        path: '/printshack',
        builder: (context, state) => const Scaffold(
            body: Column(children: [AppHeader(), Text('PRINT_PAGE')])),
      ),
    ]);

    await tester.pumpWidget(MaterialApp.router(routerConfig: router));

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

    // initial route is '/', so HOME_PAGE should be visible
    expect(find.text('HOME_PAGE'), findsOneWidget);

    // --- TAP TEST: About --- (header should navigate using go_router)
    await tester.tap(find.text("About"));
    await tester.pumpAndSettle();
    expect(find.text('ABOUT_PAGE'), findsOneWidget);

    // --- TAP TEST: Home ---
    await tester.tap(find.text("Home"));
    await tester.pumpAndSettle();
    expect(find.text('HOME_PAGE'), findsOneWidget);
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
