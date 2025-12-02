import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:union_shop/views/homepage.dart';
import 'package:union_shop/layout.dart';
import 'package:provider/provider.dart';
import 'package:fake_cloud_firestore/fake_cloud_firestore.dart';
import 'package:firebase_auth_mocks/firebase_auth_mocks.dart';
import 'package:union_shop/services/auth_service.dart';
import 'package:union_shop/models/cart_model.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  late FakeFirebaseFirestore fakeFirestore;
  late MockFirebaseAuth mockAuth;
  late AuthService authService;
  late CartModel cartModel;

  setUp(() {
    fakeFirestore = FakeFirebaseFirestore();
    mockAuth =
        MockFirebaseAuth(signedIn: true, mockUser: MockUser(uid: 'homeUser'));
    authService = AuthService(auth: mockAuth);
    cartModel = CartModel(auth: mockAuth, firestore: fakeFirestore);
  });

  Widget buildRouterApp(Widget child, {List<RouteBase>? extraRoutes}) {
    final routes = <RouteBase>[
      GoRoute(path: '/', builder: (context, state) => child),
      if (extraRoutes != null) ...extraRoutes,
    ];

    final router = GoRouter(routes: routes);

    return MultiProvider(
      providers: [
        Provider<AuthService>.value(value: authService),
        ChangeNotifierProvider<CartModel>.value(value: cartModel),
      ],
      child: MaterialApp.router(routerConfig: router),
    );
  }

  testWidgets('HomeScreen renders hero slider and footer', (tester) async {
    await tester
        .pumpWidget(buildRouterApp(const HomeScreen(enableProducts: false)));

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
    // FOOTER
    // ---------------------------------------------------------
    expect(find.text('Opening Hours'), findsOneWidget);
    expect(find.text('Latest Offers'), findsOneWidget);

    // Basic presence of footer content
    expect(find.text('Opening Hours'), findsOneWidget);
  });

  testWidgets('Squares navigate to their collections', (tester) async {
    final extraRoutes = [
      GoRoute(
        path: '/collections/clothing',
        builder: (context, state) =>
            const Scaffold(body: Center(child: Text('Clothing Collection'))),
      ),
      GoRoute(
        path: '/collections/merchandise',
        builder: (context, state) =>
            const Scaffold(body: Center(child: Text('Merchandise Collection'))),
      ),
    ];

    await tester.pumpWidget(buildRouterApp(
        const HomeScreen(enableProducts: false),
        extraRoutes: extraRoutes));
    await tester.pumpAndSettle();

    // Tap Clothing square
    final clothingLabel = find.text('Clothing');
    await tester.ensureVisible(clothingLabel);
    await tester.tap(clothingLabel);
    await tester.pumpAndSettle();
    expect(find.text('Clothing Collection'), findsOneWidget);

    // Rebuild home and tap Merchandise
    await tester.pumpWidget(buildRouterApp(
        const HomeScreen(enableProducts: false),
        extraRoutes: extraRoutes));
    await tester.pumpAndSettle();
    final merchLabel = find.text('Merchandise');
    await tester.ensureVisible(merchLabel);
    await tester.tap(merchLabel);
    await tester.pumpAndSettle();
    expect(find.text('Merchandise Collection'), findsOneWidget);
  });

  testWidgets('Hero slideshow arrows change the current slide', (tester) async {
    await tester
        .pumpWidget(buildRouterApp(const HomeScreen(enableProducts: false)));

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

  testWidgets('Full-page smoke: header, key sections, footer visible',
      (tester) async {
    await tester
        .pumpWidget(buildRouterApp(const HomeScreen(enableProducts: false)));
    await tester.pumpAndSettle();

    // Ensure key static sections are present
    expect(find.byType(AppHeader), findsOneWidget);
    await tester.ensureVisible(find.text('Add a Personal Touch'));
    expect(find.text('Add a Personal Touch'), findsOneWidget);
    expect(find.byType(AppFooter), findsOneWidget);

    // Ensure footer is reachable in scroll view
    await tester.ensureVisible(find.byType(AppFooter));
    expect(find.text('Opening Hours'), findsOneWidget);
  });
}
