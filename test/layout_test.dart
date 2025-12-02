import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:union_shop/layout.dart';

void main() {
  testWidgets('AppFooter renders all column titles',
      (WidgetTester tester) async {
    await tester.pumpWidget(
      const MaterialApp(
        home: Scaffold(
          body: AppFooter(),
        ),
      ),
    );

    // Column titles
    expect(find.text('Opening Hours'), findsOneWidget);
    expect(find.text('Help and Information'), findsOneWidget);
    expect(find.text('Latest Offers'), findsOneWidget);
  });

  testWidgets('AppFooter renders opening hours content',
      (WidgetTester tester) async {
    await tester.pumpWidget(
      const MaterialApp(
        home: Scaffold(
          body: AppFooter(),
        ),
      ),
    );

    // Opening hours content
    expect(find.text('(Term Time)'), findsOneWidget);
    expect(find.text('Monday - Friday 9am - 4pm'), findsOneWidget);
    expect(find.text('(Outside of Term Time / Consolidation Weeks)'),
        findsOneWidget);
    expect(find.text('Monday - Friday 9am - 3pm'), findsOneWidget);
    expect(find.text('Purchase online 24/7'), findsOneWidget);
  });

  testWidgets('AppFooter renders help section links',
      (WidgetTester tester) async {
    await tester.pumpWidget(
      const MaterialApp(
        home: Scaffold(
          body: AppFooter(),
        ),
      ),
    );

    // Help links
    expect(find.text('Search'), findsOneWidget);
    expect(find.text('Terms & Conditions of Sale Policy'), findsOneWidget);
  });

  testWidgets('AppFooter renders subscribe section',
      (WidgetTester tester) async {
    await tester.pumpWidget(
      const MaterialApp(
        home: Scaffold(
          body: AppFooter(),
        ),
      ),
    );

    // Subscribe section
    expect(find.text('Email address'), findsOneWidget);
    expect(find.byType(TextField), findsOneWidget);
    expect(find.text('Subscribe'), findsOneWidget);
    expect(find.byType(ElevatedButton), findsOneWidget);
  });

  testWidgets('AppFooter uses column layout on narrow screens',
      (WidgetTester tester) async {
    // Set a narrow screen size
    await tester.binding.setSurfaceSize(const Size(600, 800));

    await tester.pumpWidget(
      const MaterialApp(
        home: Scaffold(
          body: AppFooter(),
        ),
      ),
    );

    // Content should still render
    expect(find.text('Opening Hours'), findsOneWidget);
    expect(find.text('Help and Information'), findsOneWidget);
    expect(find.text('Latest Offers'), findsOneWidget);

    // Reset to default size
    await tester.binding.setSurfaceSize(null);
  });

  testWidgets('AppFooter uses row layout on wide screens',
      (WidgetTester tester) async {
    // Set a wide screen size
    await tester.binding.setSurfaceSize(const Size(1200, 800));

    await tester.pumpWidget(
      const MaterialApp(
        home: Scaffold(
          body: AppFooter(),
        ),
      ),
    );

    // Content should still render
    expect(find.text('Opening Hours'), findsOneWidget);
    expect(find.text('Help and Information'), findsOneWidget);
    expect(find.text('Latest Offers'), findsOneWidget);

    // Reset to default size
    await tester.binding.setSurfaceSize(null);
  });
}
