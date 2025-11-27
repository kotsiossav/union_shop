import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:union_shop/views/about_page.dart';
import 'package:union_shop/layout.dart' show AppHeader, AppFooter;

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  testWidgets('AboutPage renders header, footer, heading and contact email',
      (WidgetTester tester) async {
    await tester.pumpWidget(
      const MaterialApp(
        home: AboutPage(),
      ),
    );
    await tester.pumpAndSettle();

    // header and footer
    expect(find.byType(AppHeader), findsOneWidget);
    expect(find.byType(AppFooter), findsOneWidget);

    // main heading
    expect(find.text('About Us'), findsOneWidget);

    // body contains contact email
    final contactFinder = find.byWidgetPredicate((w) {
      if (w is Text) {
        final data = w.data ?? '';
        return data.contains('hello@upsu.net');
      }
      return false;
    }, description: 'Text widget containing contact email');
    expect(contactFinder, findsOneWidget);
  });
}
