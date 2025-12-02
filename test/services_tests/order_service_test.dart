import 'package:flutter_test/flutter_test.dart';
import 'package:union_shop/services/order_service.dart';
import 'package:union_shop/models/cart_model.dart';
import 'package:union_shop/models/order_model.dart' as order_model;
import 'package:fake_cloud_firestore/fake_cloud_firestore.dart';
import 'package:firebase_auth_mocks/firebase_auth_mocks.dart';

void main() {
  group('OrderService', () {
    late OrderService orderService;
    late FakeFirebaseFirestore mockFirestore;
    late MockFirebaseAuth mockAuth;
    late CartModel cart;

    setUp(() {
      mockFirestore = FakeFirebaseFirestore();
      mockAuth = MockFirebaseAuth(signedIn: true);
      orderService = OrderService(firestore: mockFirestore, auth: mockAuth);
      cart = CartModel(auth: mockAuth, firestore: mockFirestore);
    });

    group('Create Order from Cart', () {
      test('should create order successfully with cart items', () async {
        // Add items to cart
        cart.addProduct(
          title: 'Test Product',
          imageUrl: 'https://example.com/product.jpg',
          price: 29.99,
          category: 'Merchandise',
        );

        final orderId = await orderService.createOrderFromCart(cart);

        expect(orderId, isNotNull);
        expect(orderId, isNotEmpty);
      });

      test('should throw exception when user is not signed in', () async {
        final unauthAuth = MockFirebaseAuth(signedIn: false);
        final unauthService =
            OrderService(firestore: mockFirestore, auth: unauthAuth);
        final unauthCart =
            CartModel(auth: unauthAuth, firestore: mockFirestore);

        unauthCart.addProduct(
          title: 'Product',
          imageUrl: 'url',
          price: 10.0,
        );

        expect(
          () => unauthService.createOrderFromCart(unauthCart),
          throwsA(isA<Exception>()),
        );
      });

      test('should throw exception when cart is empty', () async {
        expect(
          () => orderService.createOrderFromCart(cart),
          throwsA(isA<Exception>()),
        );
      });

      test('should convert cart items to order items correctly', () async {
        cart.addProduct(
          title: 'Hoodie',
          imageUrl: 'https://example.com/hoodie.jpg',
          price: 45.00,
          category: 'Clothing',
          collection: 'Essential Range',
          color: 'Black',
          size: 'M',
        );

        await orderService.createOrderFromCart(cart);

        final orders = await orderService.getUserOrders();
        expect(orders.length, 1);
        expect(orders[0].items[0].title, 'Hoodie');
        expect(orders[0].items[0].price, 45.00);
        expect(orders[0].items[0].color, 'Black');
        expect(orders[0].items[0].size, 'M');
      });

      test('should create order with correct total amount', () async {
        cart.addProduct(
          title: 'Product 1',
          imageUrl: 'url1',
          price: 20.00,
        );
        cart.addProduct(
          title: 'Product 2',
          imageUrl: 'url2',
          price: 30.00,
        );

        await orderService.createOrderFromCart(cart);

        final orders = await orderService.getUserOrders();
        expect(orders[0].totalAmount, 50.00);
      });

      test('should create order with multiple items', () async {
        cart.addProduct(
          title: 'Item 1',
          imageUrl: 'url1',
          price: 15.00,
        );
        cart.addProduct(
          title: 'Item 2',
          imageUrl: 'url2',
          price: 25.00,
        );
        cart.addProduct(
          title: 'Item 3',
          imageUrl: 'url3',
          price: 35.00,
        );

        await orderService.createOrderFromCart(cart);

        final orders = await orderService.getUserOrders();
        expect(orders[0].items.length, 3);
      });

      test('should set order status to completed', () async {
        cart.addProduct(
          title: 'Product',
          imageUrl: 'url',
          price: 10.0,
        );

        await orderService.createOrderFromCart(cart);

        final orders = await orderService.getUserOrders();
        expect(orders[0].status, 'completed');
      });

      test('should preserve item quantities in order', () async {
        cart.addProduct(
          title: 'Product',
          imageUrl: 'url',
          price: 10.0,
        );
        // Increase quantity
        cart.items.values.first.quantity = 5;

        await orderService.createOrderFromCart(cart);

        final orders = await orderService.getUserOrders();
        expect(orders[0].items[0].quantity, 5);
      });
    });

    group('Get User Orders', () {
      test('should return empty list when user is not signed in', () async {
        final unauthAuth = MockFirebaseAuth(signedIn: false);
        final unauthService =
            OrderService(firestore: mockFirestore, auth: unauthAuth);

        final orders = await unauthService.getUserOrders();

        expect(orders, isEmpty);
      });

      test('should return empty list when user has no orders', () async {
        final orders = await orderService.getUserOrders();

        expect(orders, isEmpty);
      });

      test('should return list of orders', () async {
        // Create first order
        cart.addProduct(
          title: 'Product 1',
          imageUrl: 'url1',
          price: 20.0,
        );
        await orderService.createOrderFromCart(cart);

        // Clear cart and create second order
        cart.clearCart();
        cart.addProduct(
          title: 'Product 2',
          imageUrl: 'url2',
          price: 30.0,
        );
        await orderService.createOrderFromCart(cart);

        final orders = await orderService.getUserOrders();

        expect(orders.length, 2);
      });

      test('should return orders in descending date order', () async {
        // Create first order
        cart.addProduct(title: 'First', imageUrl: 'url', price: 10.0);
        await orderService.createOrderFromCart(cart);
        await Future.delayed(const Duration(milliseconds: 10));

        // Create second order
        cart.clearCart();
        cart.addProduct(title: 'Second', imageUrl: 'url', price: 20.0);
        await orderService.createOrderFromCart(cart);

        final orders = await orderService.getUserOrders();

        expect(orders[0].items[0].title, 'Second');
        expect(orders[1].items[0].title, 'First');
      });

      test('should return Order objects with all properties', () async {
        cart.addProduct(
          title: 'Complete Product',
          imageUrl: 'url',
          price: 50.0,
          category: 'Clothing',
          color: 'Red',
          size: 'L',
        );

        await orderService.createOrderFromCart(cart);
        final orders = await orderService.getUserOrders();

        expect(orders[0].id, isNotEmpty);
        expect(orders[0].items, isNotEmpty);
        expect(orders[0].totalAmount, 50.0);
        expect(orders[0].orderDate, isA<DateTime>());
        expect(orders[0].status, 'completed');
      });
    });

    group('Get User Orders Stream', () {
      test('should return empty stream when user is not signed in', () async {
        final unauthAuth = MockFirebaseAuth(signedIn: false);
        final unauthService =
            OrderService(firestore: mockFirestore, auth: unauthAuth);

        final stream = unauthService.getUserOrdersStream();
        final orders = await stream.first;

        expect(orders, isEmpty);
      });

      test('should emit list of orders', () async {
        cart.addProduct(
          title: 'Streaming Product',
          imageUrl: 'url',
          price: 25.0,
        );
        await orderService.createOrderFromCart(cart);

        final stream = orderService.getUserOrdersStream();
        final orders = await stream.first;

        expect(orders.length, 1);
        expect(orders[0].items[0].title, 'Streaming Product');
      });

      test('should emit updates when new orders are added', () async {
        final stream = orderService.getUserOrdersStream();
        final ordersList = <List<order_model.Order>>[];

        final subscription = stream.listen((orders) {
          ordersList.add(orders);
        });

        await Future.delayed(const Duration(milliseconds: 100));

        // Add first order
        cart.addProduct(title: 'Product 1', imageUrl: 'url', price: 10.0);
        await orderService.createOrderFromCart(cart);

        await Future.delayed(const Duration(milliseconds: 100));

        await subscription.cancel();

        expect(ordersList.length, greaterThan(0));
      });

      test('should return stream with Order objects', () async {
        cart.addProduct(title: 'Stream Test', imageUrl: 'url', price: 15.0);
        await orderService.createOrderFromCart(cart);

        final stream = orderService.getUserOrdersStream();
        final orders = await stream.first;

        expect(orders[0], isA<order_model.Order>());
        expect(orders[0].items[0].title, 'Stream Test');
      });
    });

    group('Integration Tests', () {
      test('should handle complete order flow', () async {
        // Add items to cart
        cart.addProduct(
          title: 'Product A',
          imageUrl: 'urlA',
          price: 30.0,
        );
        cart.addProduct(
          title: 'Product B',
          imageUrl: 'urlB',
          price: 20.0,
        );

        // Create order
        final orderId = await orderService.createOrderFromCart(cart);
        expect(orderId, isNotNull);

        // Retrieve orders
        final orders = await orderService.getUserOrders();
        expect(orders.length, 1);
        expect(orders[0].items.length, 2);
        expect(orders[0].totalAmount, 50.0);
      });

      test('should handle multiple sequential orders', () async {
        // First order
        cart.addProduct(title: 'Order 1', imageUrl: 'url', price: 10.0);
        await orderService.createOrderFromCart(cart);

        // Second order
        cart.clearCart();
        cart.addProduct(title: 'Order 2', imageUrl: 'url', price: 20.0);
        await orderService.createOrderFromCart(cart);

        // Third order
        cart.clearCart();
        cart.addProduct(title: 'Order 3', imageUrl: 'url', price: 30.0);
        await orderService.createOrderFromCart(cart);

        final orders = await orderService.getUserOrders();
        expect(orders.length, 3);
      });

      test('should preserve order data integrity', () async {
        const productTitle = 'Integrity Test Product';
        const productPrice = 99.99;
        const productColor = 'Navy';
        const productSize = 'XL';

        cart.addProduct(
          title: productTitle,
          imageUrl: 'test-url',
          price: productPrice,
          category: 'Clothing',
          color: productColor,
          size: productSize,
        );

        await orderService.createOrderFromCart(cart);
        final orders = await orderService.getUserOrders();

        final item = orders[0].items[0];
        expect(item.title, productTitle);
        expect(item.price, productPrice);
        expect(item.color, productColor);
        expect(item.size, productSize);
      });
    });
  });
}
