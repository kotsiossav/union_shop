import 'dart:math';

import 'package:flutter/material.dart';
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
    'assets/images/The_Union_Print_Shack_Logo.webp',
  ];

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
            final asset = pick(rowIndex * 3 + colIndex);
            return Expanded(
              child: Padding(
                // gutter between images
                padding: const EdgeInsets.symmetric(horizontal: 24.0),
                // compute height based on available width instead of hardcoding
                child: LayoutBuilder(builder: (context, constraints) {
                  // constraints.maxWidth is the width allocated to this item
                  final itemWidth = constraints.maxWidth;

                  // make images less tall by using a larger aspectRatio (width/height)
                  // and cap the computed height as a fraction of the viewport height
                  const aspectRatio = 0.85; // larger -> less tall
                  final rawHeight = itemWidth / aspectRatio;
                  final maxAllowedHeight =
                      MediaQuery.of(context).size.height * 0.35;
                  final computedHeight = min(rawHeight, maxAllowedHeight);

                  return SizedBox(
                    height: computedHeight,
                    child: HoverImage(
                      imageUrl: asset,
                      // pass computed sizes if HoverImage uses them; if not, it will size to parent
                      width: itemWidth,
                      height: computedHeight,
                      fit: BoxFit.cover,
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

            // Centered bold "collections" heading — vertical padding tripled (was 32)
            const Padding(
              padding: EdgeInsets.symmetric(vertical: 96.0),
              child: Center(
                child: Text(
                  'collections',
                  style: TextStyle(
                    fontSize: 28,
                    fontWeight: FontWeight.bold,
                  ),
                  textAlign: TextAlign.center,
                ),
              ),
            ),

            // small intro / placeholder — padding tripled (was 16)
            Container(
              padding: const EdgeInsets.all(48),
              child: const Text('Collections Page Content Here'),
            ),

            const SizedBox(height: 48),

            // 5 rows with 3 images each
            ...rows,

            const AppFooter(),
          ],
        ),
      ),
    );
  }
}
