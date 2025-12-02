import 'package:flutter/foundation.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class CartItem {
  final String title;
  final String imageUrl;
  final double price;
  final String? category;
  final String? collection;
  final String? color;
  final String? size;
  int quantity;

  CartItem({
    required this.title,
    required this.imageUrl,
    required this.price,
    this.category,
    this.collection,
    this.color,
    this.size,
    this.quantity = 1,
  });

  double get totalPrice => price * quantity;

  // Convert CartItem to Map for Firestore
  Map<String, dynamic> toMap() {
    return {
      'title': title,
      'imageUrl': imageUrl,
      'price': price,
      'category': category,
      'collection': collection,
      'color': color,
      'size': size,
      'quantity': quantity,
    };
  }

  // Create CartItem from Firestore Map
  factory CartItem.fromMap(Map<String, dynamic> map) {
    return CartItem(
      title: map['title'] ?? '',
      imageUrl: map['imageUrl'] ?? '',
      price: (map['price'] ?? 0).toDouble(),
      category: map['category'],
      collection: map['collection'],
      color: map['color'],
      size: map['size'],
      quantity: map['quantity'] ?? 1,
    );
  }
}

class CartModel extends ChangeNotifier {
  final Map<String, CartItem> _items = {};
  final FirebaseAuth _auth;
  final FirebaseFirestore _firestore;

  CartModel({
    FirebaseAuth? auth,
    FirebaseFirestore? firestore,
  })  : _auth = auth ?? FirebaseAuth.instance,
        _firestore = firestore ?? FirebaseFirestore.instance {
    // Listen to auth state changes and load cart when user signs in
    _auth.authStateChanges().listen((user) {
      if (user != null) {
        _loadCartFromFirestore();
      } else {
        _items.clear();
        notifyListeners();
      }
    });
  }

  Map<String, CartItem> get items => {..._items};

  int get itemCount => _items.length;

  int get totalQuantity =>
      _items.values.fold(0, (sum, item) => sum + item.quantity);

  double get totalPrice =>
      _items.values.fold(0.0, (sum, item) => sum + item.totalPrice);

  // Load cart from Firestore
  Future<void> _loadCartFromFirestore() async {
    final user = _auth.currentUser;
    if (user == null) return;

    try {
      final snapshot = await _firestore
          .collection('users')
          .doc(user.uid)
          .collection('cart')
          .get();

      _items.clear();
      for (var doc in snapshot.docs) {
        final item = CartItem.fromMap(doc.data());
        _items[item.title.toLowerCase()] = item;
      }
      notifyListeners();
    } catch (e) {
      debugPrint('Error loading cart: $e');
    }
  }

  // Save cart to Firestore
  Future<void> _saveCartToFirestore() async {
    final user = _auth.currentUser;
    if (user == null) return;

    try {
      final cartRef =
          _firestore.collection('users').doc(user.uid).collection('cart');

      // Delete all existing cart items
      final existingDocs = await cartRef.get();
      for (var doc in existingDocs.docs) {
        await doc.reference.delete();
      }

      // Add current cart items
      for (var item in _items.values) {
        await cartRef.add(item.toMap());
      }
    } catch (e) {
      debugPrint('Error saving cart: $e');
    }
  }

  void addProduct({
    required String title,
    required String imageUrl,
    required double price,
    String? category,
    String? collection,
    String? color,
    String? size,
  }) {
    final key = title.toLowerCase();

    if (_items.containsKey(key)) {
      _items[key]!.quantity++;
    } else {
      _items[key] = CartItem(
        title: title,
        imageUrl: imageUrl,
        price: price,
        category: category,
        collection: collection,
        color: color,
        size: size,
      );
    }
    notifyListeners();
    _saveCartToFirestore();
  }

  void removeProduct(String title) {
    final key = title.toLowerCase();

    if (_items.containsKey(key)) {
      if (_items[key]!.quantity > 1) {
        _items[key]!.quantity--;
      } else {
        _items.remove(key);
      }
      notifyListeners();
      _saveCartToFirestore();
    }
  }

  void removeProductCompletely(String title) {
    final key = title.toLowerCase();
    _items.remove(key);
    notifyListeners();
    _saveCartToFirestore();
  }

  void clearCart() {
    _items.clear();
    notifyListeners();
    _saveCartToFirestore();
  }
}
