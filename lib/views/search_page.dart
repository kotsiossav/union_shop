import 'package:flutter/material.dart';
import 'package:union_shop/layout.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:union_shop/images_layout.dart';

class SearchPage extends StatefulWidget {
  const SearchPage({super.key});

  @override
  State<SearchPage> createState() => _SearchPageState();
}

class _SearchPageState extends State<SearchPage> {
  final TextEditingController _searchController = TextEditingController();
  List<Map<String, dynamic>> _searchResults = [];
  bool _isSearching = false;
  bool _hasSearched = false;

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _performSearch() async {
    final query = _searchController.text.trim().toLowerCase();

    if (query.isEmpty) return;

    setState(() {
      _isSearching = true;
      _hasSearched = true;
    });

    try {
      final snapshot =
          await FirebaseFirestore.instance.collection('products').get();

      final results = <Map<String, dynamic>>[];

      for (var doc in snapshot.docs) {
        final data = doc.data();
        final title = (data['title'] ?? '').toString().toLowerCase();
        final coll = (data['coll'] ?? '').toString().toLowerCase();

        // Check if query matches title or any collection
        if (title.contains(query) || coll.contains(query)) {
          // Parse collections
          final collParts = coll.split(',').map((e) => e.trim()).toList();
          final collection = collParts.isNotEmpty ? collParts.first : 'all';

          // Parse price
          double parsePrice(Object? raw) {
            if (raw is num) return raw.toDouble();
            if (raw is String) {
              final cleanStr = raw.replaceAll(RegExp(r'[^0-9.]'), '');
              if (cleanStr.isEmpty) return 0.0;
              final pence = double.tryParse(cleanStr) ?? 0.0;
              return pence >= 100 ? pence / 100 : pence;
            }
            return 0.0;
          }

          final price = parsePrice(data['price']);
          final discPrice = parsePrice(data['disc_price']);

          results.add({
            'title': data['title'] ?? '',
            'imageUrl': data['image_url'] ?? '',
            'price': price,
            'discPrice': discPrice > 0 ? discPrice : null,
            'category': data['cat'] ?? '',
            'collection': collection,
          });
        }
      }

      setState(() {
        _searchResults = results;
        _isSearching = false;
      });
    } catch (e) {
      setState(() {
        _isSearching = false;
      });
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error searching: $e')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SingleChildScrollView(
        child: Column(
          children: [
            const AppHeader(),

            // Search content
            Padding(
              padding: const EdgeInsets.all(40.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Search',
                    style: TextStyle(
                      fontSize: 32,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 24),
                  Row(
                    children: [
                      Expanded(
                        child: TextField(
                          controller: _searchController,
                          onSubmitted: (_) => _performSearch(),
                          decoration: InputDecoration(
                            hintText: 'Search for products...',
                            prefixIcon: const Icon(Icons.search),
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(4),
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(width: 12),
                      ElevatedButton(
                        onPressed: _performSearch,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFF4d2963),
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(
                            horizontal: 32,
                            vertical: 20,
                          ),
                        ),
                        child: const Text('Search'),
                      ),
                    ],
                  ),
                  const SizedBox(height: 40),

                  // Search results
                  if (_isSearching)
                    const Center(
                      child: CircularProgressIndicator(),
                    )
                  else if (!_hasSearched)
                    const Text(
                      'Enter a search term to find products',
                      style: TextStyle(color: Colors.grey),
                    )
                  else if (_searchResults.isEmpty)
                    const Text(
                      'No products found matching your search',
                      style: TextStyle(color: Colors.grey),
                    )
                  else
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          '${_searchResults.length} product${_searchResults.length == 1 ? '' : 's'} found',
                          style: const TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        const SizedBox(height: 24),
                        Wrap(
                          spacing: 16,
                          runSpacing: 16,
                          children: _searchResults.map((product) {
                            return SizedBox(
                              width: 250,
                              child: ProductCard(
                                imageUrl: product['imageUrl'],
                                title: product['title'],
                                price:
                                    '£${product['price'].toStringAsFixed(2)}',
                                discountPrice: product['discPrice'] != null
                                    ? '£${product['discPrice'].toStringAsFixed(2)}'
                                    : null,
                                category: product['category'],
                                collection: product['collection'],
                              ),
                            );
                          }).toList(),
                        ),
                      ],
                    ),
                ],
              ),
            ),

            const AppFooter(),
          ],
        ),
      ),
    );
  }
}
