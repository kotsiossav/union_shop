import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:union_shop/layout.dart'; // AppHeader, AppFooter
import 'package:union_shop/images_layout.dart'; // ProductCard

class CollectionPage extends StatefulWidget {
  final String slug;
  final FirebaseFirestore? firestore;
  const CollectionPage({super.key, this.slug = '', this.firestore});

  @override
  State<CollectionPage> createState() => _CollectionPageState();
}

class _CollectionPageState extends State<CollectionPage> {
  String _selectedSort = 'Featured';
  String _selectedFilter = 'Display all';

  // sanitize + split coll field into normalized parts
  List<String> _collParts(dynamic raw) {
    if (raw == null) return [];
    final cleaned = raw
        .toString()
        .replaceAll(RegExp("^['\"]+|['\"]+\$"), '')
        .trim()
        .toLowerCase();
    return cleaned
        .split(RegExp(r'[,;|]'))
        .map((s) => s.trim())
        .where((s) => s.isNotEmpty)
        .toList();
  }

  // sanitize + split category field (cat)
  List<String> _catParts(dynamic raw) {
    if (raw == null) return [];
    final cleaned = raw
        .toString()
        .replaceAll(RegExp("^['\"]+|['\"]+\$"), '')
        .trim()
        .toLowerCase();
    return cleaned
        .split(RegExp(r'[,;|]'))
        .map((s) => s.trim())
        .where((s) => s.isNotEmpty)
        .toList();
  }

  bool _catMatches(dynamic raw, String desired) {
    if (desired.toLowerCase() == 'display all' || desired.isEmpty) return true;
    final parts = _catParts(raw);
    return parts.contains(desired.toLowerCase());
  }

  double _parsePrice(dynamic raw) {
    if (raw == null) return 0.0;
    if (raw is num) {
      final v = raw.toDouble();
      if (raw is int && raw.abs() > 1000) return v / 100.0;
      return v;
    }
    final s = raw.toString().replaceAll(RegExp("^['\"]+|['\"]+\$"), '').trim();
    final numeric = s.replaceAll(RegExp(r'[^0-9.]'), '');
    final p = double.tryParse(numeric);
    if (p != null) return p > 1000 ? p / 100.0 : p;
    return 0.0;
  }

  String _formatPrice(double v) => '£${v.toStringAsFixed(2)}';

  // match either the slug or a human label derived from slug
  bool _matchesSlug(List<String> parts, String slug) {
    if (slug.isEmpty) return false;
    final normSlug = slug.toLowerCase();
    final label = normSlug.replaceAll('-', ' ').trim();
    return parts.contains(normSlug) || parts.contains(label);
  }

