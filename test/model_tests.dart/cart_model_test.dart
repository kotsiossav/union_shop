import 'package:flutter_test/flutter_test.dart';
import 'package:union_shop/models/cart_model.dart';
import 'package:fake_cloud_firestore/fake_cloud_firestore.dart';
import 'package:firebase_auth_mocks/firebase_auth_mocks.dart';

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

  group('CartModel - Basic Operations', () {
    late CartModel cart;
    late MockFirebaseAuth mockAuth;
    late FakeFirebaseFirestore mockFirestore;
    late MockUser mockUser;

    setUp(() async {
      // Create mock user
      mockUser = MockUser(
        uid: 'test-user-id',
        email: 'test@example.com',
        displayName: 'Test User',
      );

      // Create mock auth (signed in)
      mockAuth = MockFirebaseAuth(mockUser: mockUser, signedIn: true);

      // Create fake firestore
      mockFirestore = FakeFirebaseFirestore();

      // Create CartModel with mocked dependencies
      cart = CartModel(auth: mockAuth, firestore: mockFirestore);

      // Wait for initialization
      await Future.delayed(Duration.zero);
    });

    test('should start with empty cart', () {
      expect(cart.items, isEmpty);
      expect(cart.itemCount, 0);
      expect(cart.totalQuantity, 0);
      expect(cart.totalPrice, 0.0);
    });

    test('should add a product to cart', () async {
      cart.addProduct(
        title: 'Test Hoodie',
        imageUrl: 'https://example.com/hoodie.jpg',
        price: 45.00,
      );

      await Future.delayed(Duration(milliseconds: 100));

      expect(cart.itemCount, 1);
      expect(cart.totalQuantity, 1);
      expect(cart.totalPrice, 45.00);
      expect(cart.items.containsKey('test hoodie'), true);
    });

    test('should add product with all optional parameters', () async {
      cart.addProduct(
        title: 'Premium Hoodie',
        imageUrl: 'https://example.com/premium.jpg',
        price: 55.00,
        category: 'clothing',
        collection: 'signature-range',
        color: 'Navy',
        size: 'L',
      );

      await Future.delayed(Duration(milliseconds: 100));

      final item = cart
          .items['premium hoodie_navy_l']; // uniqueKey includes color and size
      expect(item, isNotNull);
      expect(item!.category, 'clothing');
      expect(item.collection, 'signature-range');
      expect(item.color, 'Navy');
      expect(item.size, 'L');
    });

    test('should increment quantity when adding existing product', () async {
      cart.addProduct(
        title: 'T-Shirt',
        imageUrl: 'https://example.com/tshirt.jpg',
        price: 20.00,
      );

      await Future.delayed(Duration(milliseconds: 100));

      cart.addProduct(
        title: 'T-Shirt',
        imageUrl: 'https://example.com/tshirt.jpg',
        price: 20.00,
      );

      await Future.delayed(Duration(milliseconds: 100));

      expect(cart.itemCount, 1);
      expect(cart.totalQuantity, 2);
      expect(cart.totalPrice, 40.00);
      expect(cart.items['t-shirt']!.quantity, 2);
    });

    test('should handle case-insensitive product titles', () async {
      cart.addProduct(
        title: 'HOODIE',
        imageUrl: 'https://example.com/hoodie.jpg',
        price: 45.00,
      );

      await Future.delayed(Duration(milliseconds: 100));

      cart.addProduct(
        title: 'hoodie',
        imageUrl: 'https://example.com/hoodie.jpg',
        price: 45.00,
      );

      await Future.delayed(Duration(milliseconds: 100));

      expect(cart.itemCount, 1);
      expect(cart.items['hoodie']!.quantity, 2);
    });

    test('should add multiple different products', () async {
      cart.addProduct(
        title: 'Hoodie',
        imageUrl: 'https://example.com/hoodie.jpg',
        price: 45.00,
      );

      cart.addProduct(
        title: 'T-Shirt',
        imageUrl: 'https://example.com/tshirt.jpg',
        price: 20.00,
      );

      cart.addProduct(
        title: 'Sweatshirt',
        imageUrl: 'https://example.com/sweatshirt.jpg',
        price: 35.00,
      );

      await Future.delayed(Duration(milliseconds: 100));

      expect(cart.itemCount, 3);
      expect(cart.totalQuantity, 3);
      expect(cart.totalPrice, 100.00);
    });

    test('should calculate totalPrice correctly with multiple items', () async {
      cart.addProduct(
        title: 'Item 1',
        imageUrl: 'https://example.com/1.jpg',
        price: 10.00,
      );
      cart.addProduct(
        title: 'Item 1',
        imageUrl: 'https://example.com/1.jpg',
        price: 10.00,
      );

      cart.addProduct(
        title: 'Item 2',
        imageUrl: 'https://example.com/2.jpg',
        price: 25.50,
      );

      cart.addProduct(
        title: 'Item 3',
        imageUrl: 'https://example.com/3.jpg',
        price: 15.75,
      );
      cart.addProduct(
        title: 'Item 3',
        imageUrl: 'https://example.com/3.jpg',
        price: 15.75,
      );
      cart.addProduct(
        title: 'Item 3',
        imageUrl: 'https://example.com/3.jpg',
        price: 15.75,
      );

      await Future.delayed(Duration(milliseconds: 100));

      // 2x10 + 1x25.50 + 3x15.75 = 20 + 25.50 + 47.25 = 92.75
      expect(cart.totalQuantity, 6);
      expect(cart.totalPrice, 92.75);
    });

    test('should remove one quantity when removeProduct is called', () async {
      cart.addProduct(
        title: 'Hoodie',
        imageUrl: 'https://example.com/hoodie.jpg',
        price: 45.00,
      );
      cart.addProduct(
        title: 'Hoodie',
        imageUrl: 'https://example.com/hoodie.jpg',
        price: 45.00,
      );
      cart.addProduct(
        title: 'Hoodie',
        imageUrl: 'https://example.com/hoodie.jpg',
        price: 45.00,
      );

      await Future.delayed(Duration(milliseconds: 100));

      expect(cart.items['hoodie']!.quantity, 3);

      cart.removeProduct('hoodie'); // Use uniqueKey (lowercase)

      await Future.delayed(Duration(milliseconds: 100));

      expect(cart.items['hoodie']!.quantity, 2);
      expect(cart.totalQuantity, 2);
      expect(cart.totalPrice, 90.00);
    });

    test('should remove item completely when quantity reaches 0', () async {
      cart.addProduct(
        title: 'T-Shirt',
        imageUrl: 'https://example.com/tshirt.jpg',
        price: 20.00,
      );

      await Future.delayed(Duration(milliseconds: 100));

      cart.removeProduct('t-shirt'); // Use uniqueKey (lowercase)

      await Future.delayed(Duration(milliseconds: 100));

      expect(cart.itemCount, 0);
      expect(cart.items.containsKey('t-shirt'), false);
    });

    test('should handle removeProduct with case-insensitive title', () async {
      cart.addProduct(
        title: 'HOODIE',
        imageUrl: 'https://example.com/hoodie.jpg',
        price: 45.00,
      );
      cart.addProduct(
        title: 'HOODIE',
        imageUrl: 'https://example.com/hoodie.jpg',
        price: 45.00,
      );

      await Future.delayed(Duration(milliseconds: 100));

      cart.removeProduct('hoodie');

      await Future.delayed(Duration(milliseconds: 100));

      expect(cart.items['hoodie']!.quantity, 1);
    });

    test('should do nothing when removing non-existent product', () async {
      cart.addProduct(
        title: 'Hoodie',
        imageUrl: 'https://example.com/hoodie.jpg',
        price: 45.00,
      );

      await Future.delayed(Duration(milliseconds: 100));

      cart.removeProduct('non-existent product'); // Use uniqueKey (lowercase)

      await Future.delayed(Duration(milliseconds: 100));

      expect(cart.itemCount, 1);
      expect(cart.totalQuantity, 1);
    });

    test('should remove product completely with removeProductCompletely',
        () async {
      cart.addProduct(
        title: 'Hoodie',
        imageUrl: 'https://example.com/hoodie.jpg',
        price: 45.00,
      );
      cart.addProduct(
        title: 'Hoodie',
        imageUrl: 'https://example.com/hoodie.jpg',
        price: 45.00,
      );
      cart.addProduct(
        title: 'Hoodie',
        imageUrl: 'https://example.com/hoodie.jpg',
        price: 45.00,
      );

      await Future.delayed(Duration(milliseconds: 100));

      expect(cart.items['hoodie']!.quantity, 3);

      cart.removeProductCompletely('hoodie'); // Use uniqueKey (lowercase title)

      await Future.delayed(Duration(milliseconds: 100));

      expect(cart.itemCount, 0);
      expect(cart.items.containsKey('hoodie'), false);
    });

    test('should handle removeProductCompletely with case-insensitive title',
        () async {
      cart.addProduct(
        title: 'SWEATSHIRT',
        imageUrl: 'https://example.com/sweatshirt.jpg',
        price: 35.00,
      );

      await Future.delayed(Duration(milliseconds: 100));

      cart.removeProductCompletely('sweatshirt');

      await Future.delayed(Duration(milliseconds: 100));

      expect(cart.items.containsKey('sweatshirt'), false);
    });

    test('should clear all items from cart', () async {
      cart.addProduct(
        title: 'Hoodie',
        imageUrl: 'https://example.com/hoodie.jpg',
        price: 45.00,
      );
      cart.addProduct(
        title: 'T-Shirt',
        imageUrl: 'https://example.com/tshirt.jpg',
        price: 20.00,
      );
      cart.addProduct(
        title: 'Sweatshirt',
        imageUrl: 'https://example.com/sweatshirt.jpg',
        price: 35.00,
      );

      await Future.delayed(Duration(milliseconds: 100));

      expect(cart.itemCount, 3);

      cart.clearCart();

      await Future.delayed(Duration(milliseconds: 100));

      expect(cart.itemCount, 0);
      expect(cart.totalQuantity, 0);
      expect(cart.totalPrice, 0.0);
      expect(cart.items, isEmpty);
    });

    test('should return a copy of items map', () async {
      cart.addProduct(
        title: 'Hoodie',
        imageUrl: 'https://example.com/hoodie.jpg',
        price: 45.00,
      );

      await Future.delayed(Duration(milliseconds: 100));

      final items1 = cart.items;
      final items2 = cart.items;

      expect(identical(items1, items2), false);
      expect(items1, equals(items2));
    });

    test('should persist cart to Firestore when adding product', () async {
      cart.addProduct(
        title: 'Hoodie',
        imageUrl: 'https://example.com/hoodie.jpg',
        price: 45.00,
        category: 'clothing',
      );

      await Future.delayed(Duration(milliseconds: 100));

      // Verify cart was saved to Firestore
      final cartDocs = await mockFirestore
          .collection('users')
          .doc('test-user-id')
          .collection('cart')
          .get();

      expect(cartDocs.docs.length, 1);
      expect(cartDocs.docs.first.data()['title'], 'Hoodie');
      expect(cartDocs.docs.first.data()['price'], 45.00);
    });

    test('should load cart from Firestore on auth state change', () async {
      // Create a fresh mock setup for this test
      final testUser = MockUser(
        uid: 'load-test-user',
        email: 'loadtest@example.com',
        displayName: 'Load Test User',
      );
      final testAuth = MockFirebaseAuth(mockUser: testUser, signedIn: true);
      final testFirestore = FakeFirebaseFirestore();

      // Add items to Firestore directly BEFORE creating CartModel
      await testFirestore
          .collection('users')
          .doc('load-test-user')
          .collection('cart')
          .add({
        'title': 'Preloaded Item',
        'imageUrl': 'https://example.com/preloaded.jpg',
        'price': 30.00,
        'quantity': 2,
        'category': 'clothing',
        'collection': null,
        'color': null,
        'size': null,
      });

      // Create new cart instance to trigger load
      final newCart = CartModel(auth: testAuth, firestore: testFirestore);

      // Wait for async operations to complete
      await Future.delayed(Duration(milliseconds: 500));

      expect(newCart.itemCount, 1);
      expect(newCart.items['preloaded item']!.quantity, 2);
      expect(newCart.totalPrice, 60.00);
    });

    test('should handle decimal prices correctly', () async {
      cart.addProduct(
        title: 'Item 1',
        imageUrl: 'https://example.com/1.jpg',
        price: 19.99,
      );
      cart.addProduct(
        title: 'Item 2',
        imageUrl: 'https://example.com/2.jpg',
        price: 25.50,
      );

      await Future.delayed(Duration(milliseconds: 100));

      expect(cart.totalPrice, closeTo(45.49, 0.01));
    });
  });
}
