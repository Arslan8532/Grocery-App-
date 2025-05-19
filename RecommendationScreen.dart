import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class RecommendationScreen extends StatefulWidget {
  const RecommendationScreen({Key? key}) : super(key: key);

  @override
  State<RecommendationScreen> createState() => _RecommendationScreenState();
}

class _RecommendationScreenState extends State<RecommendationScreen> {
  final User? user = FirebaseAuth.instance.currentUser;
  List<dynamic> recommendations = [];
  List<dynamic> categoryRecommendations = [];
  bool isLoadingCollab = true;
  bool isLoadingCategory = true;
  String errorMessage = '';

  @override
  void initState() {
    super.initState();
    if (user != null) {
      fetchRecommendations();
      fetchCategoryRecommendations();
    }
  }

  // Fetch collaborative recommendations
  Future<void> fetchRecommendations() async {
    if (user == null) return;

    setState(() {
      isLoadingCollab = true;
      errorMessage = '';
    });

    try {
      final response = await http.get(
        Uri.parse('https://grocerybackendapi.vercel.app/recommendations?userId=${user!.uid}'),
        headers: {'Content-Type': 'application/json'},
      );

      final data = jsonDecode(response.body);

      if (response.statusCode == 200) {
        setState(() {
          recommendations = data['data'] ?? [];
        });
      } else {
        setState(() {
          errorMessage = 'Server error: ${data['message'] ?? 'Unknown error'}';
        });
        print('Error response: ${response.body}');
      }
    } catch (e) {
      setState(() {
        errorMessage = 'Network error: $e';
      });
      print('Exception: $e');
    } finally {
      setState(() {
        isLoadingCollab = false;
      });
    }
  }

  // Fetch category-based recommendations
  Future<void> fetchCategoryRecommendations() async {
    if (user == null) return;

    setState(() {
      isLoadingCategory = true;
    });

    try {
      final response = await http.get(
        Uri.parse('https://grocerybackendapi.vercel.app/custom-recommendations?userId=${user!.uid}'),
        headers: {'Content-Type': 'application/json'},
      );

      final data = jsonDecode(response.body);

      if (response.statusCode == 200) {
        setState(() {
          categoryRecommendations = data['data'] ?? [];
        });
      } else {
        print('Error response: ${response.body}');
      }
    } catch (e) {
      print('Exception: $e');
    } finally {
      setState(() {
        isLoadingCategory = false;
      });
    }
  }

  // Create a product list item
  Widget _buildProductItem(dynamic item) {
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 4.0),
      color: const Color(0xFF203a43),
      child: ListTile(
        title: Text(item['name'] ?? 'Unnamed',
            style: const TextStyle(color: Colors.white)),
        subtitle: Text(
          '₹${item['price'] ?? 0} | ${item['category'] ?? 'Unknown'}',
          style: const TextStyle(color: Colors.white70),
        ),
      ),
    );
  }

  // Create a section for recommendations
  Widget _buildRecommendationSection(String title, List<dynamic> items, bool isLoading) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.all(16.0),
          child: Text(
            title,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
        isLoading
            ? const Center(child: CircularProgressIndicator(color: Colors.cyanAccent))
            : items.isEmpty
            ? const Padding(
          padding: EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
          child: Text(
            'No recommendations available',
            style: TextStyle(color: Colors.white70),
          ),
        )
            : ListView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          itemCount: items.length,
          itemBuilder: (context, index) => _buildProductItem(items[index]),
        ),
        const SizedBox(height: 16),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    final bool isLoading = isLoadingCollab || isLoadingCategory;

    return Scaffold(
      backgroundColor: const Color(0xFF0f2027),
      appBar: AppBar(
        backgroundColor: const Color(0xFF203a43),
        title: const Text('Recommendations', style: TextStyle(color: Colors.white)),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh, color: Colors.white),
            onPressed: () {
              fetchRecommendations();
              fetchCategoryRecommendations();
            },
          ),
        ],
      ),
      body: errorMessage.isNotEmpty
          ? Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.error_outline, color: Colors.red, size: 48),
            const SizedBox(height: 16),
            Text(
              'Something went wrong',
              style: const TextStyle(color: Colors.white, fontSize: 18),
            ),
            const SizedBox(height: 8),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 32.0),
              child: Text(
                errorMessage,
                style: const TextStyle(color: Colors.white70),
                textAlign: TextAlign.center,
              ),
            ),
            const SizedBox(height: 24),
            ElevatedButton(
              onPressed: () {
                setState(() {
                  errorMessage = '';
                });
                fetchRecommendations();
                fetchCategoryRecommendations();
              },
              child: const Text('Try Again'),
            ),
          ],
        ),
      )
          : RefreshIndicator(
        onRefresh: () async {
          await Future.wait([
            fetchRecommendations(),
            fetchCategoryRecommendations(),
          ]);
        },
        color: Colors.cyanAccent,
        backgroundColor: const Color(0xFF203a43),
        child: SingleChildScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildRecommendationSection(
                  "Collaborative Recommendations",
                  recommendations,
                  isLoadingCollab
              ),
              _buildRecommendationSection(
                  "Category-Based Recommendations",
                  categoryRecommendations,
                  isLoadingCategory
              ),
            ],
          ),
        ),
      ),
    );
  }
}