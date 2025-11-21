import 'package:flutter/material.dart';

/// Shared navigation bar used on all pages.
class AppHeader extends StatelessWidget {
  final VoidCallback onHome;
  final VoidCallback onShop;
  final VoidCallback onSale;
  final VoidCallback onPrintShack;
  final VoidCallback onAbout;

  const AppHeader({
    super.key,
    required this.onHome,
    required this.onShop,
    required this.onSale,
    required this.onPrintShack,
    required this.onAbout,
  });

  void _placeholderCallbackForButtons() {
    // shared placeholder
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 100,
      decoration: const BoxDecoration(
        color: Colors.white,
        border: Border(
          bottom: BorderSide(
            color: Colors.grey, // line color
            width: 1, // thin solid line
          ),
        ),
      ),
      child: Column(
        children: [
          // Top banner
          Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(vertical: 8),
            color: const Color(0xFF4d2963),
            child: const Text(
              'BIG SALE! OUR ESSENTIAL RANGE HAS DROPPED IN PRICE! OVER 20% OFF! COME GRAB YOURS WHILE STOCK LASTS!',
              textAlign: TextAlign.center,
              style: TextStyle(color: Colors.white, fontSize: 16),
            ),
          ),
          // Main header
          Expanded(
            child: LayoutBuilder(
              builder: (context, constraints) {
                final isNarrow = constraints.maxWidth < 800;

                return Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 10),
                  child: Row(
                    children: [
                      // Logo
                      GestureDetector(
                        onTap: onHome,
                        child: Image.network(
                          'assets/images/logo2.png',
                          height: 80,
                          fit: BoxFit.cover,
                          errorBuilder: (context, error, stackTrace) {
                            return Container(
                              color: Colors.grey[300],
                              width: 30,
                              height: 30,
                              child: const Center(
                                child: Icon(Icons.image_not_supported,
                                    color: Colors.grey),
                              ),
                            );
                          },
                        ),
                      ),

                      const Spacer(),

                      if (!isNarrow) ...[
                        // NAVIGATION ITEMS – desktop / wide
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            _NavItem(label: "Home", onTap: onHome),
                            _NavItem(label: "Shop", onTap: onShop),
                            _NavItem(
                              label: "The Print Shack",
                              onTap: onPrintShack,
                            ),
                            _NavItem(label: "SALE!", onTap: onSale),
                            _NavItem(label: "About", onTap: onAbout),
                          ],
                        ),
                        const Spacer(),
                      ],

                      // Right-side icons (always shown)
                      Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          IconButton(
                            icon: const Icon(
                              Icons.search,
                              size: 18,
                              color: Colors.grey,
                            ),
                            padding: const EdgeInsets.all(8),
                            constraints: const BoxConstraints(
                              minWidth: 32,
                              minHeight: 32,
                            ),
                            onPressed: _placeholderCallbackForButtons,
                          ),
                          IconButton(
                            icon: const Icon(
                              Icons.person_outline,
                              size: 18,
                              color: Colors.grey,
                            ),
                            padding: const EdgeInsets.all(8),
                            constraints: const BoxConstraints(
                              minWidth: 32,
                              minHeight: 32,
                            ),
                            onPressed: _placeholderCallbackForButtons,
                          ),
                          IconButton(
                            icon: const Icon(
                              Icons.shopping_bag_outlined,
                              size: 18,
                              color: Colors.grey,
                            ),
                            padding: const EdgeInsets.all(8),
                            constraints: const BoxConstraints(
                              minWidth: 32,
                              minHeight: 32,
                            ),
                            onPressed: _placeholderCallbackForButtons,
                          ),

                          // On narrow screens, show a menu icon instead of the full nav row
                          if (isNarrow)
                            IconButton(
                              icon: const Icon(
                                Icons.menu,
                                size: 18,
                                color: Colors.grey,
                              ),
                              padding: const EdgeInsets.all(8),
                              constraints: const BoxConstraints(
                                minWidth: 32,
                                minHeight: 32,
                              ),
                              onPressed: _placeholderCallbackForButtons,
                            ),
                        ],
                      ),
                    ],
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}

/// Shared footer used on all pages.
class AppFooter extends StatelessWidget {
  const AppFooter({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      color: Colors.grey[50],
      padding: const EdgeInsets.all(40),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          // COLUMN 1
          const Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  "Opening Hours",
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Colors.black,
                  ),
                ),
                SizedBox(height: 12),
                Text("(Term Time)"),
                Text("Monday - Friday 9am - 4pm"),
                SizedBox(height: 8),
                Text("(Outside of Term Time / Consolidation Weeks)"),
                Text("Monday - Friday 9am - 3pm"),
                SizedBox(height: 8),
                Text("Purchase online 24/7"),
              ],
            ),
          ),

          SizedBox(width: 40),

          // COLUMN 2
          const Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  "Help and Information",
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Colors.black,
                  ),
                ),
                SizedBox(height: 12),
                Text("Search"),
                SizedBox(height: 4),
                Text("Terms & Conditions of Sale Policy"),
              ],
            ),
          ),

          SizedBox(width: 40),

          // COLUMN 3
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  "Latest Offers",
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Colors.black,
                  ),
                ),
                const SizedBox(height: 12),
                Row(
                  children: [
                    const Expanded(
                      child: TextField(
                        decoration: InputDecoration(
                          hintText: "Email address",
                          filled: true,
                          fillColor: Colors.white,
                          contentPadding: EdgeInsets.symmetric(
                            horizontal: 12,
                            vertical: 10,
                          ),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.zero,
                            borderSide: BorderSide(color: Colors.grey),
                          ),
                        ),
                      ),
                    ),
                    SizedBox(
                      height: 40,
                      child: ElevatedButton(
                        onPressed: () {},
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFF4d2963),
                          foregroundColor: Colors.white,
                          shape: const RoundedRectangleBorder(
                            borderRadius: BorderRadius.zero,
                          ),
                        ),
                        child: const Text("Subscribe"),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

/// Shared nav item with hover behaviour.
class _NavItem extends StatefulWidget {
  final String label;
  final VoidCallback onTap;

  const _NavItem({required this.label, required this.onTap});

  @override
  State<_NavItem> createState() => _NavItemState();
}

class _NavItemState extends State<_NavItem> {
  bool _isHovered = false;

  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      onEnter: (_) => setState(() => _isHovered = true),
      onExit: (_) => setState(() => _isHovered = false),
      cursor: SystemMouseCursors.click,
      child: GestureDetector(
        onTap: widget.onTap,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 12),
          child: Text(
            widget.label,
            style: TextStyle(
              fontSize: 14,
              color: Colors.black87,
              fontWeight: _isHovered ? FontWeight.bold : FontWeight.w500,
              decoration:
                  _isHovered ? TextDecoration.underline : TextDecoration.none,
            ),
          ),
        ),
      ),
    );
  }
}

class HoverImage extends StatefulWidget {
  final String imageUrl;
  final BoxFit fit;
  final double? width;
  final double? height;

  const HoverImage({
    super.key,
    required this.imageUrl,
    this.fit = BoxFit.cover,
    this.width,
    this.height,
  });

  @override
  State<HoverImage> createState() => _HoverImageState();
}

class _HoverImageState extends State<HoverImage> {
  bool _hovered = false;

  @override
  Widget build(BuildContext context) {
    final image = Image.network(
      widget.imageUrl,
      fit: widget.fit,
    );

    return MouseRegion(
      onEnter: (_) => setState(() => _hovered = true),
      onExit: (_) => setState(() => _hovered = false),
      child: ColorFiltered(
        colorFilter: ColorFilter.mode(
          // if hovered, multiply with white to appear brighter
          _hovered ? Colors.white.withOpacity(0.25) : Colors.transparent,
          BlendMode.srcATop,
        ),
        child: SizedBox(
          width: widget.width,
          height: widget.height,
          child: image,
        ),
      ),
    );
  }
}
