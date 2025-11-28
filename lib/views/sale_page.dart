import 'package:flutter/material.dart';
import 'package:union_shop/layout.dart'; // AppHeader, AppFooter
import 'package:union_shop/images_layout.dart'; // ProductCard

class SalePage extends StatelessWidget {
  const SalePage({super.key});

  static const List<Map<String, String>> _products = [
    {
      'image': 'assets/images/PurpleHoodieFinal_540x.webp',
      'title': 'Purple Hoodie',
      'price': '£28.00',
      'discount': '£22.00',
    },
    {
      'image': 'assets/images/grey_hoodie.webp',
      'title': 'Grey Hoodie',
      'price': '£24.50',
      'discount': '£19.50',
    },
    {
      'image': 'assets/images/Pink_Essential_Hoodie_720x.webp',
      'title': 'Pink Hoodie',
      'price': '£30.00',
      'discount': '£24.00',
    },
    {
      'image': 'assets/images/SageHoodie_720x.webp',
      'title': 'Sage Hoodie',
      'price': '£27.00',
      'discount': '£21.60',
    },
    {
      'image': 'assets/images/card_holder.jpg',
      'title': 'Card Holder',
      'price': '£6.00',
      'discount': '£4.50',
    },
    {
      'image': 'assets/images/postcard.jpg',
      'title': 'Postcard Pack',
      'price': '£4.50',
      'discount': '£3.25',
    },
  ];

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
                      style: TextStyle(
                        fontSize: 36,
                        fontWeight: FontWeight.bold,
                      ),
                      textAlign: TextAlign.center,
                    ),
                    SizedBox(height: 8),
                    Text(
                      'Don’t miss out! Get yours before they’re all gone!',
                      style: TextStyle(
                        fontSize: 16,
                      ),
                      textAlign: TextAlign.center,
                    ),
                    SizedBox(height: 12),
                    Text(
                      'All prices shown are inclusive of the discount 🛒',
                      style: TextStyle(
                        fontSize: 14,
                        color: Colors.grey,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ],
                ),
              ),
            ),

            // Product grid: at most 3 items per row
            Padding(
              padding:
                  const EdgeInsets.symmetric(horizontal: 24.0, vertical: 18.0),
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 1100),
                child: LayoutBuilder(
                  builder: (context, constraints) {
                    final width = constraints.maxWidth;
                    final crossAxisCount =
                        width > 900 ? 3 : (width > 600 ? 2 : 1);
                    return GridView.builder(
                      physics: const NeverScrollableScrollPhysics(),
                      shrinkWrap: true,
                      itemCount: _products.length,
                      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                        crossAxisCount: crossAxisCount,
                        crossAxisSpacing: 16,
                        mainAxisSpacing: 20,
                        childAspectRatio: 0.68,
                      ),
                      itemBuilder: (context, index) {
                        final p = _products[index];
                        return ProductCard(
                          imageUrl: p['image'] ?? '',
                          title: p['title'] ?? '',
                          price: p['price'] ?? '',
                          discountPrice: p['discount'],
                        );
                      },
                    );
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
