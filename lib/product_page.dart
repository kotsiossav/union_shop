import 'package:flutter/material.dart';
import 'package:union_shop/layout.dart';

class ProductPage extends StatelessWidget {
  final String imageUrl; // can be asset path or network URL

  const ProductPage({
    super.key,
    required this.imageUrl,
  });

  void navigateToHome(BuildContext context) {
    Navigator.pushNamedAndRemoveUntil(context, '/', (route) => false);
  }

  void placeholderCallbackForButtons() {
    // This is the event handler for buttons that don't work yet
  }

  @override
  Widget build(BuildContext context) {
    final bool isNetwork = imageUrl.startsWith('http');

    return Scaffold(
      body: SingleChildScrollView(
        child: Column(
          children: [
            // Reusable header from layout.dart
            AppHeader(
              onHome: () => navigateToHome(context),
              onShop: placeholderCallbackForButtons,
              onSale: placeholderCallbackForButtons,
              onPrintShack: placeholderCallbackForButtons,
              onAbout: () {
                Navigator.pushNamed(context, '/about');
              },
            ),

            // Product details
            Container(
              color: Colors.white,
              padding: const EdgeInsets.all(24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Product image
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
                          ? Image.network(
                              imageUrl,
                              fit: BoxFit.cover,
                              errorBuilder: (context, error, stackTrace) {
                                return _fallbackImage();
                              },
                            )
                          : Image.asset(
                              imageUrl,
                              fit: BoxFit.cover,
                              errorBuilder: (context, error, stackTrace) {
                                return _fallbackImage();
                              },
                            ),
                    ),
                  ),

                  const SizedBox(height: 24),

                  // Product name
                  const Text(
                    'Placeholder Product Name',
                    style: TextStyle(
                      fontSize: 28,
                      fontWeight: FontWeight.bold,
                      color: Colors.black,
                    ),
                  ),

                  const SizedBox(height: 12),

                  // Product price
                  const Text(
                    '£15.00',
                    style: TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF4d2963),
                    ),
                  ),

                  const SizedBox(height: 24),

                  // Product description
                  const Text(
                    'Description',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w600,
                      color: Colors.black,
                    ),
                  ),
                  const SizedBox(height: 8),
                  const Text(
                    'This is a placeholder description for the product. Students should replace this with real product information and implement proper data management.',
                    style: TextStyle(
                      fontSize: 16,
                      color: Colors.grey,
                      height: 1.5,
                    ),
                  ),
                ],
              ),
            ),

            // Reusable footer from layout.dart
            const AppFooter(),
          ],
        ),
      ),
    );
  }

  Widget _fallbackImage() {
    return Container(
      color: Colors.grey[300],
      child: const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.image_not_supported,
              size: 64,
              color: Colors.grey,
            ),
            SizedBox(height: 8),
            Text(
              'Image unavailable',
              style: TextStyle(color: Colors.grey),
            ),
          ],
        ),
      ),
    );
  }
}
