import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../models/order_model.dart' as order_model;
import '../models/cart_model.dart';

// Abstract base class defining the order service interface
// Allows for dependency injection and easier testing
abstract class OrderServiceBase {
  Future<String?> createOrderFromCart(CartModel cart);
  Future<List<order_model.Order>> getUserOrders();
  Stream<List<order_model.Order>> getUserOrdersStream();
}

// Concrete implementation of order service using Firestore
// Handles order creation, retrieval, and history management
class OrderService implements OrderServiceBase {
  final FirebaseFirestore _firestore;
  final FirebaseAuth _auth;

  // Constructor with optional dependency injection for testing
  OrderService({
    FirebaseFirestore? firestore,
    FirebaseAuth? auth,
  })  : _firestore = firestore ?? FirebaseFirestore.instance,
        _auth = auth ?? FirebaseAuth.instance;

  // Create a new order from the current cart contents
  // Converts CartItems to OrderItems and saves to Firestore
  // Returns the Firestore document ID of the created order
  @override
  Future<String?> createOrderFromCart(CartModel cart) async {
    final user = _auth.currentUser;
    if (user == null) {
      throw Exception('User must be signed in to place an order');
    }

    if (cart.items.isEmpty) {
      throw Exception('Cart is empty');
    }

    try {
      // Convert each cart item to an order item (snapshot of cart at checkout time)
      final orderItems = cart.items.values.map((cartItem) {
        return order_model.OrderItem(
          title: cartItem.title,
          imageUrl: cartItem.imageUrl,
          price: cartItem.price,
          category: cartItem.category,
          collection: cartItem.collection,
          color: cartItem.color,
          size: cartItem.size,
          quantity: cartItem.quantity,
        );
      }).toList();

      // Create order object with current timestamp
      final order = order_model.Order(
        id: '', // ID will be set by Firestore
        items: orderItems,
        totalAmount: cart.totalPrice,
        orderDate: DateTime.now(),
        status: 'completed',
      );

      // Save order to Firestore under user's orders subcollection
      final docRef = await _firestore
          .collection('users')
          .doc(user.uid)
          .collection('orders')
          .add(order.toMap());

      return docRef.id;
    } catch (e) {
      throw Exception('Failed to create order: $e');
    }
  }

  // Get all orders for the current user as a list
  // Returns orders sorted by date (most recent first)
  // Returns empty list if user is not signed in
  @override
  Future<List<order_model.Order>> getUserOrders() async {
    final user = _auth.currentUser;
    if (user == null) {
      return [];
    }

    try {
      // Fetch all orders from user's orders subcollection
      final snapshot = await _firestore
          .collection('users')
          .doc(user.uid)
          .collection('orders')
          .orderBy('orderDate', descending: true)
          .get();

      // Convert Firestore documents to Order objects
      return snapshot.docs
          .map((doc) => order_model.Order.fromFirestore(doc))
          .toList();
    } catch (e) {
      throw Exception('Failed to load orders: $e');
    }
  }

  // Get real-time stream of user's orders
  // Automatically updates when new orders are added or existing orders change
  // Useful for order history page with live updates
  @override
  Stream<List<order_model.Order>> getUserOrdersStream() {
    final user = _auth.currentUser;
    if (user == null) {
      return Stream.value([]);
    }

    // Return stream that emits updated order list whenever Firestore changes
    return _firestore
        .collection('users')
        .doc(user.uid)
        .collection('orders')
        .orderBy('orderDate', descending: true)
        .snapshots()
        .map((snapshot) => snapshot.docs
            .map((doc) => order_model.Order.fromFirestore(doc))
            .toList());
  }
}
