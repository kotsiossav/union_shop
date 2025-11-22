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
            LayoutBuilder(
              builder: (context, constraints) {
                // If width is small (like in tests), use a narrower image.
                final bool isNarrow = constraints.maxWidth < 600;
                final double imageWidth =
                    isNarrow ? constraints.maxWidth - 40 : 500;
                final double imageHeight = 400;

                return Container(
                  color: Colors.white,
                  padding: const EdgeInsets.symmetric(
                    vertical: 32,
                    horizontal: 32,
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Padding(
                            padding: EdgeInsets.only(left: isNarrow ? 0 : 250),
                            child: SizedBox(
                              width: imageWidth,
                              height: imageHeight,
                              child: ClipRRect(
                                borderRadius: BorderRadius.circular(8),
                                child: isNetwork
                                    ? Image.network(imageUrl, fit: BoxFit.cover)
                                    : Image.asset(imageUrl, fit: BoxFit.cover),
                              ),
                            ),
                          ),
                          if (!isNarrow) const SizedBox(width: 40),
                          if (!isNarrow)
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    title,
                                    style: const TextStyle(
                                      fontSize: 32,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                  const SizedBox(height: 16),
                                  Text(
                                    price,
                                    style: const TextStyle(
                                      fontSize: 26,
                                      fontWeight: FontWeight.bold,
                                      color: Color(0xFF4d2963),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                        ],
                      ),
                      const SizedBox(height: 24),
                      // On narrow screens, show title/price below the image instead
                      if (isNarrow) ...[
                        Text(
                          title,
                          style: const TextStyle(
                            fontSize: 28,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 12),
                        Text(
                          price,
                          style: const TextStyle(
                            fontSize: 24,
                            fontWeight: FontWeight.bold,
                            color: Color(0xFF4d2963),
                          ),
                        ),
                        const SizedBox(height: 24),
                      ],
                      const Text(
                        'Description',
                        style: TextStyle(
                          fontSize: 20,
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
                );
              },
            ),
            const AppFooter(),
          ],
        ),
      ),
    );
  }
}
