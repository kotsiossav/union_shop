import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:union_shop/layout.dart';

class PersonilationPage extends StatelessWidget {
  const PersonilationPage({super.key});

  Future<Map<String, dynamic>?> _fetchPersonalisationProduct() async {
    final col = FirebaseFirestore.instance.collection('products');
    // try by category first
    var q = await col.where('cat', isEqualTo: 'personalisation').limit(1).get();
    if (q.docs.isEmpty) {
      // fallback to title match
      q = await col.where('title', isEqualTo: 'Personalisation').limit(1).get();
    }
    if (q.docs.isEmpty) return null;
    return q.docs.first.data();
  }

  String _extractImage(Map<String, dynamic> d) {
    return (d['image_url'] ?? d['imageUrl'] ?? d['image'] ?? '') as String;
  }

  String _extractTitle(Map<String, dynamic> d) {
    return (d['title'] ?? '') as String;
  }

  String _extractCategory(Map<String, dynamic> d) {
    return (d['cat'] ?? d['category'] ?? '') as String;
  }

  double _parsePrice(dynamic raw) {
    if (raw == null) return 0.0;
    if (raw is num) return raw.toDouble();
    final s = raw.toString();
    final numeric = s.replaceAll(RegExp(r'[^0-9.]'), '');
    return double.tryParse(numeric) ?? 0.0;
  }

  String _formatPrice(double p) => '£${p.toStringAsFixed(2)}';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Print Shack — Personalisation')),
      body: Column(
        children: [
          const AppHeader(),
          Expanded(
            child: FutureBuilder<Map<String, dynamic>?>(
              future: _fetchPersonalisationProduct(),
              builder: (context, snap) {
                if (snap.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                }
                if (!snap.hasData || snap.data == null) {
                  return const Center(
                    child: Padding(
                      padding: EdgeInsets.all(24.0),
                      child: Text(
                        'Personalisation product not found in the database.',
                        textAlign: TextAlign.center,
                      ),
                    ),
                  );
                }

                final data = snap.data!;
                final rawImage = _extractImage(data);
                // normalize image string from DB (remove surrounding quotes/whitespace)
                final imageUrl = rawImage
                    .toString()
                    .replaceAll(RegExp("^['\"]+|['\"]+\$"), '')
                    .trim();
  
                final title = _extractTitle(data);
                final category = _extractCategory(data);
                final price = _parsePrice(data['price']);

                final bool isNetwork = imageUrl.startsWith('http');

                return SingleChildScrollView(
                  padding: const EdgeInsets.all(24.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // product preview card
                      SizedBox(
                        width: double.infinity,
                        child: Card(
                          elevation: 2,
                          child: Padding(
                            padding: const EdgeInsets.all(12.0),
                            child: Row(
                              children: [
                                SizedBox(
                                  width: 140,
                                  height: 140,
                                  child: isNetwork
                                      ? Image.network(
                                          imageUrl,
                                          fit: BoxFit.cover,
                                          errorBuilder: (ctx, err, st) =>
                                              const Center(
                                                  child: Icon(Icons.image,
                                                      size: 56,
                                                      color: Colors.grey)),
                                        )
                                      : Image.asset(
                                          imageUrl.isEmpty
                                              ? 'assets/images/personalisation_placeholder.png'
                                              : imageUrl,
                                          fit: BoxFit.cover,
                                          errorBuilder: (ctx, err, st) =>
                                              const Center(
                                                  child: Icon(Icons.image,
                                                      size: 56,
                                                      color: Colors.grey)),
                                        ),
                                ),
                                const SizedBox(width: 16),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                          title.isNotEmpty
                                              ? title
                                              : 'Personalisation',
                                          style: const TextStyle(
                                              fontSize: 20,
                                              fontWeight: FontWeight.bold)),
                                      const SizedBox(height: 8),
                                      Text(_formatPrice(price),
                                          style: const TextStyle(
                                              fontSize: 16,
                                              color: Colors.black87)),
                                      const SizedBox(height: 6),
                                      Text(
                                          'Category: ${category.isNotEmpty ? category : 'Personalisation'}',
                                          style: const TextStyle(
                                              fontSize: 14,
                                              color: Colors.grey)),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(height: 16),

                      // rest of the page content / description
                      const Text(
                        'Personalisation',
                        style: TextStyle(
                            fontSize: 24, fontWeight: FontWeight.bold),
                      ),
                      const SizedBox(height: 12),
                      const Text(
                        'Placeholder content for personalisation. Add form fields, pricing details or upload instructions here.',
                        style: TextStyle(fontSize: 16, color: Colors.black87),
                      ),
                    ],
                  ),
                );
              },
            ),
          ),
          const AppFooter(),
        ],
      ),
    );
  }
}
