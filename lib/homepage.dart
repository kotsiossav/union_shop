import 'package:flutter/material.dart';
import 'package:union_shop/layout.dart';
import 'package:union_shop/app_styles.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  void navigateToHome(BuildContext context) {
    Navigator.pushNamedAndRemoveUntil(context, '/', (route) => false);
  }

  void navigateToProduct(BuildContext context) {
    Navigator.pushNamed(context, '/product');
  }

  void placeholderCallbackForButtons() {
    // This is the event handler for buttons that don't work yet
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SingleChildScrollView(
        child: Column(
          children: [
            // Header from layout.dart
            AppHeader(
              onHome: () => navigateToHome(context),
              onShop: placeholderCallbackForButtons,
              onSale: placeholderCallbackForButtons,
              onPrintShack: placeholderCallbackForButtons,
              onAbout: placeholderCallbackForButtons,
            ),

            // Hero Section
            SizedBox(
              height: 400,
              width: double.infinity,
              child: Stack(
                children: [
                  // Background image
                  Positioned.fill(
                    child: Container(
                      decoration: const BoxDecoration(
                        image: DecorationImage(
                          image: AssetImage(
                            'assets/images/Pink_Essential_Hoodie_720x.webp',
                          ),
                          fit: BoxFit.cover,
                        ),
                      ),
                      child: Container(
                        decoration: BoxDecoration(
                          color: Colors.black.withOpacity(0.7),
                        ),
                      ),
                    ),
                  ),
                  // Content overlay
                  Positioned(
                    left: 24,
                    right: 24,
                    top: 80,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        const Text(
                          'Placeholder Hero Title',
                          style: TextStyle(
                            fontSize: 32,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                            height: 1.2,
                          ),
                        ),
                        const SizedBox(height: 16),
                        const Text(
                          "This is placeholder text for the hero section.",
                          style: TextStyle(
                            fontSize: 20,
                            color: Colors.white,
                            height: 1.5,
                          ),
                          textAlign: TextAlign.center,
                        ),
                        const SizedBox(height: 32),
                        ElevatedButton(
                          onPressed: placeholderCallbackForButtons,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xFF4d2963),
                            foregroundColor: Colors.white,
                            shape: const RoundedRectangleBorder(
                              borderRadius: BorderRadius.zero,
                            ),
                          ),
                          child: const Text(
                            'BROWSE PRODUCTS',
                            style: TextStyle(fontSize: 14, letterSpacing: 1),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),

            // Products Section
            Container(
              color: Colors.white,
              child: Padding(
                padding: EdgeInsets.all(40.0),
                child: Center(
                  // <--- center the inner content
                  child: SizedBox(
                    width: 1100, // <--- same width for cards + squares
                    child: Column(
                      children: [
                        const Text(
                          'ESSENTIAL RANGE - OVER 20% OFF!',
                          style: AppStyles.title,
                        ),
                        SizedBox(height: 48),

                        // First 2 products in a row
                        const Row(
                          children: [
                            Expanded(
                              child: ProductCard(
                                title: 'Placeholder Product 1',
                                price: '£10.00',
                                imageUrl:
                                    'assets/images/Pink_Essential_Hoodie_720x.webp',
                              ),
                            ),
                            SizedBox(width: 24),
                            Expanded(
                              child: ProductCard(
                                title: 'Placeholder Product 2',
                                price: '£15.00',
                                imageUrl:
                                    'assets/images/Sage_T-shirt_720x.webp',
                              ),
                            ),
                          ],
                        ),

                        const SizedBox(height: 48),

                        // Text between first 2 and last 2 product cards
                        const Center(
                          child: Text(
                            'SIGNATURE RANGE',
                            style: AppStyles.title,
                            textAlign: TextAlign.center,
                          ),
                        ),

                        SizedBox(height: 48),

                        // Last 2 products in a row
                        const Row(
                          children: [
                            Expanded(
                              child: ProductCard(
                                title: 'Placeholder Product 3',
                                price: '£20.00',
                                imageUrl: 'assets/images/SageHoodie_720x.webp',
                              ),
                            ),
                            SizedBox(width: 24),
                            Expanded(
                              child: ProductCard(
                                title: 'Placeholder Product 4',
                                price: '£25.00',
                                imageUrl:
                                    'assets/images/Signature_T-Shirt_Indigo_Blue_2_720x.webp',
                              ),
                            ),
                          ],
                        ),
                        const Center(
                          child: Text(
                            'PORTSMOUTH CITY COLLECTION',
                            style: AppStyles.title,
                            textAlign: TextAlign.center,
                          ),
                        ),

                        const SizedBox(height: 48),

                        const Row(
                          children: [
                            Expanded(
                              child: ProductCard(
                                title: 'Placeholder Product 5',
                                price: '£10.00',
                                imageUrl: 'assets/images/postcard.jpg',
                              ),
                            ),
                            SizedBox(width: 24),
                            Expanded(
                              child: ProductCard(
                                title: 'Placeholder Product 6',
                                price: '£15.00',
                                imageUrl: 'assets/images/magnet.jpg',
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 48),
                        const Row(
                          children: [
                            Expanded(
                              child: ProductCard(
                                title: 'Placeholder Product 7',
                                price: '£10.00',
                                imageUrl: 'assets/images/bookmark.jpg',
                              ),
                            ),
                            SizedBox(width: 24),
                            Expanded(
                              child: ProductCard(
                                title: 'Placeholder Product 8',
                                price: '£15.00',
                                imageUrl: 'assets/images/postcard.jpg',
                              ),
                            ),
                          ],
                        ),

                        const SizedBox(height: 24),

                        // VIEW ALL button
                        Center(
                          child: ElevatedButton(
                            onPressed: () {},
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Color(0xFF4d2963),
                              foregroundColor: Colors.white,
                              padding: const EdgeInsets.symmetric(
                                horizontal: 32,
                                vertical: 12,
                              ),
                              shape: const RoundedRectangleBorder(
                                borderRadius: BorderRadius.zero,
                              ),
                            ),
                            child: const Text(
                              'VIEW ALL',
                              style: TextStyle(
                                letterSpacing: 1,
                                fontSize: 14,
                              ),
                            ),
                          ),
                        ),

                        const SizedBox(height: 24),

                        // 4 square images, centered and same total width
                        const Wrap(
                          alignment: WrapAlignment.center,
                          spacing: 24,
                          runSpacing: 24,
                          children: [
                            _SquareImage(
                              imagePath:
                                  'assets/images/PurpleHoodieFinal_540x.webp',
                            ),
                            _SquareImage(
                              imagePath: 'assets/images/card_holder.jpg',
                            ),
                            _SquareImage(
                              imagePath: 'assets/images/grey_hoodie.webp',
                            ),
                            _SquareImage(
                              imagePath: 'assets/images/purple_notepad.webp',
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),

            // Footer from layout.dart
            const AppFooter(),
          ],
        ),
      ),
    );
  }
}

class ProductCard extends StatelessWidget {
  final String title;
  final String price;
  final String imageUrl;

  const ProductCard({
    super.key,
    required this.title,
    required this.price,
    required this.imageUrl,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        Navigator.pushNamed(context, '/product');
      },
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // was: Expanded(child: Image.asset(...))
          SizedBox(
            height: 320, // smaller image height; reduce/increase as needed
            width: double.infinity,
            child: Image.asset(
              imageUrl,
              fit: BoxFit.cover,
              errorBuilder: (context, error, stackTrace) {
                return Container(
                  color: Colors.grey[300],
                  child: const Center(
                    child: Icon(Icons.image_not_supported, color: Colors.grey),
                  ),
                );
              },
            ),
          ),
          const SizedBox(height: 4),
          Text(
            title,
            style: const TextStyle(fontSize: 14, color: Colors.black),
            maxLines: 2,
          ),
          const SizedBox(height: 4),
          Text(
            price,
            style: const TextStyle(fontSize: 13, color: Colors.grey),
          ),
        ],
      ),
    );
  }
}

class _SquareImage extends StatelessWidget {
  final String imagePath;

  const _SquareImage({Key? key, required this.imagePath}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 250, // increased size
      height: 250, // increased size
      decoration: BoxDecoration(
        image: DecorationImage(
          image: AssetImage(imagePath),
          fit: BoxFit.cover,
        ),
      ),
    );
  }
}
