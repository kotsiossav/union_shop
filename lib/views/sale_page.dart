import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:union_shop/layout.dart'; // AppHeader, AppFooter
import 'package:union_shop/images_layout.dart'; // ProductCard

class SalePage extends StatelessWidget {
  const SalePage({super.key});

  @override
  Widget build(BuildContext context) {
    final productsStream =
        FirebaseFirestore.instance.collection('products').snapshots();

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

            // Products from Firestore
            Padding(
              padding:
                  const EdgeInsets.symmetric(horizontal: 24.0, vertical: 18.0),
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
                    if (docs.isEmpty) {
                      return const Center(child: Text('No products found.'));
                    }

                    // Build responsive grid
                    return LayoutBuilder(builder: (context, constraints) {
                      final width = constraints.maxWidth;
                      final crossAxisCount =
                          width > 900 ? 3 : (width > 600 ? 2 : 1);

                      return GridView.builder(
                        physics: const NeverScrollableScrollPhysics(),
                        shrinkWrap: true,
                        itemCount: docs.length,
                        gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                          crossAxisCount: crossAxisCount,
                          crossAxisSpacing: 16,
                          mainAxisSpacing: 20,
                          childAspectRatio: 0.68,
                        ),
                        itemBuilder: (context, index) {
                          final data = docs[index].data();

                          // read fields safely
                          final imageUrl = (data['image_url'] as String?) ?? '';
                          final title = (data['title'] as String?) ?? '';
                          final rawPrice = data['price'];
                          final disc_price = data['disc_price'];
                          double priceNum;
                          if (rawPrice is num) {
                            priceNum = rawPrice.toDouble();
                          } else {
                            priceNum =
                                double.tryParse(rawPrice?.toString() ?? '') ??
                                    0.0;
                          }
                          final priceStr = '£${priceNum.toStringAsFixed(2)}';

                          double disc_priceNum;
                          if (disc_price is num) {
                            disc_priceNum = disc_price.toDouble();
                          } else {
                            disc_priceNum =
                                double.tryParse(disc_price?.toString() ?? '') ??
                                    0.0;
                          }
                          final disc_priceStr = '£${disc_priceNum.toStringAsFixed(2)}';
                          
                          return ProductCard(
                            imageUrl: imageUrl,
                            title: title,
                            price: priceStr,
                            discountPrice: disc_priceStr, // no discount field in DB
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
