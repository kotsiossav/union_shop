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
              onAbout: () {
                Navigator.pushNamed(context, '/about'); // go to AboutPage
              },
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
                        const SizedBox(height: 48),
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

                        const SizedBox(height: 48),

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

                        const SizedBox(height: 48),

                        // OUR RANGE title
                        const Center(
                          child: Text(
                            'OUR RANGE',
                            style: AppStyles.title,
                            textAlign: TextAlign.center,
                          ),
                        ),

                        const SizedBox(height: 48),

                        // 4 square images, centered and same total width
                        const Wrap(
                          alignment: WrapAlignment.center,
                          spacing: 24,
                          runSpacing: 24,
                          children: [
                            _SquareImage(
                              imagePath:
                                  'assets/images/PurpleHoodieFinal_540x.webp',
                              label: 'Clothing',
                            ),
                            _SquareImage(
                              imagePath: 'assets/images/card_holder.jpg',
                              label: 'Merchandise',
                            ),
                            _SquareImage(
                              imagePath: 'assets/images/grey_hoodie.webp',
                              label: 'Graduation',
                            ),
                            _SquareImage(
                              imagePath: 'assets/images/purple_notepad.webp',
                              label: 'SALE',
                            ),
                          ],
                        ),

                        const SizedBox(height: 48),

                        // Add a Personal Touch section
                        Row(
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                            // Left side: text + button
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  const Text(
                                    'Add a Personal Touch',
                                    style: AppStyles.title,
                                  ),
                                  const SizedBox(height: 16),
                                  const Text(
                                    'First add your item of clothing to your cart then click below to add your text! '
                                    'One line of text contains 10 characters!',
                                    style: AppStyles.subtitle,
                                  ),
                                  const SizedBox(height: 24),
                                  ElevatedButton(
                                    onPressed: placeholderCallbackForButtons,
                                    style: ElevatedButton.styleFrom(
                                      backgroundColor: const Color(0xFF4d2963),
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
                                      'Click here to add text',
                                      style: TextStyle(
                                        letterSpacing: 1,
                                        fontSize: 14,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),

                            const SizedBox(height: 148),

                            // Right side: smaller image
                            SizedBox(
                              width: 450, // adjust as you like
                              height: 300, // adjust as you like
                              child: Image.asset(
                                'assets/images/The_Union_Print_Shack_Logo.webp',
                                fit: BoxFit.contain, // was BoxFit.cover
                              ),
                            ),
                          ],
                        ),

                        const SizedBox(height: 48),
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
    return MouseRegion(
      cursor: SystemMouseCursors.click,
      child: GestureDetector(
        onTap: () {
          Navigator.pushNamed(context, '/product');
        },
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _HoverImage(
              imageUrl: imageUrl,
              height: 320,
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
      ),
    );
  }
}

class _SquareImage extends StatelessWidget {
  final String imagePath;
  final String? label; // optional

  const _SquareImage({
    Key? key,
    required this.imagePath,
    this.label, // not required anymore
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return _HoverImage(
      imageUrl: imagePath,
      width: 250,
      height: 250,
      label: label,
    );
  }
}

class _HoverImage extends StatefulWidget {
  final String imageUrl;
  final double? width;
  final double height;
  final String? label; // optional

  const _HoverImage({
    Key? key,
    required this.imageUrl,
    this.width,
    required this.height,
    this.label, // optional
  }) : super(key: key);

  @override
  State<_HoverImage> createState() => _HoverImageState();
}

class _HoverImageState extends State<_HoverImage> {
  bool _hovering = false;

  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      onEnter: (_) => setState(() => _hovering = true),
      onExit: (_) => setState(() => _hovering = false),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 120),
        width: widget.width ?? double.infinity,
        height: widget.height,
        child: Stack(
          fit: StackFit.expand,
          children: [
            // base image
            Image.asset(
              widget.imageUrl,
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

            // base grey shading (always on)
            Container(
              color: Colors.black.withOpacity(0.25),
            ),

            // extra brighten / change on hover (optional)
            AnimatedContainer(
              duration: const Duration(milliseconds: 120),
              color: _hovering
                  ? Colors.white.withOpacity(0.12)
                  : Colors.transparent,
            ),

            // centered label if provided
            if (widget.label != null)
              Center(
                child: Text(
                  widget.label!,
                  style: AppStyles.title.copyWith(
                    color: Colors.white,
                  ),
                  textAlign: TextAlign.center,
                ),
              ),
          ],
        ),
      ),
    );
  }
}
