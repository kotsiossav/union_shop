import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:union_shop/sign_in.dart';
import 'package:flutter/painting.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  testWidgets(
      'SignInPage shows heading, email field and disabled Continue button',
      (WidgetTester tester) async {
    await tester.pumpWidget(
      const MaterialApp(
        home: SignInPage(),
      ),
    );
    await tester.pumpAndSettle();

    // Heading present
    expect(find.text('Sign in'), findsOneWidget);

    // Email input present
    expect(find.byType(TextFormField), findsOneWidget);

    // Continue button present and disabled
    final buttonFinder = find.widgetWithText(ElevatedButton, 'Continue');
    expect(buttonFinder, findsOneWidget);
    final ElevatedButton buttonWidget =
        tester.widget<ElevatedButton>(buttonFinder);
    expect(buttonWidget.onPressed, isNull);
  });

  testWidgets('SignInPage displays logo image asset at top of the box',
      (WidgetTester tester) async {
    await tester.pumpWidget(
      const MaterialApp(
        home: SignInPage(),
      ),
    );
    await tester.pumpAndSettle();

    // There should be at least one Image widget loading an AssetImage containing logo2.png
    final images = tester.widgetList<Image>(find.byType(Image));
    final hasLogoAsset = images.any((img) {
      final provider = img.image;
      return provider is AssetImage && provider.assetName.contains('logo2.png');
    });

    expect(hasLogoAsset, isTrue,
        reason: 'Expected an Image.asset referencing logo2.png to be present.');
  });
}
