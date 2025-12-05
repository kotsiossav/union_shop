import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:union_shop/layout.dart';
import 'package:union_shop/app_styles.dart';
import 'package:union_shop/images_layout.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

// Homepage displaying hero slideshow, featured products, and collection links
class HomeScreen extends StatefulWidget {
  final bool enableProducts; // Allow disabling products for testing

  const HomeScreen({super.key, this.enableProducts = true});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final PageController _heroController = PageController();
  int _currentHeroPage = 0; // Track current slide index

  // Hero slideshow data
  final List<HeroSlide> _slides = const [
    HeroSlide(
      imagePath: 'assets/images/Pink_Essential_Hoodie_720x.webp',
      title: 'Essential Range - Over 20% Off!',
      subtitle:
          'Over 20% off our essential range.come and grab yours while stock lasts!.',
      buttonText: 'Browse products',
    ),
    HeroSlide(
      imagePath: 'assets/images/grey_hoodie.webp',
      title: 'The Print Shack',
      subtitle:
          'Lets create something uniquely you with our personalisation servive-From £3 for one line of text.',
      buttonText: 'Add personal text',
    ),
  ];

  void navigateToHome(BuildContext context) {
    Navigator.pushNamedAndRemoveUntil(context, '/', (route) => false);
  }

  void navigateToProduct(BuildContext context) {
    Navigator.pushNamed(context, '/product');
  }

  void placeholderCallbackForButtons() {
    // This is the event handler for buttons that don't work yet
  }

  // Parse price from Firestore (handles both numbers and strings)
  double _parsePrice(dynamic raw) {
    if (raw is num) return raw.toDouble();
    if (raw is String) {
      String cleaned = raw.replaceAll(RegExp(r'[^0-9.]'), '');
      double? val = double.tryParse(cleaned);
      if (val != null) {
        return val < 10 ? val * 100 : val;
      }
    }
    return 0.0;
  }

  // Format price as currency string
  String _formatPrice(double v) => '£${v.toStringAsFixed(2)}';

  // Parse collection string from Firestore
  List<String> _collParts(dynamic raw) {
    if (raw == null) return [];
    return raw
        .toString()
        .replaceAll(RegExp("^['\"]+|['\"]+\$"), '')
        .split(',')
        .map((s) => s.trim().toLowerCase())
        .where((s) => s.isNotEmpty)
        .toList();
  }

