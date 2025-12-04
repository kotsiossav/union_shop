import 'package:cloud_firestore/cloud_firestore.dart';

// Represents a single item in a completed order
// Similar to CartItem but immutable since order is finalized
class OrderItem {
  final String title; // Product name
  final String imageUrl; // Product image path
  final double price; // Price per unit at time of purchase
  final String? category; // Product category
  final String? collection; // Product collection
  final String? color; // Selected color option
  final String? size; // Selected size option
  final int quantity; // Number of units ordered

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

  // Calculate total price for this order item
  double get totalPrice => price * quantity;

  // Convert OrderItem to Map for Firestore storage
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

  // Create OrderItem from Firestore Map data
  factory OrderItem.fromMap(Map<String, dynamic> map) {
    return OrderItem(
      title: map['title'] ?? '',
      imageUrl: map['imageUrl'] ?? '',
      // Ensure price is converted to double
      price: (map['price'] ?? 0).toDouble(),
      category: map['category'],
      collection: map['collection'],
      color: map['color'],
      size: map['size'],
      quantity: map['quantity'] ?? 1,
    );
  }
}

// Represents a complete order placed by a user
// Stored in Firestore under users/{uid}/orders/
class Order {
  final String id; // Unique order ID from Firestore document ID
  final List<OrderItem> items; // List of all items in this order
  final double totalAmount; 
  final DateTime orderDate; 
  final String status; //  "completed", "pending"

  Order({
    required this.id,
    required this.items,
    required this.totalAmount,
    required this.orderDate,
    this.status = 'completed', // Default status is completed
  });

  // Convert Order to Map for Firestore storage
  Map<String, dynamic> toMap() {
    return {
      'items': items.map((item) => item.toMap()).toList(),
      'totalAmount': totalAmount,
      // Convert DateTime to Firestore Timestamp
      'orderDate': Timestamp.fromDate(orderDate),
      'status': status,
    };
  }

  // Create Order from Firestore DocumentSnapshot
  factory Order.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return Order(
      id: doc.id, // Use Firestore document ID as order ID
      // Convert each item Map to OrderItem object
      items: (data['items'] as List)
          .map((item) => OrderItem.fromMap(item as Map<String, dynamic>))
          .toList(),
      totalAmount: (data['totalAmount'] ?? 0).toDouble(),
      // Convert Firestore Timestamp back to DateTime
      orderDate: (data['orderDate'] as Timestamp).toDate(),
      status: data['status'] ?? 'completed',
    );
  }
}
