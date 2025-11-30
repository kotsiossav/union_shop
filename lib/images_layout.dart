import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:union_shop/app_styles.dart';

/// Reusable product card used across the app (moved from homepage.dart)
class ProductCard extends StatelessWidget {
  final String title;
  final String price;
  final String imageUrl;
  final String? discountPrice; // optional
  final String? category; // optional
  final String? collection; // collection slug for routing

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
          // convert price string like "£10.00" -> 10.00 (numeric) before passing
          final numericPrice =
              double.tryParse(price.replaceAll(RegExp(r'[^0-9.]'), '')) ?? 0.0;

          // create URL-safe slugs from collection and product title
          final productSlug = Uri.encodeComponent(
              title.toLowerCase().replaceAll(RegExp(r'\s+'), '-'));

          // use collection slug if provided, otherwise use category or 'all'
          final collectionSlug = collection ?? category ?? 'all';

          // navigate to /collections/:collectionSlug/products/:productSlug
          context.push('/collections/$collectionSlug/products/$productSlug', extra: {
            'imageUrl': imageUrl,
            'price': numericPrice,
            'category': category,
          });
        },
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            HoverImage(
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
            // show either single price or original+discount with strikethrough
            if (discountPrice == null)
              Text(
                price,
                style: const TextStyle(fontSize: 13, color: Colors.grey),
              )
            else
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

/// Square image tile with centered white label
class SquareImage extends StatelessWidget {
  final String imagePath;
  final String? label; // optional

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

/// HoverImage — always uses local assets, shows optional centered label and hover brighten
class HoverImage extends StatefulWidget {
  final String imageUrl;
  final double? width;
  final double height;
  final String? label; // optional

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
            // base image (local asset)
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

/// Simple model for hero slides (if used elsewhere)
class HeroSlide {
  final String imagePath;
  final String title;
  final String subtitle;
  final String buttonText;

  const HeroSlide({
    required this.imagePath,
    required this.title,
    required this.subtitle,
    required this.buttonText,
  });
}
