import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:intl/intl.dart';

class OrderService {
  final String userId;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  final String apiBaseUrl = 'https://grocerybackendapi.vercel.app'; // Use this for web/desktop

  OrderService(this.userId);

  // Stream of orders for the current user
  Stream<QuerySnapshot> getOrders() {
    return _firestore
        .collection('users')
        .doc(userId)
        .collection('orders')
        .orderBy('date', descending: true)
        .snapshots();
  }

  // Place an order
  Future<void> placeOrder(List<Map<String, dynamic>> items, double total) async {
    try {
      // First create the order in Firestore
      final orderRef = _firestore
          .collection('users')
          .doc(userId)
          .collection('orders')
          .doc();

      final orderData = {
        'orderId': orderRef.id,
        'userId': userId,
        'items': items,
        'total': total,
        'status': 'Placed',
        'date': FieldValue.serverTimestamp(),
      };

      await orderRef.set(orderData);

      // Then record all purchases in bulk in Neo4j through FastAPI
      try {
        await recordPurchasesInBulk(items);
      } catch (e) {
        print('Error recording purchases in Neo4j: $e');
        // Continue with the order even if Neo4j recording fails
      }

      // Clear the cart after successful order
      final cartItems = await _firestore
          .collection('users')
          .doc(userId)
          .collection('cart')
          .get();

      // Delete each cart item
      final batch = _firestore.batch();
      for (var doc in cartItems.docs) {
        batch.delete(doc.reference);
      }
      await batch.commit();
    } catch (e) {
      print('Error placing order: $e');
      throw Exception('Error placing order: $e');
    }
  }

  // Record multiple purchases in bulk through FastAPI
  Future<void> recordPurchasesInBulk(List<Map<String, dynamic>> items) async {
    try {
      List<Map<String, dynamic>> purchases = items.map((item) {
        return {
          'product_id': item['id'],
          'quantity': item['quantity'],
          'date': DateFormat('yyyy-MM-dd').format(DateTime.now()),
          'product_data': {
            'name': item['name'],
            'category': item['category'],
            'price': item['price'],
          }
        };
      }).toList();

      final response = await http.post(
        Uri.parse('$apiBaseUrl/bulk-purchase'),
        headers: {'Content-Type': 'application/json'},
        body: json.encode({
          'userId': userId,
          'purchases': purchases,
        }),
      ).timeout(const Duration(seconds: 15));

      if (response.statusCode != 201 && response.statusCode != 207) {
        print('API Error: ${response.body}');
        throw Exception('Failed to record purchases: ${response.statusCode}');
      }

      // Log partial success
      if (response.statusCode == 207) {
        final data = json.decode(response.body);
        if (data['errors'] != null && data['errors'].isNotEmpty) {
          print('Some purchases failed: ${data['errors']}');
        }
      }
    } catch (e) {
      print('Network error recording purchases: $e');
      // Don't throw here - we want the Firestore order to succeed even if Neo4j fails
    }
  }

  // Record a single purchase in Neo4j through FastAPI
  Future<void> recordPurchase(Map<String, dynamic> item) async {
    try {
      // Include product data in case the product doesn't exist in Neo4j
      final productData = {
        'name': item['name'],
        'category': item['category'],
        'price': item['price'],
      };

      final response = await http.post(
        Uri.parse('$apiBaseUrl/purchase'),
        headers: {'Content-Type': 'application/json'},
        body: json.encode({
          'userId': userId,
          'productId': item['id'],
          'quantity': item['quantity'],
          'date': DateFormat('yyyy-MM-dd').format(DateTime.now()),
          'product_data': productData, // Include product data for automatic creation
        }),
      ).timeout(const Duration(seconds: 10)); // Add timeout

      if (response.statusCode != 201) {
        print('API Error: ${response.body}');
        throw Exception('Failed to record purchase: ${response.statusCode}');
      }
    } catch (e) {
      print('Network error recording purchase: $e');
      // Don't throw here - we want the Firestore order to succeed even if Neo4j fails
    }
  }

  // Cancel an order
  Future<void> cancelOrder(String orderId) async {
    try {
      await _firestore
          .collection('users')
          .doc(userId)
          .collection('orders')
          .doc(orderId)
          .update({'status': 'Cancelled'});
    } catch (e) {
      print('Error cancelling order: $e');
      throw Exception('Error cancelling order: $e');
    }
  }

  // Get order history
  Future<List<Map<String, dynamic>>> getOrderHistory() async {
    try {
      final orderDocs = await _firestore
          .collection('users')
          .doc(userId)
          .collection('orders')
          .orderBy('date', descending: true)
          .get();

      return orderDocs.docs
          .map((doc) {
        final data = doc.data();
        // Convert Timestamp to DateTime if it exists
        if (data['date'] != null && data['date'] is Timestamp) {
          final dateTime = (data['date'] as Timestamp).toDate();
          data['dateString'] = DateFormat('MMM dd, yyyy').format(dateTime);
        }
        return data;
      })
          .toList();
    } catch (e) {
      print('Error getting order history: $e');
      return [];
    }
  }
}