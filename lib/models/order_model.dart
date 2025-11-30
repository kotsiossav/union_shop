import 'package:cloud_firestore/cloud_firestore.dart';

class OrderItem {
  final String title;
  final String imageUrl;
  final double price;
  final String? category;
  final String? collection;
  final String? color;
  final String? size;
  final int quantity;

  OrderItem({
    required this.title,
    required this.imageUrl,
    required this.price,
    this.category,
    this.collection,
    this.color,
    this.size,
    required this.quantity,
  });

  double get totalPrice => price * quantity;

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

  factory OrderItem.fromMap(Map<String, dynamic> map) {
    return OrderItem(
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

class Order {
  final String id;
  final List<OrderItem> items;
  final double totalAmount;
  final DateTime orderDate;
  final String status;

  Order({
    required this.id,
    required this.items,
    required this.totalAmount,
    required this.orderDate,
    this.status = 'completed',
  });

  Map<String, dynamic> toMap() {
    return {
      'items': items.map((item) => item.toMap()).toList(),
      'totalAmount': totalAmount,
      'orderDate': Timestamp.fromDate(orderDate),
      'status': status,
    };
  }

  factory Order.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return Order(
      id: doc.id,
      items: (data['items'] as List)
          .map((item) => OrderItem.fromMap(item as Map<String, dynamic>))
          .toList(),
      totalAmount: (data['totalAmount'] ?? 0).toDouble(),
      orderDate: (data['orderDate'] as Timestamp).toDate(),
      status: data['status'] ?? 'completed',
    );
  }
}
