import 'package:flutter/material.dart';
import 'package:union_shop/layout.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:go_router/go_router.dart';

// Search page for finding products by name or collection
class SearchPage extends StatefulWidget {
  final String? initialQuery; // Optional pre-filled search query
  final FirebaseFirestore? firestore; // Optional Firestore instance for testing
  final Future<QuerySnapshot<Map<String, dynamic>>> Function()?
      fetchProducts; // Optional custom fetch function for testing

  const SearchPage({
    super.key,
    this.initialQuery,
    this.firestore,
    this.fetchProducts,
  });

  @override
  State<SearchPage> createState() => _SearchPageState();
}

class _SearchPageState extends State<SearchPage> {
  final TextEditingController _searchController = TextEditingController();
  List<Map<String, dynamic>> _searchResults = []; // Filtered product results
  bool _isSearching = false; // Loading state during search
  bool _hasSearched = false; // Track if a search has been performed

  @override
  void initState() {
    super.initState();
    // If initial query provided, populate search field and trigger search
    if (widget.initialQuery != null && widget.initialQuery!.isNotEmpty) {
      _searchController.text = widget.initialQuery!;
      // Perform search after the widget is built
      WidgetsBinding.instance.addPostFrameCallback((_) {
        _performSearch();
      });
    }
  }

  @override
  void dispose() {
    // Clean up text controller to prevent memory leaks
    _searchController.dispose();
    super.dispose();
  }

  // Fetch products from Firestore and filter by search query
  Future<void> _performSearch() async {
    final query = _searchController.text.trim().toLowerCase();

    if (query.isEmpty) return;

    setState(() {
      _isSearching = true;
      _hasSearched = true;
    });

    try {
      // Use custom fetch function if provided, otherwise query Firestore
      final snapshot = widget.fetchProducts != null
          ? await widget.fetchProducts!()
          : await (widget.firestore ?? FirebaseFirestore.instance)
              .collection('products')
              .get();

      final results = <Map<String, dynamic>>[];

      for (var doc in snapshot.docs) {
        final data = doc.data();
        final title = (data['title'] ?? '').toString().toLowerCase();
        final coll = (data['coll'] ?? '').toString().toLowerCase();

        // Check if query matches title or any collection
        if (title.contains(query) || coll.contains(query)) {
          // Parse collections from comma-separated string
          final collParts = coll.split(',').map((e) => e.trim()).toList();
          final collection = collParts.isNotEmpty ? collParts.first : 'all';

          // Parse price from various formats (number, string, pence)
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

          // Add matching product to results
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
      // Show error message if search fails
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

            // Search content area
            Padding(
              padding: const EdgeInsets.all(40.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Page title
                  const Text(
                    'Search',
                    style: TextStyle(
                      fontSize: 32,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 24),
                  // Search input with button
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

                  // Search results with different states
                  if (_isSearching)
                    // Loading state
                    const Center(
                      child: CircularProgressIndicator(),
                    )
                  else if (!_hasSearched)
                    // Initial state (no search performed yet)
                    const Text(
                      'Enter a search term to find products',
                      style: TextStyle(color: Colors.grey),
                    )
                  else if (_searchResults.isEmpty)
                    // Empty results state
                    const Text(
                      'No products found matching your search',
                      style: TextStyle(color: Colors.grey),
                    )
                  else
                    // Results found state
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Results count
                        Text(
                          '${_searchResults.length} product${_searchResults.length == 1 ? '' : 's'} found',
                          style: const TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        const SizedBox(height: 24),
                        // List of product items
                        ..._searchResults.map((product) {
                          return _buildProductItem(context, product);
                        }),
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

  // Build individual product item row with image, details, and navigation
  Widget _buildProductItem(BuildContext context, Map<String, dynamic> product) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 16),
      decoration: const BoxDecoration(
        border: Border(
          bottom: BorderSide(color: Colors.grey, width: 0.5),
        ),
      ),
      child: InkWell(
        onTap: () {
          // Create URL-friendly slugs for navigation
          final productSlug = Uri.encodeComponent(product['title']
              .toString()
              .toLowerCase()
              .replaceAll(RegExp(r'\s+'), '-'));
          final collectionSlug = product['collection'] ?? 'all';
          // Navigate to product detail page
          context.push(
            '/collections/$collectionSlug/products/$productSlug',
            extra: {
              'imageUrl': product['imageUrl'],
              'price': product['price'],
              'discPrice': product['discPrice'],
              'category': product['category'],
            },
          );
        },
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Product image
            Container(
              width: 100,
              height: 100,
              decoration: BoxDecoration(
                border: Border.all(color: Colors.grey.shade300),
              ),
              child: Image.asset(
                product['imageUrl'],
                fit: BoxFit.cover,
                errorBuilder: (context, error, stack) =>
                    const Icon(Icons.image),
              ),
            ),
            const SizedBox(width: 16),

            // Product details (title, price, category)
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    product['title'],
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 8),
                  // Show discount price if available
                  if (product['discPrice'] != null) ...[
                    Text(
                      '£${product['discPrice'].toStringAsFixed(2)}',
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: Colors.red,
                      ),
                    ),
                    const SizedBox(height: 4),
                    // Original price with strikethrough
                    Text(
                      '£${product['price'].toStringAsFixed(2)}',
                      style: const TextStyle(
                        fontSize: 14,
                        color: Colors.grey,
                        decoration: TextDecoration.lineThrough,
                      ),
                    ),
                  ] else ...[
                    // Regular price
                    Text(
                      '£${product['price'].toStringAsFixed(2)}',
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                  const SizedBox(height: 4),
                  // Product category
                  Text(
                    'Category: ${product['category']}',
                    style: const TextStyle(
                      fontSize: 14,
                      color: Colors.grey,
                    ),
                  ),
                ],
              ),
            ),

            // Navigation arrow indicator
            const Icon(
              Icons.arrow_forward_ios,
              size: 16,
              color: Colors.grey,
            ),
          ],
        ),
      ),
    );
  }
}
