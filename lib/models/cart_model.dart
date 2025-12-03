import 'package:flutter/foundation.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

// Represents a single item in the shopping cart
// Stores product information, selection options (color/size), and quantity
class CartItem {
  final String title; // Product name
  final String imageUrl; // Path to product image (local asset or URL)
  final double price; // Price per unit (uses effective price if discounted)
  final String? category; // Optional product category (e.g., "Clothing")
  final String? collection; // Optional collection name (e.g., "essential-range")
  final String? color; // Optional selected color for clothing items
  final String? size; // Optional selected size for clothing items
  int quantity; // Number of this item in cart

  CartItem({
    required this.title,
    required this.imageUrl,
    required this.price,
    this.category,
    this.collection,
    this.color,
    this.size,
    this.quantity = 1, // Default quantity is 1
  });

  // Calculate total price for this cart item (price × quantity)
  double get totalPrice => price * quantity;

  // Convert CartItem to Map for Firestore storage
  // Used when saving cart to database
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

  // Create CartItem from Firestore Map data
  // Used when loading cart from database
  factory CartItem.fromMap(Map<String, dynamic> map) {
    return CartItem(
      title: map['title'] ?? '',
      imageUrl: map['imageUrl'] ?? '',
      // Convert price to double (handles both int and double from Firestore)
      price: (map['price'] ?? 0).toDouble(),
      category: map['category'],
      collection: map['collection'],
      color: map['color'],
      size: map['size'],
      quantity: map['quantity'] ?? 1,
    );
  }
}

// Shopping cart state management using ChangeNotifier for reactive updates
// Automatically syncs cart data with Firestore when user is signed in
// Provides methods to add, remove, and clear cart items
class CartModel extends ChangeNotifier {
  // Internal storage of cart items (key: lowercase title for case-insensitive matching)
  final Map<String, CartItem> _items = {};
  // Firebase Authentication instance to track user sign-in state
  final FirebaseAuth _auth;
  // Firestore instance for persisting cart data to database
  final FirebaseFirestore _firestore;

  // Constructor with optional dependency injection for testing
  CartModel({
    FirebaseAuth? auth,
    FirebaseFirestore? firestore,
  })  : _auth = auth ?? FirebaseAuth.instance,
        _firestore = firestore ?? FirebaseFirestore.instance {
    // Listen to authentication state changes
    // Load cart from Firestore when user signs in
    // Clear cart when user signs out
    _auth.authStateChanges().listen((user) {
      if (user != null) {
        _loadCartFromFirestore();
      } else {
        _items.clear();
        notifyListeners();
      }
    });
  }

  // Get a copy of all cart items (prevents external modification)
  Map<String, CartItem> get items => {..._items};

  // Get number of unique items in cart
  int get itemCount => _items.length;

  // Get total quantity of all items (sum of all quantities)
  int get totalQuantity =>
      _items.values.fold(0, (sum, item) => sum + item.quantity);

  // Get total price of all items in cart
  double get totalPrice =>
      _items.values.fold(0.0, (sum, item) => sum + item.totalPrice);

  // Load cart items from Firestore for current user
  // Called automatically when user signs in
  Future<void> _loadCartFromFirestore() async {
    final user = _auth.currentUser;
    if (user == null) return;

    try {
      // Fetch all cart items from user's cart subcollection
      final snapshot = await _firestore
          .collection('users')
          .doc(user.uid)
          .collection('cart')
          .get();

      // Clear existing cart and populate with Firestore data
      _items.clear();
      for (var doc in snapshot.docs) {
        final item = CartItem.fromMap(doc.data());
        // Use lowercase title as key for case-insensitive matching
        _items[item.title.toLowerCase()] = item;
      }
      // Notify listeners to update UI with loaded cart
      notifyListeners();
    } catch (e) {
      debugPrint('Error loading cart: $e');
    }
  }

  // Save current cart state to Firestore
  // Called after any cart modification (add/remove/clear)
  Future<void> _saveCartToFirestore() async {
    final user = _auth.currentUser;
    if (user == null) return;

    try {
      final cartRef =
          _firestore.collection('users').doc(user.uid).collection('cart');

      // Delete all existing cart items first
      final existingDocs = await cartRef.get();
      for (var doc in existingDocs.docs) {
        await doc.reference.delete();
      }

      // Add current cart items to Firestore
      for (var item in _items.values) {
        await cartRef.add(item.toMap());
      }
    } catch (e) {
      debugPrint('Error saving cart: $e');
    }
  }

  // Add a product to the cart or increment quantity if already exists
  // Uses lowercase title for case-insensitive matching
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
      // Product already in cart - increment quantity
      _items[key]!.quantity++;
    } else {
      // New product - add to cart
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
    // Notify listeners to update UI and save to Firestore
    notifyListeners();
    _saveCartToFirestore();
  }

  // Decrease quantity of a product or remove if quantity reaches 0
  void removeProduct(String title) {
    final key = title.toLowerCase();

    if (_items.containsKey(key)) {
      if (_items[key]!.quantity > 1) {
        // Decrease quantity by 1
        _items[key]!.quantity--;
      } else {
        // Remove item if quantity would be 0
        _items.remove(key);
      }
      notifyListeners();
      _saveCartToFirestore();
    }
  }

  // Remove a product completely from cart regardless of quantity
  void removeProductCompletely(String title) {
    final key = title.toLowerCase();
    _items.remove(key);
    notifyListeners();
    _saveCartToFirestore();
  }

  // Remove all items from cart
  // Called after successful checkout
  void clearCart() {
    _items.clear();
    notifyListeners();
    _saveCartToFirestore();
  }
}
