import 'package:fake_cloud_firestore/fake_cloud_firestore.dart';
import 'package:firebase_auth_mocks/firebase_auth_mocks.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';
import 'package:union_shop/models/cart_model.dart';
import 'package:union_shop/services/auth_service.dart';
import 'package:union_shop/views/order_history_page.dart';
import 'package:union_shop/models/order_model.dart' as order_model;
import 'package:union_shop/services/order_service.dart';

class FakeOrderService implements OrderServiceBase {
  FakeOrderService({this.result, this.throwError = false, this.delayMs = 0});

  final List<order_model.Order>? result;
  final bool throwError;
  final int delayMs;

  @override
  Future<List<order_model.Order>> getUserOrders() async {
    if (delayMs > 0) {
      await Future.delayed(Duration(milliseconds: delayMs));
    }
    if (throwError) {
      throw Exception('boom');
    }
    return result ?? <order_model.Order>[];
  }

  @override
  Future<String?> createOrderFromCart(CartModel cart) async {
    throw UnimplementedError();
  }

  @override
  Stream<List<order_model.Order>> getUserOrdersStream() {
    return const Stream.empty();
  }
}

order_model.Order makeOrder({
  String id = 'abcdef123456',
  String status = 'completed',
  DateTime? date,
  List<order_model.OrderItem>? items,
  double total = 42.50,
}) {
  return order_model.Order(
    id: id,
    status: status,
    orderDate: date ?? DateTime(2024, 5, 10, 14, 7),
    items: items ??
        [
          order_model.OrderItem(
            imageUrl: 'assets/images/Bear.avif',
            title: 'Bear Tee',
            quantity: 2,
            price: 12.25,
            color: 'Black',
            size: 'M',
          ),
        ],
    totalAmount: total,
  );
}

void main() {
  late MockFirebaseAuth mockAuth;
  late FakeFirebaseFirestore mockFirestore;
  late AuthService authService;
  late CartModel cart;

  TestWidgetsFlutterBinding.ensureInitialized();

  setUp(() {
    mockAuth = MockFirebaseAuth();
    mockFirestore = FakeFirebaseFirestore();
    authService = AuthService(auth: mockAuth);
    cart = CartModel(auth: mockAuth, firestore: mockFirestore);
  });

  Widget wrapWithProviders(Widget child) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider<CartModel>.value(value: cart),
        Provider<AuthService>.value(value: authService),
      ],
      child: MaterialApp(home: child),
    );
  }

  group('OrderHistoryPage', () {
    testWidgets('shows loading spinner while fetching', (tester) async {
      final fake = FakeOrderService(result: [], delayMs: 300);
      await tester
          .pumpWidget(wrapWithProviders(OrderHistoryPage(orderService: fake)));

      // Initial frame shows CircularProgressIndicator inside FutureBuilder
      await tester.pump();
      expect(find.byType(CircularProgressIndicator), findsOneWidget);

      // Let the fake delay elapse to avoid pending timers
      await tester.pump(const Duration(milliseconds: 400));
    });

    testWidgets('shows empty state when no orders', (tester) async {
      final fake = FakeOrderService(result: []);
      await tester
          .pumpWidget(wrapWithProviders(OrderHistoryPage(orderService: fake)));
      await tester.pumpAndSettle();

      expect(find.text('Order History'), findsOneWidget);
      expect(find.text('No orders yet'), findsOneWidget);
      expect(find.text('Start shopping to see your order history'),
          findsOneWidget);
      // Header/Footer from layout
      expect(
          find.byType(AppBar), findsNothing); // page uses custom header/footer
      expect(find.textContaining('Order #'), findsNothing);
    });

    testWidgets('renders a list of orders', (tester) async {
      final orders = [
        makeOrder(id: '12345678abc', total: 24.50),
        makeOrder(id: '87654321def', total: 18.00, status: 'processing'),
      ];
      final fake = FakeOrderService(result: orders);

      await tester
          .pumpWidget(wrapWithProviders(OrderHistoryPage(orderService: fake)));
      await tester.pumpAndSettle();

      expect(find.text('Order History'), findsOneWidget);
      // Two cards
      expect(find.textContaining('Order #'), findsNWidgets(2));
      // Totals (may appear in item rows and total row)
      expect(find.textContaining('£24.50'), findsWidgets);
      expect(find.textContaining('£18.00'), findsWidgets);
      // Status chips
      expect(find.text('COMPLETED'), findsOneWidget);
      expect(find.text('PROCESSING'), findsOneWidget);
      // An item row exists
      expect(find.textContaining('Bear Tee'), findsWidgets);
      expect(find.textContaining('Quantity: 2'), findsWidgets);
    });

    testWidgets('shows error message on failure', (tester) async {
      final fake = FakeOrderService(throwError: true);
      await tester
          .pumpWidget(wrapWithProviders(OrderHistoryPage(orderService: fake)));
      await tester.pumpAndSettle();

      expect(find.textContaining('Error loading orders'), findsOneWidget);
    });
  });
}