  @override
  Widget build(BuildContext context) {
    final title = widget.slug.isEmpty
        ? 'Collection'
        : widget.slug.replaceAll('-', ' ').toUpperCase();
    final firestore = widget.firestore ?? FirebaseFirestore.instance;
    final productsStream =
        firestore.collection('products').snapshots();

    return Scaffold(
      body: SingleChildScrollView(
        child: Column(
          children: [
            const AppHeader(),
            Padding(
              padding:
                  const EdgeInsets.symmetric(vertical: 24.0, horizontal: 16.0),
              child: Center(
                child: Text(
                  title,
                  style: const TextStyle(
                      fontSize: 28, fontWeight: FontWeight.bold),
                  textAlign: TextAlign.center,
                ),
              ),
            ),
            StreamBuilder<QuerySnapshot<Map<String, dynamic>>>(
              stream: productsStream,
              builder: (context, snapshot) {
                if (snapshot.hasError) {
                  return Center(
                    child: Text('Error loading products: ${snapshot.error}',
                        style: const TextStyle(color: Colors.red)),
                  );
                }
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                }

                final docs = snapshot.data?.docs ?? [];
                // filter to only products that belong to this collection (coll contains slug/label)
                final matched = docs.where((doc) {
                  final parts = _collParts(doc.data()['coll']);
                  return _matchesSlug(parts, widget.slug);
                }).toList();

                if (matched.isEmpty) {
                  return Padding(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 16.0, vertical: 24.0),
                    child: Center(
                        child: Text('No products found for "$title".',
                            style: const TextStyle(color: Colors.grey))),
                  );
                }

                // apply category filter (client-side) based on _selectedFilter
                final filteredMatched = matched.where((doc) {
                  final data = doc.data();
                  return _catMatches(data['cat'], _selectedFilter);
                }).toList();

                // Build a list of product maps with numeric effective price for sorting
                final products = <Map<String, dynamic>>[];
                for (var i = 0; i < filteredMatched.length; i++) {
                  final data = filteredMatched[i].data();
                  final rawImage = (data['image_url'] as String?) ?? '';
                  final imageUrl = rawImage
                      .replaceAll(RegExp("^['\"]+|['\"]+\$"), '')
                      .trim();

                  final rawTitle = (data['title'] as String?) ?? '';
                  final titleText = rawTitle
                      .replaceAll(RegExp("^['\"]+|['\"]+\$"), '')
                      .trim();

                  final priceNum = _parsePrice(data['price']);
                  final discRaw = data['disc_price'] ??
                      data['discPrice'] ??
                      data['discount_price'];
                  final discNum = discRaw != null ? _parsePrice(discRaw) : null;

                  // effective price = disc if present else regular price
                  final effectivePrice = discNum ?? priceNum;

                  // read and normalize category (cat) from DB
                  final rawCat = (data['cat'] as String?) ?? '';
                  final category = rawCat
                      .toString()
                      .replaceAll(RegExp("^['\"]+|['\"]+\$"), '')
                      .trim();

                  products.add({
                    'imageUrl': imageUrl,
                    'title': titleText,
                    'priceNum': priceNum,
                    'priceStr': _formatPrice(priceNum),
                    'discStr': discNum != null ? _formatPrice(discNum) : null,
                    'effectivePrice': effectivePrice,
                    'category': category,
                    'index': i,
                  });
                }

                // apply client-side sorting
                final sorted = List<Map<String, dynamic>>.from(products);
                switch (_selectedSort) {
                  case 'A-Z':
                    sorted.sort((a, b) => (a['title'] as String)
                        .toLowerCase()
                        .compareTo((b['title'] as String).toLowerCase()));
                    break;
                  case 'Z-A':
                    sorted.sort((a, b) => (b['title'] as String)
                        .toLowerCase()
                        .compareTo((a['title'] as String).toLowerCase()));
                    break;
                  case 'PriceLowHigh':
                    sorted.sort((a, b) => (a['effectivePrice'] as double)
                        .compareTo((b['effectivePrice'] as double)));
                    break;
                  case 'PriceHighLow':
                    sorted.sort((a, b) => (b['effectivePrice'] as double)
                        .compareTo((a['effectivePrice'] as double)));
                    break;
                  case 'Featured':
                  default:
                    sorted.sort((a, b) =>
                        (a['index'] as int).compareTo(b['index'] as int));
                }

                final itemCount = sorted.length;

                return Padding(
                  padding: const EdgeInsets.symmetric(
                      horizontal: 24.0, vertical: 18.0),
                  child: ConstrainedBox(
                    constraints: const BoxConstraints(maxWidth: 1100),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        // Responsive controls layout
                        LayoutBuilder(
                          builder: (context, constraints) {
                            final isMobile = constraints.maxWidth < 600;

                            if (isMobile) {
                              // Mobile: stack controls vertically
                              return Column(
                                crossAxisAlignment: CrossAxisAlignment.stretch,
                                children: [
                                  // Item count on top
                                  Text(
                                    '$itemCount item${itemCount == 1 ? '' : 's'}',
                                    style: const TextStyle(
                                        fontSize: 16,
                                        fontWeight: FontWeight.w600),
                                    textAlign: TextAlign.center,
                                  ),
                                  const SizedBox(height: 12),
                                  // Sort dropdown
                                  Row(
                                    children: [
                                      const Text('Sort by'),
                                      const SizedBox(width: 12),
                                      Expanded(
                                        child: DropdownButton<String>(
                                          value: _selectedSort,
                                          isExpanded: true,
                                          items: const [
                                            DropdownMenuItem(
                                                value: 'Featured',
                                                child: Text('Featured')),
                                            DropdownMenuItem(
                                                value: 'A-Z',
                                                child:
                                                    Text('Alphabetical A‑Z')),
                                            DropdownMenuItem(
                                                value: 'Z-A',
                                                child:
                                                    Text('Alphabetical Z‑A')),
                                            DropdownMenuItem(
                                                value: 'PriceLowHigh',
                                                child:
                                                    Text('Price: Low → High')),
                                            DropdownMenuItem(
                                                value: 'PriceHighLow',
                                                child:
                                                    Text('Price: High → Low')),
                                          ],
                                          onChanged: (v) {
                                            if (v == null) return;
                                            setState(() => _selectedSort = v);
                                          },
                                        ),
                                      ),
                                    ],
                                  ),
                                  const SizedBox(height: 8),
                                  // Filter dropdown
                                  Row(
                                    children: [
                                      const Text('Filter by'),
                                      const SizedBox(width: 12),
                                      Expanded(
                                        child: DropdownButton<String>(
                                          value: _selectedFilter,
                                          isExpanded: true,
                                          items: const [
                                            DropdownMenuItem(
                                                value: 'Display all',
                                                child: Text('Display all')),
                                            DropdownMenuItem(
                                                value: 'Clothing',
                                                child: Text('Clothing')),
                                            DropdownMenuItem(
                                                value: 'Merchandise',
                                                child: Text('Merchandise')),
                                          ],
                                          onChanged: (v) {
                                            if (v == null) return;
                                            setState(() => _selectedFilter = v);
                                          },
                                        ),
                                      ),
                                    ],
                                  ),
                                ],
                              );
                            } else {
                              // Desktop: horizontal layout
                              return Row(
                                children: [
                                  // left-aligned: Sort + Filter controls
                                  Row(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      const Text('Sort by'),
                                      const SizedBox(width: 12),
                                      DropdownButton<String>(
                                        value: _selectedSort,
                                        items: const [
                                          DropdownMenuItem(
                                              value: 'Featured',
                                              child: Text('Featured')),
                                          DropdownMenuItem(
                                              value: 'A-Z',
                                              child: Text('Alphabetical A‑Z')),
                                          DropdownMenuItem(
                                              value: 'Z-A',
                                              child: Text('Alphabetical Z‑A')),
                                          DropdownMenuItem(
                                              value: 'PriceLowHigh',
                                              child: Text('Price: Low → High')),
                                          DropdownMenuItem(
                                              value: 'PriceHighLow',
                                              child: Text('Price: High → Low')),
                                        ],
                                        onChanged: (v) {
                                          if (v == null) return;
                                          setState(() => _selectedSort = v);
                                        },
                                      ),
                                      const SizedBox(width: 18),
                                      const Text('Filter by'),
                                      const SizedBox(width: 12),
                                      DropdownButton<String>(
                                        value: _selectedFilter,
                                        items: const [
                                          DropdownMenuItem(
                                              value: 'Display all',
                                              child: Text('Display all')),
                                          DropdownMenuItem(
                                              value: 'Clothing',
                                              child: Text('Clothing')),
                                          DropdownMenuItem(
                                              value: 'Merchandise',
                                              child: Text('Merchandise')),
                                        ],
                                        onChanged: (v) {
                                          if (v == null) return;
                                          setState(() => _selectedFilter = v);
                                        },
                                      ),
                                    ],
                                  ),
                                  const Spacer(), // push the count to the right
                                  // right-aligned: item count
                                  Text(
                                    '$itemCount item${itemCount == 1 ? '' : 's'}',
                                    style: const TextStyle(
                                        fontSize: 16,
                                        fontWeight: FontWeight.w600),
                                  ),
                                ],
                              );
                            }
                          },
                        ),
                        const SizedBox(height: 12),
                        LayoutBuilder(builder: (context, constraints) {
                          final width = constraints.maxWidth;
                          final crossAxisCount =
                              width > 900 ? 3 : (width > 600 ? 2 : 1);

                          return GridView.builder(
                            physics: const NeverScrollableScrollPhysics(),
                            shrinkWrap: true,
                            itemCount: sorted.length,
                            gridDelegate:
                                SliverGridDelegateWithFixedCrossAxisCount(
                              crossAxisCount: crossAxisCount,
                              crossAxisSpacing: 16,
                              mainAxisSpacing: 20,
                              childAspectRatio: 0.68,
                            ),
                            itemBuilder: (context, index) {
                              final p = sorted[index];
                              return ProductCard(
                                imageUrl: p['imageUrl'] as String,
                                title: p['title'] as String,
                                price: p['priceStr'] as String,
                                discountPrice: p['discStr'] as String?,
                                category: p['category'] as String,
                                collection:
                                    widget.slug, // pass current collection slug
                              );
                            },
                          );
                        }),
                      ],
                    ),
                  ),
                );
              },
            ),
            const SizedBox(height: 48),
            const AppFooter(),
          ],
        ),
      ),
    );
  }
}
