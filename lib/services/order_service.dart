import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../models/order_model.dart' as order_model;
import '../models/cart_model.dart';

class OrderService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  // Create order from cart
  Future<String?> createOrderFromCart(CartModel cart) async {
    final user = _auth.currentUser;
    if (user == null) {
      throw Exception('User must be signed in to place an order');
    }

    if (cart.items.isEmpty) {
      throw Exception('Cart is empty');
    }

    try {
      // Convert cart items to order items
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

      // Create order
      final order = order_model.Order(
        id: '',
        items: orderItems,
        totalAmount: cart.totalPrice,
        orderDate: DateTime.now(),
        status: 'completed',
      );

      // Save to Firestore
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

  // Get user's order history
  Future<List<order_model.Order>> getUserOrders() async {
    final user = _auth.currentUser;
    if (user == null) {
      return [];
    }

    try {
      final snapshot = await _firestore
          .collection('users')
          .doc(user.uid)
          .collection('orders')
          .orderBy('orderDate', descending: true)
          .get();

      return snapshot.docs
          .map((doc) => order_model.Order.fromFirestore(doc))
          .toList();
    } catch (e) {
      throw Exception('Failed to load orders: $e');
    }
  }

  // Get orders stream for real-time updates
  Stream<List<order_model.Order>> getUserOrdersStream() {
    final user = _auth.currentUser;
    if (user == null) {
      return Stream.value([]);
    }

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
