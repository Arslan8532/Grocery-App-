import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import '../services/order_service.dart';


class OrderHistoryScreen extends StatefulWidget {
  const OrderHistoryScreen({Key? key}) : super(key: key);

  @override
  State<OrderHistoryScreen> createState() => _OrderHistoryScreenState();
}

class _OrderHistoryScreenState extends State<OrderHistoryScreen> {
  final user = FirebaseAuth.instance.currentUser;
  late final OrderService orderService = OrderService(user?.uid ?? '');
  bool _isLoading = true;
  List<Map<String, dynamic>> _orders = [];
  List<Map<String, dynamic>> _filteredOrders = [];
  DateTime? _selectedDate;
  final TextEditingController _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _loadOrders();
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _loadOrders() async {
    setState(() => _isLoading = true);

    try {
      final orders = await orderService.getOrderHistory();
      if (mounted) {
        setState(() {
          _orders = orders.map(_processOrderDates).toList();
          _filteredOrders = _orders;
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() => _isLoading = false);
        _showErrorSnackbar('Failed to load order history: $e');
      }
    }
  }

  Map<String, dynamic> _processOrderDates(Map<String, dynamic> order) {
    if (order['date'] is Timestamp) {
      final date = (order['date'] as Timestamp).toDate();
      return {
        ...order,
        'date': date,
        'dateString': DateFormat('MMM dd, yyyy').format(date),
      };
    } else if (order['date'] is DateTime) {
      return {
        ...order,
        'dateString': DateFormat('MMM dd, yyyy').format(order['date']),
      };
    } else {
      try {
        final date = DateTime.parse(order['date'].toString());
        return {
          ...order,
          'date': date,
          'dateString': DateFormat('MMM dd, yyyy').format(date),
        };
      } catch (e) {
        return {
          ...order,
          'date': DateTime.now(),
          'dateString': 'Unknown date',
        };
      }
    }
  }

  void _filterOrdersByDate(DateTime? date) {
    setState(() {
      _selectedDate = date;
      if (date == null) {
        _filteredOrders = _orders;
      } else {
        _filteredOrders = _orders.where((order) {
          final orderDate = order['date'] as DateTime;
          return orderDate.year == date.year &&
              orderDate.month == date.month &&
              orderDate.day == date.day;
        }).toList();
      }
    });
  }

  void _showErrorSnackbar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message, style: GoogleFonts.poppins()),
        backgroundColor: Theme.of(context).colorScheme.error,
      ),
    );
  }

  Future<void> _selectDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate ?? DateTime.now(),
      firstDate: DateTime(2000),
      lastDate: DateTime.now(),
    );
    if (picked != null && picked != _selectedDate) {
      _filterOrdersByDate(picked);
    }
  }

  Widget _buildDateSearchField() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      child: TextField(
        controller: _searchController,
        decoration: InputDecoration(
          hintText: 'Search by date',
          prefixIcon: Icon(Icons.calendar_today, color: Colors.white.withOpacity(0.7)),
          suffixIcon: _selectedDate != null
              ? IconButton(
            icon: Icon(Icons.clear, color: Colors.white.withOpacity(0.7)),
            onPressed: () {
              _searchController.clear();
              _filterOrdersByDate(null);
            },
          )
              : null,
          filled: true,
          fillColor: const Color(0xFF1E3A8A).withOpacity(0.8),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide.none,
          ),
          hintStyle: GoogleFonts.poppins(color: Colors.white.withOpacity(0.7)),
        ),
        style: GoogleFonts.poppins(color: Colors.white),
        readOnly: true,
        onTap: () => _selectDate(context),
      ),
    );
  }

  Widget _buildLoadingIndicator() {
    return Center(
      child: CircularProgressIndicator(
        color: const Color(0xFF1E3A8A),
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.history,
            color: Colors.white.withOpacity(0.5),
            size: 64,
          ),
          const SizedBox(height: 16),
          Text(
            _selectedDate == null
                ? 'No order history found'
                : 'No orders found for selected date',
            style: GoogleFonts.poppins(
              color: Colors.white.withOpacity(0.7),
              fontSize: 18,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildOrderCard(Map<String, dynamic> order) {
    final items = (order['items'] as List<dynamic>?) ?? [];
    final isOrderPlaced = order['status'] == 'Placed';
    final formattedDate = order['dateString'] ?? 'Unknown date';

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Card(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
        color: const Color(0xFF1E3A8A),
        elevation: 2,
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Order #${order['orderId']?.toString().substring(0, 8) ?? 'N/A'}',
                    style: GoogleFonts.poppins(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      color: Colors.white,
                    ),
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                    decoration: BoxDecoration(
                      color: isOrderPlaced
                          ? Colors.teal.withOpacity(0.2)
                          : Colors.red.withOpacity(0.2),
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(
                        color: isOrderPlaced ? Colors.teal : Colors.red,
                        width: 1,
                      ),
                    ),
                    child: Text(
                      isOrderPlaced ? 'Placed' : 'Cancelled',
                      style: GoogleFonts.poppins(
                        fontSize: 12,
                        fontWeight: FontWeight.w500,
                        color: Colors.white,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              Text(
                formattedDate,
                style: GoogleFonts.poppins(
                  fontSize: 14,
                  color: Colors.white.withOpacity(0.8),
                ),
              ),
              const SizedBox(height: 12),
              Divider(
                color: Colors.white.withOpacity(0.2),
                thickness: 1,
              ),
              const SizedBox(height: 12),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    '${items.length} item${items.length == 1 ? '' : 's'}',
                    style: GoogleFonts.poppins(
                      fontSize: 14,
                      color: Colors.white.withOpacity(0.8),
                    ),
                  ),
                  Text(
                    '₹${order['total']?.toStringAsFixed(0) ?? '0'}',
                    style: GoogleFonts.poppins(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[100],
      appBar: AppBar(
        title: Text(
          'Order History',
          style: GoogleFonts.poppins(
            fontWeight: FontWeight.w600,
            fontSize: 18,
          ),
        ),
        centerTitle: true,
        backgroundColor: const Color(0xFF1E3A8A),
        elevation: 0,
      ),
      body: Column(
        children: [
          _buildDateSearchField(),
          Expanded(
            child: RefreshIndicator(
              onRefresh: _loadOrders,
              color: const Color(0xFF1E3A8A),
              child: _isLoading
                  ? _buildLoadingIndicator()
                  : _filteredOrders.isEmpty
                  ? _buildEmptyState()
                  : ListView.builder(
                padding: const EdgeInsets.only(bottom: 16),
                itemCount: _filteredOrders.length,
                itemBuilder: (context, index) =>
                    _buildOrderCard(_filteredOrders[index]),
              ),
            ),
          ),
        ],
      ),
    );
  }
}