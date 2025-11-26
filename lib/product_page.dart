import 'package:flutter/material.dart';
import 'package:union_shop/layout.dart';

class ProductPage extends StatelessWidget {
  final String imageUrl; // asset or network
  final String title;
  final double price;

  const ProductPage({
    super.key,
    required this.imageUrl,
    required this.title,
    required this.price,
  });

  void navigateToHome(BuildContext context) {
    Navigator.pushNamedAndRemoveUntil(context, '/', (_) => false);
  }

  void placeholderCallbackForButtons() {}

  @override
  Widget build(BuildContext context) {
    final bool isNetwork = imageUrl.startsWith('http');

    return Scaffold(
      appBar: AppBar(title: Text(title)),
      body: SingleChildScrollView(
        child: Column(
          children: [
            // Header
            const AppHeader(),

            // MAIN PRODUCT LAYOUT
            LayoutBuilder(
              builder: (context, constraints) {
                final bool isNarrow = constraints.maxWidth < 600;

                return Container(
                  color: Colors.white,
                  padding: const EdgeInsets.symmetric(
                    vertical: 32,
                    horizontal: 16,
                  ),

                  // ---------- NARROW LAYOUT (Column) ----------
                  child: isNarrow
                      ? Column(
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                            // Image
                            if (imageUrl.isNotEmpty)
                              SizedBox(
                                width: constraints.maxWidth * 0.8,
                                height: 300,
                                child: isNetwork
                                    ? Image.network(
                                        imageUrl,
                                        fit: BoxFit.cover,
                                        key: const Key('product_image'),
                                      )
                                    : Image.asset(
                                        imageUrl,
                                        fit: BoxFit.cover,
                                        key: const Key('product_image'),
                                      ),
                              ),
                            const SizedBox(height: 16),

                            // Title
                            Text(
                              title,
                              style: const TextStyle(
                                fontSize: 28,
                                fontWeight: FontWeight.bold,
                              ),
                              textAlign: TextAlign.center,
                            ),
                            const SizedBox(height: 8),

                            // Price
                            Text(
                              '\$${price.toStringAsFixed(2)}',
                              style: const TextStyle(
                                fontSize: 24,
                                fontWeight: FontWeight.bold,
                                color: Color(0xFF4d2963),
                              ),
                              textAlign: TextAlign.center,
                            ),
                            const SizedBox(height: 24),

                            // Description
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
                              style: TextStyle(
                                fontSize: 16,
                                color: Colors.grey,
                              ),
                              textAlign: TextAlign.center,
                            ),
                          ],
                        )

                      // ---------- WIDE SCREEN LAYOUT (Row) ----------
                      : ConstrainedBox(
                          constraints: const BoxConstraints(
                            maxHeight: 450, // Ensures scroll works properly
                          ),
                          child: Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              // IMAGE
                              if (imageUrl.isNotEmpty)
                                SizedBox(
                                  width: 500,
                                  height: 400,
                                  child: isNetwork
                                      ? Image.network(
                                          imageUrl,
                                          fit: BoxFit.cover,
                                          key: const Key('product_image'),
                                        )
                                      : Image.asset(
                                          imageUrl,
                                          fit: BoxFit.cover,
                                          key: const Key('product_image'),
                                        ),
                                ),
                              const SizedBox(width: 16),

                              // TEXT CONTENT (scroll-disabled inner)
                              Expanded(
                                child: SingleChildScrollView(
                                  physics: const NeverScrollableScrollPhysics(),
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
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
                                        '\$${price.toStringAsFixed(2)}',
                                        style: const TextStyle(
                                          fontSize: 26,
                                          fontWeight: FontWeight.bold,
                                          color: Color(0xFF4d2963),
                                        ),
                                      ),
                                      const SizedBox(height: 24),
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
                                        style: TextStyle(
                                          fontSize: 16,
                                          color: Colors.grey,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                );
              },
            ),

            // Footer
            const AppFooter(),
          ],
        ),
      ),
    );
  }
}
