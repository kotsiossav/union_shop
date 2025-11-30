import 'package:flutter/foundation.dart';

class CartItem {
  final String title;
  final String imageUrl;
  final double price;
  final String? category;
  final String? collection;
  int quantity;

  CartItem({
    required this.title,
    required this.imageUrl,
    required this.price,
    this.category,
    this.collection,
    this.quantity = 1,
  });

  double get totalPrice => price * quantity;
}

class CartModel extends ChangeNotifier {
  final Map<String, CartItem> _items = {};

  Map<String, CartItem> get items => {..._items};

  int get itemCount => _items.length;

  int get totalQuantity =>
      _items.values.fold(0, (sum, item) => sum + item.quantity);

  double get totalPrice =>
      _items.values.fold(0.0, (sum, item) => sum + item.totalPrice);

  void addProduct({
    required String title,
    required String imageUrl,
    required double price,
    String? category,
    String? collection,
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
      );
    }
    notifyListeners();
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
    }
  }

  void removeProductCompletely(String title) {
    final key = title.toLowerCase();
    _items.remove(key);
    notifyListeners();
  }

  void clearCart() {
    _items.clear();
    notifyListeners();
  }
}
