import 'dart:math';

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
    'Clothing- Original',
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
        .replaceAll(RegExp(r'[^a-z0-9\s\-]'), '') // remove non-alnum/space/hyphen
        .trim()
        .replaceAll(RegExp(r'\s+'), '-'); // spaces -> hyphens
  }

  @override
  Widget build(BuildContext context) {
    // ensure we have enough images by cycling through the list
    String pick(int index) => _assetImages[index % _assetImages.length];

    // build 5 rows, each row with 3 images (add explicit left/right padding per row)
    final rows = List<Widget>.generate(5, (rowIndex) {
      return Padding(
        padding: const EdgeInsets.only(
            left: 72.0, right: 72.0, top: 36.0, bottom: 36.0),
        child: Row(
          children: List<Widget>.generate(3, (colIndex) {
            final globalIndex = rowIndex * 3 + colIndex;
            final asset = pick(globalIndex);
            // use explicit label list when available, otherwise fallback to filename label
            final label = globalIndex < _overlayLabels.length
                ? _overlayLabels[globalIndex]
                : _labelFromPath(asset);

            return Expanded(
              child: Padding(
                // gutter between images
                padding: const EdgeInsets.symmetric(horizontal: 24.0),
                // compute height based on available width instead of hardcoding
                child: LayoutBuilder(builder: (context, constraints) {
                  final itemWidth = constraints.maxWidth;

                  // choose aspect ratio to make images slightly taller than wide
                  const aspectRatio = 0.85; // width / height
                  final rawHeight = itemWidth / aspectRatio;
                  final maxAllowedHeight =
                      MediaQuery.of(context).size.height * 0.35;
                  final computedHeight = min(rawHeight, maxAllowedHeight);

                  final slug = _slugify(label);

                  return SizedBox(
                    height: computedHeight,
                    child: GestureDetector(
                      onTap: () {
                        // navigate to /collection/$slug
                        GoRouter.of(context).go('/collection/$slug');
                      },
                      child: ClipRRect(
                        borderRadius: BorderRadius.zero,
                        child: Stack(
                          fit: StackFit.expand,
                          children: [
                            // image (preserve existing HoverImage usage)
                            HoverImage(
                              imageUrl: asset,
                              width: itemWidth,
                              height: computedHeight,
                              fit: BoxFit.cover,
                            ),

                            // centered white text (no background) with subtle shadow for readability
                            Center(
                              child: Text(
                                label,
                                textAlign: TextAlign.center,
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontSize: 22, // increased size
                                  fontWeight: FontWeight.bold, // stronger weight
                                  shadows: [
                                    Shadow(
                                      offset: Offset(0, 1),
                                      blurRadius: 6,
                                      color: Colors.black54,
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  );
                }),
              ),
            );
          }),
        ),
      );
    });

    return Scaffold(
      body: SingleChildScrollView(
        child: Column(
          children: [
            const AppHeader(),
            const SizedBox(height: 24),
            // Centered bold "collections" heading (removed extra padding)
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

            // 5 rows with 3 images each
            ...rows,

            const AppFooter(),
          ],
        ),
      ),
    );
  }
}
