import 'package:flutter_test/flutter_test.dart';
import 'package:union_shop/models/cart_model.dart';

void main() {
  group('CartItem', () {
    test('should create a CartItem with required fields', () {
      final item = CartItem(
        title: 'Test Product',
        imageUrl: 'https://example.com/image.jpg',
        price: 25.99,
      );

      expect(item.title, 'Test Product');
      expect(item.imageUrl, 'https://example.com/image.jpg');
      expect(item.price, 25.99);
      expect(item.quantity, 1);
      expect(item.category, isNull);
      expect(item.collection, isNull);
      expect(item.color, isNull);
      expect(item.size, isNull);
    });

    test('should create a CartItem with all fields', () {
      final item = CartItem(
        title: 'Blue Hoodie',
        imageUrl: 'https://example.com/hoodie.jpg',
        price: 45.00,
        category: 'clothing',
        collection: 'essential-range',
        color: 'Blue',
        size: 'M',
        quantity: 3,
      );

      expect(item.title, 'Blue Hoodie');
      expect(item.imageUrl, 'https://example.com/hoodie.jpg');
      expect(item.price, 45.00);
      expect(item.category, 'clothing');
      expect(item.collection, 'essential-range');
      expect(item.color, 'Blue');
      expect(item.size, 'M');
      expect(item.quantity, 3);
    });

    test('should calculate totalPrice correctly', () {
      final item = CartItem(
        title: 'T-Shirt',
        imageUrl: 'https://example.com/tshirt.jpg',
        price: 15.00,
        quantity: 4,
      );

      expect(item.totalPrice, 60.00);
    });

    test('should update totalPrice when quantity changes', () {
      final item = CartItem(
        title: 'T-Shirt',
        imageUrl: 'https://example.com/tshirt.jpg',
        price: 15.00,
        quantity: 2,
      );

      expect(item.totalPrice, 30.00);

      item.quantity = 5;
      expect(item.totalPrice, 75.00);
    });

    test('should convert CartItem to Map correctly', () {
      final item = CartItem(
        title: 'Hoodie',
        imageUrl: 'https://example.com/hoodie.jpg',
        price: 35.99,
        category: 'clothing',
        collection: 'signature-range',
        color: 'Red',
        size: 'L',
        quantity: 2,
      );

      final map = item.toMap();

      expect(map['title'], 'Hoodie');
      expect(map['imageUrl'], 'https://example.com/hoodie.jpg');
      expect(map['price'], 35.99);
      expect(map['category'], 'clothing');
      expect(map['collection'], 'signature-range');
      expect(map['color'], 'Red');
      expect(map['size'], 'L');
      expect(map['quantity'], 2);
    });

    test('should create CartItem from Map correctly', () {
      final map = {
        'title': 'Sweatshirt',
        'imageUrl': 'https://example.com/sweatshirt.jpg',
        'price': 40.00,
        'category': 'clothing',
        'collection': 'essential-range',
        'color': 'Black',
        'size': 'XL',
        'quantity': 1,
      };

      final item = CartItem.fromMap(map);

      expect(item.title, 'Sweatshirt');
      expect(item.imageUrl, 'https://example.com/sweatshirt.jpg');
      expect(item.price, 40.00);
      expect(item.category, 'clothing');
      expect(item.collection, 'essential-range');
      expect(item.color, 'Black');
      expect(item.size, 'XL');
      expect(item.quantity, 1);
    });

    test('should handle missing optional fields when creating from Map', () {
      final map = {
        'title': 'Basic Tee',
        'imageUrl': 'https://example.com/tee.jpg',
        'price': 20.00,
      };

      final item = CartItem.fromMap(map);

      expect(item.title, 'Basic Tee');
      expect(item.imageUrl, 'https://example.com/tee.jpg');
      expect(item.price, 20.00);
      expect(item.category, isNull);
      expect(item.collection, isNull);
      expect(item.color, isNull);
      expect(item.size, isNull);
      expect(item.quantity, 1);
    });

    test('should handle missing price as 0 when creating from Map', () {
      final map = {
        'title': 'Free Item',
        'imageUrl': 'https://example.com/free.jpg',
      };

      final item = CartItem.fromMap(map);

      expect(item.price, 0.0);
    });

    test('should convert integer price to double', () {
      final map = {
        'title': 'Product',
        'imageUrl': 'https://example.com/product.jpg',
        'price': 30, // integer
      };

      final item = CartItem.fromMap(map);

      expect(item.price, 30.0);
      expect(item.price, isA<double>());
    });
  });

  // Note: CartModel tests are skipped because they require Firebase initialization.
  // These tests would need integration testing or proper mocking libraries.
  // The CartItem class (which handles the data structure) is fully tested above.

  // To test CartModel in the future, consider:
  // 1. Using fake_cloud_firestore and firebase_auth_mocks packages
  // 2. Refactoring CartModel to use dependency injection for easier testing
  // 3. Running integration tests with Firebase Test Lab
}
