import 'package:fake_cloud_firestore/fake_cloud_firestore.dart';
import 'package:firebase_auth_mocks/firebase_auth_mocks.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import 'package:union_shop/layout.dart';
import 'package:union_shop/models/cart_model.dart';
import 'package:union_shop/views/cart_screen.dart';
import 'package:union_shop/services/auth_service.dart';
import 'package:union_shop/services/order_service.dart';

// Fake OrderService that avoids Firebase
class FakeOrderService extends OrderService {
  FakeOrderService()
      : super(
          firestore: FakeFirebaseFirestore(),
          auth: MockFirebaseAuth(
              signedIn: true, mockUser: MockUser(uid: 'orderUser')),
        );

  @override
  Future<String?> createOrderFromCart(CartModel cart) async {
    return 'order_123';
  }
}

void main() {
  late FakeFirebaseFirestore fakeFirestore;
  late MockFirebaseAuth mockAuth;
  late AuthService authService;
  late CartModel cartModel;

  setUp(() {
    fakeFirestore = FakeFirebaseFirestore();
    mockAuth =
        MockFirebaseAuth(signedIn: true, mockUser: MockUser(uid: 'test'));
    authService = AuthService(auth: mockAuth);
    cartModel = CartModel(auth: mockAuth, firestore: fakeFirestore);
  });

  Widget buildRouterApp(Widget child) {
    final router = GoRouter(
      routes: [
        GoRoute(path: '/', builder: (context, state) => child),
        GoRoute(
          path: '/order_history',
          builder: (context, state) =>
              const Scaffold(body: Center(child: Text('Order History'))),
        ),
      ],
    );

    return MultiProvider(
      providers: [
        Provider<AuthService>.value(value: authService),
        ChangeNotifierProvider<CartModel>.value(value: cartModel),
      ],
      child: MaterialApp.router(
        routerConfig: router,
      ),
    );
  }

  group('CartScreen rendering', () {
    testWidgets('shows header, title, and footer', (tester) async {
      await tester.pumpWidget(buildRouterApp(
          CartScreen(cart: cartModel, orderService: FakeOrderService())));
      await tester.pumpAndSettle();

      expect(find.byType(AppHeader), findsOneWidget);
      expect(find.text('Your Cart'), findsOneWidget);
      expect(find.byType(AppFooter), findsOneWidget);
    });

    testWidgets('empty cart shows friendly message', (tester) async {
      await tester.pumpWidget(buildRouterApp(
          CartScreen(cart: cartModel, orderService: FakeOrderService())));
      await tester.pumpAndSettle();

      expect(find.text('Your cart is currently empty.'), findsOneWidget);
      expect(find.text('Subtotal'), findsNothing);
    });
  });

  group('CartScreen interactions', () {
    testWidgets('renders items and subtotal when cart has products',
        (tester) async {
      cartModel.addProduct(
        title: 'Item A',
        imageUrl: 'assets/images/grey_hoodie.webp',
        price: 10.0,
      );
      cartModel.addProduct(
        title: 'Item B',
        imageUrl: 'assets/images/grey_hoodie.webp',
        price: 5.5,
      );

      await tester.pumpWidget(buildRouterApp(
          CartScreen(cart: cartModel, orderService: FakeOrderService())));
      await tester.pumpAndSettle();

      expect(find.text('Item A'), findsOneWidget);
      expect(find.text('Item B'), findsOneWidget);
      expect(find.text('Subtotal'), findsOneWidget);
      // The price appears twice now (in items count and subtotal)
      expect(find.text('£15.50'), findsNWidgets(2));
    });

    testWidgets('remove button deletes item from cart', (tester) async {
      cartModel.addProduct(
        title: 'Removable Item',
        imageUrl: 'assets/images/grey_hoodie.webp',
        price: 7.0,
      );

      await tester.pumpWidget(buildRouterApp(
          CartScreen(cart: cartModel, orderService: FakeOrderService())));
      await tester.pumpAndSettle();

      expect(find.text('Removable Item'), findsOneWidget);
      await tester.tap(find.widgetWithText(TextButton, 'Remove'));
      await tester.pumpAndSettle();

      expect(find.text('Removable Item'), findsNothing);
    });

    testWidgets('checkout places order, clears cart, and navigates',
        (tester) async {
      cartModel.addProduct(
        title: 'Checkout Item',
        imageUrl: 'assets/images/grey_hoodie.webp',
        price: 12.0,
      );

      await tester.pumpWidget(buildRouterApp(
          CartScreen(cart: cartModel, orderService: FakeOrderService())));
      await tester.pumpAndSettle();

      final checkoutButton = find.widgetWithText(ElevatedButton, 'CHECK OUT');
      expect(checkoutButton, findsOneWidget);

      // Ensure the button is visible in 800x600 test viewport
      await tester.ensureVisible(checkoutButton);
      await tester.tap(checkoutButton, warnIfMissed: false);
      // First pump to allow SnackBar to show before navigation settles
      await tester.pump();

      // Expect success snackbar
      expect(find.byType(SnackBar), findsOneWidget);
      expect(find.text('Order placed successfully!'), findsOneWidget);

      // Then settle and verify navigation occurred
      await tester.pumpAndSettle();
      expect(find.text('Order History'), findsOneWidget);

      // Cart should be cleared
      expect(cartModel.items.isEmpty, isTrue);
    });
  });
}
