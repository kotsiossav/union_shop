import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:union_shop/layout.dart'; // AppHeader, AppFooter
import 'package:union_shop/images_layout.dart'; // ProductCard

class CollectionPage extends StatelessWidget {
  final String slug;
  const CollectionPage({super.key, this.slug = ''});

  // sanitize + split coll field into normalized parts
  List<String> _collParts(dynamic raw) {
    if (raw == null) return [];
    final cleaned = raw.toString().replaceAll(RegExp("^['\"]+|['\"]+\$"), '').trim().toLowerCase();
    return cleaned.split(RegExp(r'[,;|]')).map((s) => s.trim()).where((s) => s.isNotEmpty).toList();
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
    final title = slug.isEmpty ? 'Collection' : slug.replaceAll('-', ' ').toUpperCase();
    final productsStream = FirebaseFirestore.instance.collection('products').snapshots();

    return Scaffold(
      body: SingleChildScrollView(
        child: Column(
          children: [
            const AppHeader(),
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 24.0, horizontal: 16.0),
              child: Center(
                child: Text(
                  title,
                  style: const TextStyle(fontSize: 28, fontWeight: FontWeight.bold),
                  textAlign: TextAlign.center,
                ),
              ),
            ),

            StreamBuilder<QuerySnapshot<Map<String, dynamic>>>(
              stream: productsStream,
              builder: (context, snapshot) {
                if (snapshot.hasError) {
                  return Center(child: Text('Error loading products: ${snapshot.error}', style: const TextStyle(color: Colors.red)));
                }
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                }

                final docs = snapshot.data?.docs ?? [];
                final matched = docs.where((doc) {
                  final parts = _collParts(doc.data()['coll']);
                  return _matchesSlug(parts, slug);
                }).toList();

                if (matched.isEmpty) {
                  return Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 24.0),
                    child: Center(child: Text('No products found for "$title".', style: const TextStyle(color: Colors.grey))),
                  );
                }

                return Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 18.0),
                  child: ConstrainedBox(
                    constraints: const BoxConstraints(maxWidth: 1100),
                    child: LayoutBuilder(builder: (context, constraints) {
                      final width = constraints.maxWidth;
                      final crossAxisCount = width > 900 ? 3 : (width > 600 ? 2 : 1);

                      return GridView.builder(
                        physics: const NeverScrollableScrollPhysics(),
                        shrinkWrap: true,
                        itemCount: matched.length,
                        gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                          crossAxisCount: crossAxisCount,
                          crossAxisSpacing: 16,
                          mainAxisSpacing: 20,
                          childAspectRatio: 0.68,
                        ),
                        itemBuilder: (context, index) {
                          final data = matched[index].data();
                          final rawImage = (data['image_url'] as String?) ?? '';
                          final imageUrl = rawImage.replaceAll(RegExp("^['\"]+|['\"]+\$"), '').trim();
                          final rawTitle = (data['title'] as String?) ?? '';
                          final title = rawTitle.replaceAll(RegExp("^['\"]+|['\"]+\$"), '').trim();

                          final priceNum = _parsePrice(data['price']);
                          final priceStr = _formatPrice(priceNum);

                          final discRaw = data['disc_price'] ?? data['discPrice'] ?? data['discount_price'];
                          final discStr = discRaw != null ? _formatPrice(_parsePrice(discRaw)) : null;

                          return ProductCard(
                            imageUrl: imageUrl,
                            title: title,
                            price: priceStr,
                            discountPrice: discStr,
                          );
                        },
                      );
                    }),
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
