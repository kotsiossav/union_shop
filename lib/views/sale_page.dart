import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:union_shop/layout.dart'; // AppHeader, AppFooter
import 'package:union_shop/images_layout.dart'; // ProductCard

class SalePage extends StatefulWidget {
  const SalePage({super.key});

  @override
  State<SalePage> createState() => _SalePageState();
}

class _SalePageState extends State<SalePage> {
  String _selectedSort = 'Featured';
  final Stream<QuerySnapshot<Map<String, dynamic>>> productsStream =
      FirebaseFirestore.instance.collection('products').snapshots();

  double _parsePrice(dynamic raw) {
    if (raw == null) return 0.0;
    if (raw is num) {
      final v = raw.toDouble();
      // if stored as pence (large int) convert heuristically
      if (raw is int && raw.abs() > 1000) return v / 100.0;
      return v;
    }
    final s = raw.toString().replaceAll(RegExp('^["\']|["\']\$'), '').trim();
    final numeric = s.replaceAll(RegExp(r'[^0-9.]'), '');
    final p = double.tryParse(numeric);
    if (p != null) return p > 1000 ? p / 100.0 : p;
    return 0.0;
  }

  String _formatPrice(double v) => '£${v.toStringAsFixed(2)}';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SingleChildScrollView(
        child: Column(
          children: [
            const AppHeader(),

            // Promotional text
            const Padding(
              padding: EdgeInsets.symmetric(vertical: 24.0, horizontal: 12.0),
              child: Center(
                child: Column(
                  children: [
                    Text(
                      'SALE',
                      style:
                          TextStyle(fontSize: 36, fontWeight: FontWeight.bold),
                      textAlign: TextAlign.center,
                    ),
                    SizedBox(height: 8),
                    Text(
                      'Don’t miss out! Get yours before they’re all gone!',
                      style: TextStyle(fontSize: 16),
                      textAlign: TextAlign.center,
                    ),
                    SizedBox(height: 12),
                    Text(
                      'All prices shown are inclusive of the discount 🛒',
                      style: TextStyle(fontSize: 14, color: Colors.grey),
                      textAlign: TextAlign.center,
                    ),
                  ],
                ),
              ),
            ),

            // Sort row (below promo text, above products)
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24.0),
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 1100),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    const Text('Sort by'),
                    const SizedBox(width: 12),
                    DropdownButton<String>(
                      value: _selectedSort,
                      items: const [
                        DropdownMenuItem(value: 'Featured', child: Text('Featured')),
                        DropdownMenuItem(value: 'A-Z', child: Text('Alphabetical A‑Z')),
                        DropdownMenuItem(value: 'Z-A', child: Text('Alphabetical Z‑A')),
                        DropdownMenuItem(value: 'PriceLowHigh', child: Text('Price: Low → High')),
                        DropdownMenuItem(value: 'PriceHighLow', child: Text('Price: High → Low')),
                      ],
                      onChanged: (v) {
                        if (v == null) return;
                        setState(() => _selectedSort = v);
                      },
                    ),
                  ],
                ),
              ),
            ),

            // Products from Firestore
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 18.0),
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 1100),
                child: StreamBuilder<QuerySnapshot<Map<String, dynamic>>>(
                  stream: productsStream,
                  builder: (context, snapshot) {
                    if (snapshot.hasError) {
                      return Center(
                        child: Text(
                          'Error loading products: ${snapshot.error}',
                          style: const TextStyle(color: Colors.red),
                        ),
                      );
                    }
                    if (snapshot.connectionState == ConnectionState.waiting) {
                      return const Center(child: CircularProgressIndicator());
                    }

                    final docs = snapshot.data?.docs ?? [];

                    // client-side filter: only keep documents whose `coll` field equals 'sale'
                    final saleDocs = docs.where((doc) {
                      final rawColl = doc.data()['coll'];
                      final coll = rawColl == null
                          ? ''
                          : rawColl.toString().replaceAll(RegExp("^['\"]+|['\"]+\$"), '').trim().toLowerCase();
                      return coll == 'sale';
                    }).toList();

                    if (saleDocs.isEmpty) {
                      return const Center(child: Text('No sale products found.'));
                    }

                    // build in-memory list (no DB filtering) and parse prices for sorting
                    final products = <Map<String, dynamic>>[];
                    for (var i = 0; i < saleDocs.length; i++) {
                      final data = saleDocs[i].data();
                      final rawImage = (data['image_url'] as String?) ?? '';
                      final imageUrl = rawImage.replaceAll(RegExp('^["\']|["\']\$'), '').trim();

                      final rawTitle = (data['title'] as String?) ?? '';
                      final title = rawTitle.replaceAll(RegExp('^["\']|["\']\$'), '').trim();

                      final priceNum = _parsePrice(data['price']);
                      final priceStr = _formatPrice(priceNum);

                      final discRaw = data['disc_price'] ?? data['discPrice'] ?? data['discount_price'];
                      final discNum = discRaw != null ? _parsePrice(discRaw) : null;
                      final discStr = discNum != null ? _formatPrice(discNum) : null;

                      products.add({
                        'imageUrl': imageUrl,
                        'title': title,
                        'priceNum': priceNum,
                        'priceStr': priceStr,
                        'discStr': discStr,
                        'index': i,
                      });
                    }

                    // client-side sorting only (no DB filtering)
                    final sorted = List<Map<String, dynamic>>.from(products);
                    switch (_selectedSort) {
                      case 'A-Z':
                        sorted.sort((a, b) => (a['title'] as String).toLowerCase().compareTo((b['title'] as String).toLowerCase()));
                        break;
                      case 'Z-A':
                        sorted.sort((a, b) => (b['title'] as String).toLowerCase().compareTo((a['title'] as String).toLowerCase()));
                        break;
                      case 'PriceLowHigh':
                        sorted.sort((a, b) => (a['priceNum'] as double).compareTo((b['priceNum'] as double)));
                        break;
                      case 'PriceHighLow':
                        sorted.sort((a, b) => (b['priceNum'] as double).compareTo((a['priceNum'] as double)));
                        break;
                      case 'Featured':
                      default:
                        sorted.sort((a, b) => (a['index'] as int).compareTo(b['index'] as int));
                    }

                    // responsive grid
                    return LayoutBuilder(builder: (context, constraints) {
                      final width = constraints.maxWidth;
                      final crossAxisCount = width > 900 ? 3 : (width > 600 ? 2 : 1);

                      return GridView.builder(
                        physics: const NeverScrollableScrollPhysics(),
                        shrinkWrap: true,
                        itemCount: sorted.length,
                        gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
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
                          );
                        },
                      );
                    });
                  },
                ),
              ),
            ),

            const SizedBox(height: 36),
            const AppFooter(),
          ],
        ),
      ),
    );
  }
}
