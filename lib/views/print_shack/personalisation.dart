import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:union_shop/views/product_page.dart';
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

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<Map<String, dynamic>?>(
      future: _fetchPersonalisationProduct(),
      builder: (context, snap) {
        if (snap.connectionState == ConnectionState.waiting) {
          return Scaffold(
            appBar: AppBar(title: const Text('Print Shack — Personalisation')),
            body: const Column(
              children: [
                AppHeader(),
                Expanded(child: Center(child: CircularProgressIndicator())),
                AppFooter(),
              ],
            ),
          );
        }

        if (!snap.hasData || snap.data == null) {
          return Scaffold(
            appBar: AppBar(title: const Text('Print Shack — Personalisation')),
            body: const Column(
              children: [
                AppHeader(),
                Expanded(
                  child: Padding(
                    padding: EdgeInsets.all(24.0),
                    child: Center(
                      child: Text(
                        'Personalisation product not found in the database.',
                        textAlign: TextAlign.center,
                      ),
                    ),
                  ),
                ),
                AppFooter(),
              ],
            ),
          );
        }

        final data = snap.data!;
        // normalize image string from DB (remove surrounding quotes/whitespace)
        final rawImage = _extractImage(data);
        final imageUrl = rawImage
            .toString()
            .replaceAll(RegExp("^['\"]+|['\"]+\$"), '')
            .replaceAll('\\', '/')
            .trim();

        final title = _extractTitle(data);
        final category = _extractCategory(data).isNotEmpty
            ? _extractCategory(data)
            : 'Personalisation';
        final price = _parsePrice(data['price']);

        // Use the existing ProductPage layout by returning it directly.
        return ProductPage(
          imageUrl: imageUrl.isEmpty ? 'assets/images/personalisation_placeholder.png' : imageUrl,
          title: title.isNotEmpty ? title : 'Personalisation',
          price: price,
          category: category,
        );
      },
    );
  }
}