  // Build product card by fetching data from Firestore
  Widget _buildProductCard(String productTitle) {
    return FutureBuilder<DocumentSnapshot>(
      future: FirebaseFirestore.instance
          .collection('products')
          .where('title', isEqualTo: productTitle)
          .limit(1)
          .get()
          .then((snapshot) => snapshot.docs.isNotEmpty
              ? snapshot.docs.first
              : throw Exception('Product not found')),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }
        if (snapshot.hasError || !snapshot.hasData) {
          return const Center(child: Text('Error loading product'));
        }

        // Extract and clean product data
        final data = snapshot.data!.data() as Map<String, dynamic>;
        final rawImage = (data['image_url'] as String?) ?? '';
        final imageUrl =
            rawImage.replaceAll(RegExp("^['\"]+|['\"]+\$"), '').trim();
        final rawTitle = (data['title'] as String?) ?? '';
        final titleText =
            rawTitle.replaceAll(RegExp("^['\"]+|['\"]+\$"), '').trim();
        final priceNum = _parsePrice(data['price']);
        final discRaw =
            data['disc_price'] ?? data['discPrice'] ?? data['discount_price'];
        final discNum = discRaw != null ? _parsePrice(discRaw) : null;
        final rawCat = (data['cat'] as String?) ?? '';
        final category =
            rawCat.replaceAll(RegExp("^['\"]+|['\"]+\$"), '').trim();
        final collParts = _collParts(data['coll']);
        final collection = collParts.isNotEmpty ? collParts.first : 'all';

        return ProductCard(
          imageUrl: imageUrl,
          title: titleText,
          price: _formatPrice(priceNum),
          discountPrice: discNum != null ? _formatPrice(discNum) : null,
          category: category,
          collection: collection,
        );
      },
    );
  }

  // Handle hero slideshow button clicks
  void _onHeroButtonPressed(int index) {
    if (index == 0) {
      context.go('/collections/essential-range');
    } else if (index == 1) {
      context.go('/personalisation');
    }
  }

  // Navigate to previous slide (wraps to last if at first)
  void _goToPreviousSlide() {
    final int targetIndex =
        _currentHeroPage > 0 ? _currentHeroPage - 1 : _slides.length - 1;

    _heroController.animateToPage(
      targetIndex,
      duration: const Duration(milliseconds: 250),
      curve: Curves.easeInOut,
    );
  }

  // Navigate to next slide (wraps to first if at last)
  void _goToNextSlide() {
    final int targetIndex =
        _currentHeroPage < _slides.length - 1 ? _currentHeroPage + 1 : 0;

    _heroController.animateToPage(
      targetIndex,
      duration: const Duration(milliseconds: 250),
      curve: Curves.easeInOut,
    );
  }

  @override
  void dispose() {
    _heroController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SingleChildScrollView(
        child: Column(
          children: [
            const AppHeader(),

            // Hero slideshow section with responsive sizing
            LayoutBuilder(
              builder: (context, constraints) {
                final isMobile = constraints.maxWidth < 600;

                return SizedBox(
                  height: isMobile ? 300 : 400,
                  width: double.infinity,
                  child: Stack(
                    children: [
                      // PageView for swipeable slides
                      PageView.builder(
                        controller: _heroController,
                        itemCount: _slides.length,
                        onPageChanged: (idx) {
                          setState(() => _currentHeroPage = idx);
                        },
                        itemBuilder: (context, index) {
                          final slide = _slides[index];
                          return Stack(
                            fit: StackFit.expand,
                            children: [
                              // Background image
                              Image.asset(
                                slide.imagePath,
                                fit: BoxFit.cover,
                              ),
                              // Dark overlay for text readability
                              Container(
                                color: Colors.black.withOpacity(0.7),
                              ),
                              // Centered text and button content
                              Center(
                                child: Padding(
                                  padding: const EdgeInsets.symmetric(
                                      horizontal: 24),
                                  child: Column(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      Text(
                                        slide.title,
                                        style: TextStyle(
                                          fontSize: isMobile ? 24 : 48,
                                          fontWeight: FontWeight.bold,
                                          color: Colors.white,
                                          height: 1.2,
                                        ),
                                        textAlign: TextAlign.center,
                                      ),
                                      const SizedBox(height: 16),
                                      Text(
                                        slide.subtitle,
                                        style: TextStyle(
                                          fontSize: isMobile ? 16 : 30,
                                          color: Colors.white,
                                          height: 1.5,
                                        ),
                                        textAlign: TextAlign.center,
                                      ),
                                      const SizedBox(height: 32),
                                      ElevatedButton(
                                        onPressed: () =>
                                            _onHeroButtonPressed(index),
                                        style: ElevatedButton.styleFrom(
                                          backgroundColor:
                                              const Color(0xFF4d2963),
                                          foregroundColor: Colors.white,
                                          shape: const RoundedRectangleBorder(
                                            borderRadius: BorderRadius.zero,
                                          ),
                                        ),
                                        child: Text(
                                          slide.buttonText.toUpperCase(),
                                          style: const TextStyle(
                                            fontSize: 14,
                                            letterSpacing: 1,
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            ],
                          );
                        },
                      ),

                      // Navigation controls (arrows + dots) at bottom center
                      Positioned(
                        bottom: 12,
                        left: 0,
                        right: 0,
                        child: Center(
                          child: Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 8,
                              vertical: 4,
                            ),
                            decoration: BoxDecoration(
                              color: Colors.black.withOpacity(0.5),
                              borderRadius: BorderRadius.zero,
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                // Previous slide arrow
                                IconButton(
                                  iconSize: 18,
                                  padding: EdgeInsets.zero,
                                  constraints: const BoxConstraints(),
                                  color: Colors.white70,
                                  onPressed: _goToPreviousSlide,
                                  icon: const Icon(Icons.arrow_back_ios),
                                ),

                                const SizedBox(width: 6),

                                // Page indicator dots
                                Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children:
                                      List.generate(_slides.length, (index) {
                                    final bool isActive =
                                        index == _currentHeroPage;
                                    return AnimatedContainer(
                                      duration:
                                          const Duration(milliseconds: 200),
                                      margin: const EdgeInsets.symmetric(
                                          horizontal: 3),
                                      width: 8,
                                      height: 8,
                                      decoration: BoxDecoration(
                                        shape: BoxShape.circle,
                                        color: isActive
                                            ? Colors.white
                                            : Colors.white54,
                                      ),
                                    );
                                  }),
                                ),

                                const SizedBox(width: 6),

                                // Next slide arrow
                                IconButton(
                                  iconSize: 18,
                                  padding: EdgeInsets.zero,
                                  constraints: const BoxConstraints(),
                                  color: Colors.white70,
                                  onPressed: _goToNextSlide,
                                  icon: const Icon(Icons.arrow_forward_ios),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                );
              },
            ),

            // Products section with responsive layout
            Container(
              color: Colors.white,
              child: LayoutBuilder(
                builder: (context, constraints) {
                  final isMobile = constraints.maxWidth < 600;
                  final containerWidth =
                      isMobile ? constraints.maxWidth : 1100.0;
                  final padding = isMobile ? 16.0 : 40.0;

                  return Padding(
                    padding: EdgeInsets.all(padding),
                    child: Center(
                      child: SizedBox(
                        width: containerWidth,
                        child: Column(
                          children: [
                            // Essential Range section title
                            const Text(
                              'ESSENTIAL RANGE - OVER 20% OFF!',
                              style: AppStyles.title,
                              textAlign: TextAlign.center,
                            ),
                            SizedBox(height: isMobile ? 24 : 48),

                            // First pair of products (responsive: row or column)
                            if (isMobile)
                              Column(
                                children: [
                                  widget.enableProducts
                                      ? _buildProductCard(
                                          'Placeholder Product 1')
                                      : const SizedBox.shrink(),
                                  const SizedBox(height: 24),
                                  widget.enableProducts
                                      ? _buildProductCard(
                                          'Placeholder Product 2')
                                      : const SizedBox.shrink(),
                                ],
                              )
                            else
                              Row(
                                children: [
                                  Expanded(
                                    child: widget.enableProducts
                                        ? _buildProductCard(
                                            'Placeholder Product 1')
                                        : const SizedBox.shrink(),
                                  ),
                                  const SizedBox(width: 24),
                                  Expanded(
                                    child: widget.enableProducts
                                        ? _buildProductCard(
                                            'Placeholder Product 2')
                                        : const SizedBox.shrink(),
                                  ),
                                ],
                              ),

                            SizedBox(height: isMobile ? 24 : 48),

                            // Signature Range section title
                            const Center(
                              child: Text(
                                'SIGNATURE RANGE',
                                style: AppStyles.title,
                                textAlign: TextAlign.center,
                              ),
                            ),

                            SizedBox(height: isMobile ? 24 : 48),

                            // Second pair of products
                            if (isMobile)
                              Column(
                                children: [
                                  widget.enableProducts
                                      ? _buildProductCard(
                                          'Placeholder Product 3')
                                      : const SizedBox.shrink(),
                                  const SizedBox(height: 24),
                                  widget.enableProducts
                                      ? _buildProductCard(
                                          'Placeholder Product 4')
                                      : const SizedBox.shrink(),
                                ],
                              )
                            else
                              Row(
                                children: [
                                  Expanded(
                                    child: widget.enableProducts
                                        ? _buildProductCard(
                                            'Placeholder Product 3')
                                        : const SizedBox.shrink(),
                                  ),
                                  const SizedBox(width: 24),
                                  Expanded(
                                    child: widget.enableProducts
                                        ? _buildProductCard(
                                            'Placeholder Product 4')
                                        : const SizedBox.shrink(),
                                  ),
                                ],
                              ),

                            SizedBox(height: isMobile ? 24 : 48),

                            // Portsmouth City Collection section title
                            const Center(
                              child: Text(
                                'PORTSMOUTH CITY COLLECTION',
                                style: AppStyles.title,
                                textAlign: TextAlign.center,
                              ),
                            ),

                            SizedBox(height: isMobile ? 24 : 48),

                            // Third pair of products
                            if (isMobile)
                              Column(
                                children: [
                                  widget.enableProducts
                                      ? _buildProductCard(
                                          'Placeholder Product 5')
                                      : const SizedBox.shrink(),
                                  const SizedBox(height: 24),
                                  widget.enableProducts
                                      ? _buildProductCard(
                                          'Placeholder Product 6')
                                      : const SizedBox.shrink(),
                                ],
                              )
                            else
                              Row(
                                children: [
                                  Expanded(
                                    child: widget.enableProducts
                                        ? _buildProductCard(
                                            'Placeholder Product 5')
                                        : const SizedBox.shrink(),
                                  ),
                                  const SizedBox(width: 24),
                                  Expanded(
                                    child: widget.enableProducts
                                        ? _buildProductCard(
                                            'Placeholder Product 6')
                                        : const SizedBox.shrink(),
                                  ),
                                ],
                              ),

                            SizedBox(height: isMobile ? 24 : 48),

                            // Fourth pair of products
                            if (isMobile)
                              Column(
                                children: [
                                  widget.enableProducts
                                      ? _buildProductCard(
                                          'Placeholder Product 7')
                                      : const SizedBox.shrink(),
                                  const SizedBox(height: 24),
                                  widget.enableProducts
                                      ? _buildProductCard(
                                          'Placeholder Product 8')
                                      : const SizedBox.shrink(),
                                ],
                              )
                            else
                              Row(
                                children: [
                                  Expanded(
                                    child: widget.enableProducts
                                        ? _buildProductCard(
                                            'Placeholder Product 7')
                                        : const SizedBox.shrink(),
                                  ),
                                  const SizedBox(width: 24),
                                  Expanded(
                                    child: widget.enableProducts
                                        ? _buildProductCard(
                                            'Placeholder Product 8')
                                        : const SizedBox.shrink(),
                                  ),
                                ],
                              ),

                            SizedBox(height: isMobile ? 24 : 48),

                            // View all button navigating to sale collection
                            Center(
                              child: ElevatedButton(
                                onPressed: () {
                                  context.go('/collections/sale');
                                },
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

                            SizedBox(height: isMobile ? 24 : 48),

                            SizedBox(height: isMobile ? 24 : 48),

                            // Our Range section title
                            const Center(
                              child: Text(
                                'OUR RANGE',
                                style: AppStyles.title,
                                textAlign: TextAlign.center,
                              ),
                            ),

                            SizedBox(height: isMobile ? 24 : 48),

                            // Category images grid (4 clickable squares)
                            Wrap(
                              alignment: WrapAlignment.center,
                              spacing: 24,
                              runSpacing: 24,
                              children: [
                                GestureDetector(
                                  onTap: () =>
                                      context.go('/collections/clothing'),
                                  child: const SquareImage(
                                    imagePath:
                                        'assets/images/PurpleHoodieFinal_540x.webp',
                                    label: 'Clothing',
                                  ),
                                ),
                                GestureDetector(
                                  onTap: () =>
                                      context.go('/collections/merchandise'),
                                  child: const SquareImage(
                                    imagePath: 'assets/images/card_holder.jpg',
                                    label: 'Merchandise',
                                  ),
                                ),
                                GestureDetector(
                                  onTap: () =>
                                      context.go('/collections/graduation'),
                                  child: const SquareImage(
                                    imagePath: 'assets/images/grey_hoodie.webp',
                                    label: 'Graduation',
                                  ),
                                ),
                                GestureDetector(
                                  onTap: () => context.go('/collections/sale'),
                                  child: const SquareImage(
                                    imagePath:
                                        'assets/images/purple_notepad.webp',
                                    label: 'SALE',
                                  ),
                                ),
                              ],
                            ),

                            SizedBox(height: isMobile ? 24 : 48),

                            // Personalisation service section (responsive layout)
                            if (isMobile)
                              Column(
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
                                    onPressed: () =>
                                        context.go('/personalisation'),
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
                                      'Click here to add text!',
                                      style: TextStyle(
                                        letterSpacing: 1,
                                        fontSize: 14,
                                      ),
                                    ),
                                  ),
                                  const SizedBox(height: 24),
                                  SizedBox(
                                    width: double.infinity,
                                    height: 250,
                                    child: Image.asset(
                                      'assets/images/The_Union_Print_Shack_Logo.webp',
                                      fit: BoxFit.contain,
                                    ),
                                  ),
                                ],
                              )
                            else
                              Row(
                                crossAxisAlignment: CrossAxisAlignment.center,
                                children: [
                                  // Text and button on left side
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
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
                                          onPressed: () =>
                                              context.go('/personalisation'),
                                          style: ElevatedButton.styleFrom(
                                            backgroundColor:
                                                const Color(0xFF4d2963),
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
                                            'Click here to add text!',
                                            style: TextStyle(
                                              letterSpacing: 1,
                                              fontSize: 14,
                                            ),
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),

                                  const SizedBox(width: 48),

                                  // Print Shack logo on right side
                                  SizedBox(
                                    width: 450,
                                    height: 300,
                                    child: Image.asset(
                                      'assets/images/The_Union_Print_Shack_Logo.webp',
                                      fit: BoxFit.contain,
                                    ),
                                  ),
                                ],
                              ),

                            SizedBox(height: isMobile ? 24 : 48),
                          ],
                        ),
                      ),
                    ),
                  );
                },
              ),
            ),

            const AppFooter(),
          ],
        ),
      ),
    );
  }
}
