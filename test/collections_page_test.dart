import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:union_shop/views/collections_page.dart';
import 'package:union_shop/layout.dart' show HoverImage, AppHeader, AppFooter;

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  testWidgets(
      'CollectionsPage renders heading, header, footer, images and overlays',
      (WidgetTester tester) async {
    await tester.pumpWidget(
      const MaterialApp(
        home: CollectionsPage(),
      ),
    );

    await tester.pumpAndSettle();

    // Heading
    expect(find.text('collections'), findsOneWidget);

    // Header and footer present
    expect(find.byType(AppHeader), findsOneWidget);
    expect(find.byType(AppFooter), findsOneWidget);

    // There should be 5 rows * 3 images = 15 HoverImage widgets
    expect(find.byType(HoverImage), findsNWidgets(15));

    // Check a couple of deterministic overlay labels are present
    expect(find.text('Autumn Favourites'), findsOneWidget);
    expect(find.text('Summer Collection'), findsOneWidget);
  });
}
