import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:union_shop/layout.dart';

class CollectionsPage extends StatelessWidget {
  const CollectionsPage({super.key});

  // local assets used for the grid (add or remove paths to match your assets/)
  static const List<String> _assetImages = [
    'assets/images/Pink_Essential_Hoodie_720x.webp',
    'assets/images/grey_hoodie.webp',
    'assets/images/Sage_T-shirt_720x.webp',
    'assets/images/SageHoodie_720x.webp',
    'assets/images/Signature_T-Shirt_Indigo_Blue_2_720x.webp',
    'assets/images/postcard.jpg',
    'assets/images/magnet.jpg',
    'assets/images/bookmark.jpg',
    'assets/images/PurpleHoodieFinal_540x.webp',
    'assets/images/card_holder.jpg',
    'assets/images/purple_notepad.webp',
  ];

  static const List<String> _overlayLabels = [
    'Autumn Favourites',
    'Black Friday',
    'Clothing',
    'Clothing Original',
    'Election Discounts',
    'Essential Range',
    'Graduation',
    'Limited edition essential zip hoodies',
    'merchandise',
    'pride collection',
    'sale',
    'Signature Range',
    'Spring Favourites',
    'Student Essentials',
    'Summer Collection',
  ];

  // helper: produce a readable label from an asset path (fallback)
  String _labelFromPath(String path) {
    final filename = path.split('/').last;
    final base = filename.split('.').first;
    final words = base.replaceAll(RegExp(r'[_\-]+'), ' ').split(' ');
    return words
        .where((w) => w.isNotEmpty)
        .map((w) => w[0].toUpperCase() + w.substring(1).toLowerCase())
        .join(' ');
  }

  // create a URL-friendly slug from a label
  String _slugify(String label) {
    return label
        .toLowerCase()
        .replaceAll(RegExp("['\"]"), '') // remove quotes
        .replaceAll(
            RegExp(r'[^a-z0-9\s\-]'), '') // remove non-alnum/space/hyphen
        .trim()
        .replaceAll(RegExp(r'\s+'), '-'); // spaces -> hyphens
  }

  @override
  Widget build(BuildContext context) {
    // ensure we have enough images by cycling through the list
    String pick(int index) => _assetImages[index % _assetImages.length];

    return Scaffold(
      body: SingleChildScrollView(
        child: Column(
          children: [
            const AppHeader(),
            const SizedBox(height: 24),
            // Centered bold "collections" heading
            const Center(
              child: Text(
                'collections',
                style: TextStyle(
                  fontSize: 48,
                  fontWeight: FontWeight.bold,
                ),
                textAlign: TextAlign.center,
              ),
            ),
            const SizedBox(height: 24),

            // Responsive grid layout
            LayoutBuilder(
              builder: (context, constraints) {
                final screenWidth = constraints.maxWidth;
                final isMobile = screenWidth < 600;
                final isTablet = screenWidth >= 600 && screenWidth < 900;

                // Determine columns based on screen size
                final crossAxisCount = isMobile ? 1 : (isTablet ? 2 : 3);

                // Calculate padding based on screen size
                final horizontalPadding =
                    isMobile ? 16.0 : (isTablet ? 36.0 : 72.0);
                final verticalPadding = isMobile ? 12.0 : 36.0;
                final itemSpacing = isMobile ? 16.0 : 24.0;

                return Padding(
                  padding: EdgeInsets.symmetric(
                    horizontal: horizontalPadding,
                    vertical: verticalPadding,
                  ),
                  child: GridView.builder(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: crossAxisCount,
                      crossAxisSpacing: itemSpacing,
                      mainAxisSpacing: itemSpacing,
                      childAspectRatio: 0.85,
                    ),
                    itemCount: 15, // 5 rows × 3 items
                    itemBuilder: (context, index) {
                      final asset = pick(index);
                      final label = index < _overlayLabels.length
                          ? _overlayLabels[index]
                          : _labelFromPath(asset);
                      final slug = _slugify(label);

                      return GestureDetector(
                        onTap: () {
                          GoRouter.of(context).go('/collections/$slug');
                        },
                        child: ClipRRect(
                          borderRadius: BorderRadius.zero,
                          child: Stack(
                            fit: StackFit.expand,
                            children: [
                              // image
                              HoverImage(
                                imageUrl: asset,
                                width: double.infinity,
                                height: double.infinity,
                                fit: BoxFit.cover,
                              ),
                              // centered white text with shadow
                              Center(
                                child: Padding(
                                  padding: const EdgeInsets.all(8.0),
                                  child: Text(
                                    label,
                                    textAlign: TextAlign.center,
                                    style: TextStyle(
                                      color: Colors.white,
                                      fontSize: isMobile ? 18 : 22,
                                      fontWeight: FontWeight.bold,
                                      shadows: const [
                                        Shadow(
                                          offset: Offset(0, 1),
                                          blurRadius: 6,
                                          color: Colors.black54,
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      );
                    },
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
