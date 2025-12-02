import 'package:flutter_test/flutter_test.dart';
import 'package:union_shop/models/order_model.dart';
import 'package:fake_cloud_firestore/fake_cloud_firestore.dart';
import 'package:cloud_firestore/cloud_firestore.dart' show Timestamp;

void main() {
  group('OrderItem', () {
    test('should create an OrderItem with required fields', () {
      final item = OrderItem(
        title: 'Test Product',
        imageUrl: 'https://example.com/image.jpg',
        price: 25.99,
        quantity: 2,
      );

      expect(item.title, 'Test Product');
      expect(item.imageUrl, 'https://example.com/image.jpg');
      expect(item.price, 25.99);
      expect(item.quantity, 2);
      expect(item.category, isNull);
      expect(item.collection, isNull);
      expect(item.color, isNull);
      expect(item.size, isNull);
    });

    test('should create an OrderItem with all fields', () {
      final item = OrderItem(
        title: 'Blue Hoodie',
        imageUrl: 'https://example.com/hoodie.jpg',
        price: 45.00,
        category: 'Clothing',
        collection: 'Essential Range',
        color: 'Blue',
        size: 'M',
        quantity: 3,
      );

      expect(item.title, 'Blue Hoodie');
      expect(item.imageUrl, 'https://example.com/hoodie.jpg');
      expect(item.price, 45.00);
      expect(item.category, 'Clothing');
      expect(item.collection, 'Essential Range');
      expect(item.color, 'Blue');
      expect(item.size, 'M');
      expect(item.quantity, 3);
    });

    test('should calculate totalPrice correctly', () {
      final item = OrderItem(
        title: 'T-Shirt',
        imageUrl: 'https://example.com/tshirt.jpg',
        price: 15.00,
        quantity: 4,
      );

      expect(item.totalPrice, 60.00);
    });

    test('should calculate totalPrice correctly for single quantity', () {
      final item = OrderItem(
        title: 'Mug',
        imageUrl: 'https://example.com/mug.jpg',
        price: 12.50,
        quantity: 1,
      );

      expect(item.totalPrice, 12.50);
    });

    test('should calculate totalPrice correctly for large quantities', () {
      final item = OrderItem(
        title: 'Sticker',
        imageUrl: 'https://example.com/sticker.jpg',
        price: 2.99,
        quantity: 10,
      );

      expect(item.totalPrice, closeTo(29.90, 0.01));
    });

    test('should convert OrderItem to Map correctly', () {
      final item = OrderItem(
        title: 'Hoodie',
        imageUrl: 'https://example.com/hoodie.jpg',
        price: 35.99,
        category: 'Clothing',
        collection: 'Signature Range',
        color: 'Red',
        size: 'L',
        quantity: 2,
      );

      final map = item.toMap();

      expect(map['title'], 'Hoodie');
      expect(map['imageUrl'], 'https://example.com/hoodie.jpg');
      expect(map['price'], 35.99);
      expect(map['category'], 'Clothing');
      expect(map['collection'], 'Signature Range');
      expect(map['color'], 'Red');
      expect(map['size'], 'L');
      expect(map['quantity'], 2);
    });

    test('should convert OrderItem to Map with null optional fields', () {
      final item = OrderItem(
        title: 'Bear Plush',
        imageUrl: 'https://example.com/bear.jpg',
        price: 25.00,
        quantity: 1,
      );

      final map = item.toMap();

      expect(map['title'], 'Bear Plush');
      expect(map['imageUrl'], 'https://example.com/bear.jpg');
      expect(map['price'], 25.00);
      expect(map['quantity'], 1);
      expect(map['category'], isNull);
      expect(map['collection'], isNull);
      expect(map['color'], isNull);
      expect(map['size'], isNull);
    });

    test('should create OrderItem from Map correctly', () {
      final map = {
        'title': 'Sweatshirt',
        'imageUrl': 'https://example.com/sweatshirt.jpg',
        'price': 40.00,
        'category': 'Clothing',
        'collection': 'Essential Range',
        'color': 'Navy',
        'size': 'XL',
        'quantity': 2,
      };

      final item = OrderItem.fromMap(map);

      expect(item.title, 'Sweatshirt');
      expect(item.imageUrl, 'https://example.com/sweatshirt.jpg');
      expect(item.price, 40.00);
      expect(item.category, 'Clothing');
      expect(item.collection, 'Essential Range');
      expect(item.color, 'Navy');
      expect(item.size, 'XL');
      expect(item.quantity, 2);
    });

    test('should create OrderItem from Map with missing optional fields', () {
      final map = {
        'title': 'Water Bottle',
        'imageUrl': 'https://example.com/bottle.jpg',
        'price': 18.50,
        'quantity': 1,
      };

      final item = OrderItem.fromMap(map);

      expect(item.title, 'Water Bottle');
      expect(item.imageUrl, 'https://example.com/bottle.jpg');
      expect(item.price, 18.50);
      expect(item.quantity, 1);
      expect(item.category, isNull);
      expect(item.collection, isNull);
      expect(item.color, isNull);
      expect(item.size, isNull);
    });

    test('should handle default values when creating from empty Map', () {
      final map = <String, dynamic>{};

      final item = OrderItem.fromMap(map);

      expect(item.title, '');
      expect(item.imageUrl, '');
      expect(item.price, 0.0);
      expect(item.quantity, 1);
    });

    test('should convert integer price to double', () {
      final map = {
        'title': 'Product',
        'imageUrl': 'https://example.com/product.jpg',
        'price': 30, // Integer instead of double
        'quantity': 1,
      };

      final item = OrderItem.fromMap(map);

      expect(item.price, 30.0);
      expect(item.price, isA<double>());
    });
  });

  group('Order', () {
    test('should create an Order with required fields', () {
      final items = [
        OrderItem(
          title: 'Product 1',
          imageUrl: 'https://example.com/p1.jpg',
          price: 20.00,
          quantity: 1,
        ),
        OrderItem(
          title: 'Product 2',
          imageUrl: 'https://example.com/p2.jpg',
          price: 30.00,
          quantity: 2,
        ),
      ];

      final orderDate = DateTime(2025, 12, 2, 10, 30);
      final order = Order(
        id: 'order_123',
        items: items,
        totalAmount: 80.00,
        orderDate: orderDate,
      );

      expect(order.id, 'order_123');
      expect(order.items.length, 2);
      expect(order.totalAmount, 80.00);
      expect(order.orderDate, orderDate);
      expect(order.status, 'completed');
    });

    test('should create an Order with custom status', () {
      final items = [
        OrderItem(
          title: 'Product',
          imageUrl: 'https://example.com/product.jpg',
          price: 50.00,
          quantity: 1,
        ),
      ];

      final order = Order(
        id: 'order_456',
        items: items,
        totalAmount: 50.00,
        orderDate: DateTime.now(),
        status: 'pending',
      );

      expect(order.status, 'pending');
    });

    test('should convert Order to Map correctly', () {
      final items = [
        OrderItem(
          title: 'Hoodie',
          imageUrl: 'https://example.com/hoodie.jpg',
          price: 45.00,
          category: 'Clothing',
          color: 'Black',
          size: 'M',
          quantity: 1,
        ),
      ];

      final orderDate = DateTime(2025, 11, 15, 14, 30);
      final order = Order(
        id: 'order_789',
        items: items,
        totalAmount: 45.00,
        orderDate: orderDate,
        status: 'shipped',
      );

      final map = order.toMap();

      expect(map['items'], isA<List>());
      expect(map['items'].length, 1);
      expect(map['totalAmount'], 45.00);
      expect(map['orderDate'], isA<Timestamp>());
      expect(map['status'], 'shipped');

      // Verify the timestamp conversion
      final timestamp = map['orderDate'] as Timestamp;
      expect(timestamp.toDate(), orderDate);
    });

    test('should convert Order to Map with multiple items', () {
      final items = [
        OrderItem(
          title: 'Product 1',
          imageUrl: 'https://example.com/p1.jpg',
          price: 20.00,
          quantity: 2,
        ),
        OrderItem(
          title: 'Product 2',
          imageUrl: 'https://example.com/p2.jpg',
          price: 15.00,
          quantity: 1,
        ),
        OrderItem(
          title: 'Product 3',
          imageUrl: 'https://example.com/p3.jpg',
          price: 30.00,
          quantity: 3,
        ),
      ];

      final order = Order(
        id: 'order_multi',
        items: items,
        totalAmount: 145.00,
        orderDate: DateTime.now(),
      );

      final map = order.toMap();

      expect(map['items'].length, 3);
      expect(map['totalAmount'], 145.00);
    });

    test('should convert Order to Map with default status', () {
      final items = [
        OrderItem(
          title: 'Product',
          imageUrl: 'https://example.com/product.jpg',
          price: 25.00,
          quantity: 1,
        ),
      ];

      final order = Order(
        id: 'order_default',
        items: items,
        totalAmount: 25.00,
        orderDate: DateTime.now(),
      );

      final map = order.toMap();

      expect(map['status'], 'completed');
    });

    test('should create Order from Firestore document', () async {
      final firestore = FakeFirebaseFirestore();

      final orderDate = DateTime(2025, 12, 1, 9, 0);
      final orderData = {
        'items': [
          {
            'title': 'T-Shirt',
            'imageUrl': 'https://example.com/tshirt.jpg',
            'price': 22.00,
            'category': 'Clothing',
            'color': 'White',
            'size': 'S',
            'quantity': 2,
          },
          {
            'title': 'Mug',
            'imageUrl': 'https://example.com/mug.jpg',
            'price': 12.00,
            'quantity': 1,
          },
        ],
        'totalAmount': 56.00,
        'orderDate': Timestamp.fromDate(orderDate),
        'status': 'delivered',
      };

      // Add document to Firestore
      final docRef = await firestore.collection('orders').add(orderData);
      final doc = await docRef.get();

      final order = Order.fromFirestore(doc);

      expect(order.id, doc.id);
      expect(order.items.length, 2);
      expect(order.items[0].title, 'T-Shirt');
      expect(order.items[0].price, 22.00);
      expect(order.items[0].quantity, 2);
      expect(order.items[1].title, 'Mug');
      expect(order.items[1].price, 12.00);
      expect(order.totalAmount, 56.00);
      expect(order.orderDate, orderDate);
      expect(order.status, 'delivered');
    });

    test('should create Order from Firestore with default status', () async {
      final firestore = FakeFirebaseFirestore();

      final orderData = {
        'items': [
          {
            'title': 'Product',
            'imageUrl': 'https://example.com/product.jpg',
            'price': 30.00,
            'quantity': 1,
          },
        ],
        'totalAmount': 30.00,
        'orderDate': Timestamp.fromDate(DateTime.now()),
      };

      final docRef = await firestore.collection('orders').add(orderData);
      final doc = await docRef.get();

      final order = Order.fromFirestore(doc);

      expect(order.status, 'completed');
    });

    test('should handle Order with empty items list', () {
      final order = Order(
        id: 'order_empty',
        items: [],
        totalAmount: 0.0,
        orderDate: DateTime.now(),
      );

      expect(order.items.length, 0);
      expect(order.totalAmount, 0.0);

      final map = order.toMap();
      expect(map['items'], isEmpty);
    });

    test('should preserve all OrderItem data through Order serialization', () {
      final items = [
        OrderItem(
          title: 'Complete Product',
          imageUrl: 'https://example.com/complete.jpg',
          price: 99.99,
          category: 'Clothing',
          collection: 'Premium Collection',
          color: 'Navy Blue',
          size: 'XL',
          quantity: 5,
        ),
      ];

      final orderDate = DateTime(2025, 10, 20, 15, 45);
      final order = Order(
        id: 'order_complete',
        items: items,
        totalAmount: 499.95,
        orderDate: orderDate,
        status: 'processing',
      );

      final map = order.toMap();
      final itemMap = map['items'][0] as Map<String, dynamic>;

      expect(itemMap['title'], 'Complete Product');
      expect(itemMap['imageUrl'], 'https://example.com/complete.jpg');
      expect(itemMap['price'], 99.99);
      expect(itemMap['category'], 'Clothing');
      expect(itemMap['collection'], 'Premium Collection');
      expect(itemMap['color'], 'Navy Blue');
      expect(itemMap['size'], 'XL');
      expect(itemMap['quantity'], 5);
    });

    test('should handle Order with mixed item types', () {
      final items = [
        OrderItem(
          title: 'Clothing Item',
          imageUrl: 'https://example.com/clothing.jpg',
          price: 50.00,
          category: 'Clothing',
          color: 'Red',
          size: 'M',
          quantity: 1,
        ),
        OrderItem(
          title: 'Merchandise Item',
          imageUrl: 'https://example.com/merch.jpg',
          price: 15.00,
          category: 'Merchandise',
          quantity: 2,
        ),
      ];

      final order = Order(
        id: 'order_mixed',
        items: items,
        totalAmount: 80.00,
        orderDate: DateTime.now(),
      );

      expect(order.items[0].color, 'Red');
      expect(order.items[0].size, 'M');
      expect(order.items[1].color, isNull);
      expect(order.items[1].size, isNull);
    });

    test('should convert Order totalAmount from int to double', () async {
      final firestore = FakeFirebaseFirestore();

      final orderData = {
        'items': [
          {
            'title': 'Product',
            'imageUrl': 'https://example.com/product.jpg',
            'price': 25,
            'quantity': 2,
          },
        ],
        'totalAmount': 50, // Integer instead of double
        'orderDate': Timestamp.fromDate(DateTime.now()),
        'status': 'completed',
      };

      final docRef = await firestore.collection('orders').add(orderData);
      final doc = await docRef.get();

      final order = Order.fromFirestore(doc);

      expect(order.totalAmount, 50.0);
      expect(order.totalAmount, isA<double>());
    });

    test('should handle Order from Firestore with missing totalAmount',
        () async {
      final firestore = FakeFirebaseFirestore();

      final orderData = {
        'items': [
          {
            'title': 'Product',
            'imageUrl': 'https://example.com/product.jpg',
            'price': 30.00,
            'quantity': 1,
          },
        ],
        'orderDate': Timestamp.fromDate(DateTime.now()),
        'status': 'completed',
      };

      final docRef = await firestore.collection('orders').add(orderData);
      final doc = await docRef.get();

      final order = Order.fromFirestore(doc);

      expect(order.totalAmount, 0.0);
    });
  });

  group('Order and OrderItem Integration', () {
    test('should calculate correct total from multiple OrderItems', () {
      final items = [
        OrderItem(
          title: 'Item 1',
          imageUrl: 'https://example.com/i1.jpg',
          price: 10.00,
          quantity: 2,
        ), // 20.00
        OrderItem(
          title: 'Item 2',
          imageUrl: 'https://example.com/i2.jpg',
          price: 15.50,
          quantity: 1,
        ), // 15.50
        OrderItem(
          title: 'Item 3',
          imageUrl: 'https://example.com/i3.jpg',
          price: 7.25,
          quantity: 4,
        ), // 29.00
      ];

      final calculatedTotal = items.fold<double>(
        0.0,
        (sum, item) => sum + item.totalPrice,
      );

      expect(calculatedTotal, 64.50);

      final order = Order(
        id: 'order_calc',
        items: items,
        totalAmount: calculatedTotal,
        orderDate: DateTime.now(),
      );

      expect(order.totalAmount, 64.50);
    });

    test('should preserve order item calculations through serialization',
        () async {
      final firestore = FakeFirebaseFirestore();

      final items = [
        OrderItem(
          title: 'Product A',
          imageUrl: 'https://example.com/a.jpg',
          price: 25.00,
          quantity: 3,
        ),
        OrderItem(
          title: 'Product B',
          imageUrl: 'https://example.com/b.jpg',
          price: 40.00,
          quantity: 1,
        ),
      ];

      final totalAmount =
          items.fold<double>(0.0, (sum, item) => sum + item.totalPrice);

      final originalOrder = Order(
        id: 'order_serialize',
        items: items,
        totalAmount: totalAmount,
        orderDate: DateTime(2025, 12, 2),
        status: 'completed',
      );

      // Save to Firestore
      final orderMap = originalOrder.toMap();
      final docRef = await firestore.collection('orders').add(orderMap);
      final doc = await docRef.get();

      // Load from Firestore
      final loadedOrder = Order.fromFirestore(doc);

      expect(loadedOrder.items.length, 2);
      expect(loadedOrder.items[0].totalPrice, 75.00);
      expect(loadedOrder.items[1].totalPrice, 40.00);
      expect(loadedOrder.totalAmount, 115.00);
    });

    test('should handle Order round-trip serialization correctly', () async {
      final firestore = FakeFirebaseFirestore();

      final originalItems = [
        OrderItem(
          title: 'Hoodie',
          imageUrl: 'https://example.com/hoodie.jpg',
          price: 55.00,
          category: 'Clothing',
          collection: 'Winter Collection',
          color: 'Black',
          size: 'L',
          quantity: 2,
        ),
      ];

      final originalDate = DateTime(2025, 11, 30, 12, 0);
      final originalOrder = Order(
        id: 'temp_id',
        items: originalItems,
        totalAmount: 110.00,
        orderDate: originalDate,
        status: 'shipped',
      );

      // Serialize and save
      final orderMap = originalOrder.toMap();
      final docRef = await firestore.collection('orders').add(orderMap);
      final doc = await docRef.get();

      // Deserialize
      final loadedOrder = Order.fromFirestore(doc);

      expect(loadedOrder.items.length, originalOrder.items.length);
      expect(loadedOrder.items[0].title, originalOrder.items[0].title);
      expect(loadedOrder.items[0].price, originalOrder.items[0].price);
      expect(loadedOrder.items[0].category, originalOrder.items[0].category);
      expect(loadedOrder.items[0].color, originalOrder.items[0].color);
      expect(loadedOrder.items[0].size, originalOrder.items[0].size);
      expect(loadedOrder.items[0].quantity, originalOrder.items[0].quantity);
      expect(loadedOrder.totalAmount, originalOrder.totalAmount);
      expect(loadedOrder.orderDate, originalOrder.orderDate);
      expect(loadedOrder.status, originalOrder.status);
    });
  });
}
