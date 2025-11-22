import 'package:flutter/material.dart';
import 'package:union_shop/layout.dart';

class ProductPage extends StatelessWidget {
  final String imageUrl; // asset or network
  final String title;
  final String price;

  const ProductPage({
    super.key,
    required this.imageUrl,
    required this.title,
    required this.price,
  });

  void navigateToHome(BuildContext context) {
    Navigator.pushNamedAndRemoveUntil(context, '/', (route) => false);
  }

  void placeholderCallbackForButtons() {}

  @override
  Widget build(BuildContext context) {
    final bool isNetwork = imageUrl.startsWith('http');

    return Scaffold(
      body: SingleChildScrollView(
        child: Column(
          children: [
            AppHeader(
              onHome: () => navigateToHome(context),
              onShop: placeholderCallbackForButtons,
              onSale: placeholderCallbackForButtons,
              onPrintShack: placeholderCallbackForButtons,
              onAbout: () => Navigator.pushNamed(context, '/about'),
            ),
            Container(
              color: Colors.white,
              padding: const EdgeInsets.all(24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // image
                  Container(
                    height: 300,
                    width: double.infinity,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(8),
                      color: Colors.grey[200],
                    ),
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(8),
                      child: isNetwork
                          ? Image.network(imageUrl, fit: BoxFit.cover)
                          : Image.asset(imageUrl, fit: BoxFit.cover),
                    ),
                  ),
                  const SizedBox(height: 24),
                  // title from card
                  Text(
                    title,
                    style: const TextStyle(
                      fontSize: 28,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 12),
                  // price from card
                  Text(
                    price,
                    style: const TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF4d2963),
                    ),
                  ),
                  const SizedBox(height: 24),
                  const Text(
                    'Description',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 8),
                  const Text(
                    'This is a placeholder description for the product.',
                    style: TextStyle(fontSize: 16, color: Colors.grey),
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
