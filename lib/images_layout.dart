import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:union_shop/app_styles.dart';

// Reusable product card widget displaying product image, title, and pricing
// Used throughout the app (homepage, collection pages, search results)
// Handles navigation to product detail page with all necessary data
class ProductCard extends StatelessWidget {
  final String title; // Product name
  final String price; // Display price (formatted with currency symbol)
  final String imageUrl; // Path to product image (local asset)
  final String? discountPrice; // Optional sale price (formatted)
  final String? category; // Optional product category
  final String?
      collection; // Collection slug for routing (e.g., "essential-range")

  const ProductCard({
    super.key,
    required this.title,
    required this.price,
    required this.imageUrl,
    this.discountPrice,
    this.category,
    this.collection,
  });

  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      cursor: SystemMouseCursors.click,
      child: GestureDetector(
        onTap: () {
          // Parse price strings (e.g., "£10.00") to numeric values for product page
          final numericPrice =
              double.tryParse(price.replaceAll(RegExp(r'[^0-9.]'), '')) ?? 0.0;
          final numericDiscPrice = discountPrice != null
              ? double.tryParse(
                  discountPrice!.replaceAll(RegExp(r'[^0-9.]'), ''))
              : null;

          // Create URL-safe slug from product title (e.g., "Blue Hoodie" -> "blue-hoodie")
          final productSlug = Uri.encodeComponent(
              title.toLowerCase().replaceAll(RegExp(r'\s+'), '-'));

          // Use collection slug if available, otherwise fall back to category or 'all'
          final collectionSlug = collection ?? category ?? 'all';

          // Navigate to product detail page with route parameters and extra data
          context.push('/collections/$collectionSlug/products/$productSlug',
              extra: {
                'imageUrl': imageUrl,
                'price': numericPrice,
                'discPrice': numericDiscPrice,
                'category': category,
              });
        },
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Product image with hover effect
            HoverImage(
              imageUrl: imageUrl,
              height: 320,
            ),
            const SizedBox(height: 4),
            // Product title (max 2 lines with ellipsis)
            Text(
              title,
              style: const TextStyle(fontSize: 14, color: Colors.black),
              maxLines: 2,
            ),
            const SizedBox(height: 4),
            // Price display - shows either single price or discount price with strikethrough
            if (discountPrice == null)
              // No discount - show regular price only
              Text(
                price,
                style: const TextStyle(fontSize: 13, color: Colors.grey),
              )
            else
              // Discount active - show original price with strikethrough and discount price in blue
              Row(
                children: [
                  Text(
                    price,
                    style: const TextStyle(
                      fontSize: 13,
                      color: Colors.grey,
                      decoration: TextDecoration.lineThrough,
                    ),
                  ),
                  const SizedBox(width: 8),
                  Text(
                    discountPrice!,
                    style: const TextStyle(
                      fontSize: 13,
                      color: Colors.blue,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
          ],
        ),
      ),
    );
  }
}

// Square image widget with optional centered label
// Used for category tiles on homepage (Clothing, Merchandise, etc.)
class SquareImage extends StatelessWidget {
  final String imagePath; // Path to image asset
  final String? label; // Optional text overlay

  const SquareImage({
    Key? key,
    required this.imagePath,
    this.label,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return HoverImage(
      imageUrl: imagePath,
      width: 250,
      height: 250,
      label: label,
    );
  }
}

// Image widget with hover brightness effect and optional text overlay
// Always uses local assets (not network images)
// Provides visual feedback on mouse hover for desktop users
class HoverImage extends StatefulWidget {
  final String imageUrl; // Path to local image asset
  final double? width; // Optional width constraint
  final double height; // Required height
  final String? label; // Optional centered text overlay

  const HoverImage({
    Key? key,
    required this.imageUrl,
    this.width,
    required this.height,
    this.label,
  }) : super(key: key);

  @override
  State<HoverImage> createState() => HoverImageState();
}

class HoverImageState extends State<HoverImage> {
  // Track whether mouse is currently hovering over image
  bool _hovering = false;

  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      // Update hover state when mouse enters/exits
      onEnter: (_) => setState(() => _hovering = true),
      onExit: (_) => setState(() => _hovering = false),
      child: AnimatedContainer(
        // Smooth transition when hover state changes
        duration: const Duration(milliseconds: 120),
        width: widget.width ?? double.infinity,
        height: widget.height,
        child: Stack(
          fit: StackFit.expand,
          children: [
            // Base product image loaded from local assets
            Image.asset(
              widget.imageUrl,
              fit: BoxFit.cover,
              // Fallback widget if image fails to load
              errorBuilder: (context, error, stackTrace) {
                return Container(
                  color: Colors.grey[300],
                  child: const Center(
                    child: Icon(Icons.image_not_supported, color: Colors.grey),
                  ),
                );
              },
            ),

            // Base darkening overlay (always visible)
            Container(
              color: Colors.black.withOpacity(0.25),
            ),

            // Additional brightening effect on hover
            AnimatedContainer(
              duration: const Duration(milliseconds: 120),
              color: _hovering
                  ? Colors.white.withOpacity(0.12) // Lighten on hover
                  : Colors.transparent,
            ),

            // Centered white text label if provided
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

// Data model for hero carousel slides
// Stores slide content (image, title, subtitle, button text)
class HeroSlide {
  final String imagePath; // Background image for this slide
  final String title; // Main heading text
  final String subtitle; // Descriptive text below title
  final String buttonText; // Call-to-action button label

  const HeroSlide({
    required this.imagePath,
    required this.title,
    required this.subtitle,
    required this.buttonText,
  });
}
