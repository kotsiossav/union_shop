import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'main.dart';

/// Shared navigation bar used on all pages.
class AppHeader extends StatefulWidget {
  const AppHeader({super.key});

  @override
  State<AppHeader> createState() => _AppHeaderState();
}

class _AppHeaderState extends State<AppHeader> {
  void _placeholderCallbackForButtons() {}

  @override
  void initState() {
    super.initState();
    globalCart.addListener(_onCartChanged);
  }

  @override
  void dispose() {
    globalCart.removeListener(_onCartChanged);
    super.dispose();
  }

  void _onCartChanged() {
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    return Column(
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

        Container(
          decoration: const BoxDecoration(
            color: Colors.white,
            border: Border(
              bottom: BorderSide(
                color: Colors.black,
                width: 1.0,
              ),
            ),
          ),
          child: LayoutBuilder(
            builder: (context, constraints) {
              final bool isNarrow = constraints.maxWidth < 800;

              return Padding(
                padding:
                    const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                child: Row(
                  children: [
                    // Logo (use local asset, smaller size)
                    GestureDetector(
                      onTap: () => context.go('/'),
                      child: Image.asset(
                        'assets/images/logo2.png',
                        height: 45,
                        fit: BoxFit.contain,
                      ),
                    ),

                    // Desktop navigation
                    if (!isNarrow)
                      Expanded(
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Flexible(
                                child: _NavItem(
                                    label: "Home",
                                    onTap: () => context.go('/'))),
                            Flexible(
                                child: PopupMenuButton<String>(
                              onSelected: (value) {
                                context.go('/collections/$value');
                              },
                              itemBuilder: (ctx) => const [
                                PopupMenuItem(
                                  value: 'essential-range',
                                  child: Text('Essential Range'),
                                ),
                                PopupMenuItem(
                                  value: 'signature-range',
                                  child: Text('Signature Range'),
                                ),
                                PopupMenuItem(
                                  value: 'graduation',
                                  child: Text('Graduation'),
                                ),
                                PopupMenuItem(
                                  value: 'autumn-favourites',
                                  child: Text('Autumn Favourites'),
                                ),
                                PopupMenuItem(
                                  value: 'sale',
                                  child: Text('Sale'),
                                ),
                              ],
                              child: const Padding(
                                padding: EdgeInsets.symmetric(horizontal: 12),
                                child: MouseRegion(
                                  cursor: SystemMouseCursors.click,
                                  child: Text(
                                    'Shop',
                                    style: TextStyle(
                                      fontSize: 14,
                                      color: Colors.black87,
                                      fontWeight: FontWeight.w500,
                                    ),
                                  ),
                                ),
                              ),
                            )),
                            Flexible(
                                child: PopupMenuButton<String>(
                              onSelected: (value) {
                                if (value == 'about') {
                                  context.go('/print_shack_about');
                                } else if (value == 'personalisation') {
                                  context.go('/personalisation');
                                }
                              },
                              itemBuilder: (ctx) => const [
                                PopupMenuItem(
                                  value: 'about',
                                  child: Text('About'),
                                ),
                                PopupMenuItem(
                                  value: 'personalisation',
                                  child: Text('Personalisation'),
                                ),
                              ],
                              child: const Padding(
                                padding: EdgeInsets.symmetric(horizontal: 12),
                                child: MouseRegion(
                                  cursor: SystemMouseCursors.click,
                                  child: Text(
                                    'The Print Shack',
                                    style: TextStyle(
                                      fontSize: 14,
                                      color: Colors.black87,
                                      fontWeight: FontWeight.w500,
                                    ),
                                  ),
                                ),
                              ),
                            )),
                            Flexible(
                                child: _NavItem(
                                    label: "SALE!",
                                    onTap: () =>
                                        context.go('/collections/sale'))),
                            Flexible(
                                child: _NavItem(
                                    label: "About",
                                    onTap: () => context.go('/about'))),
                          ],
                        ),
                      ),

                    // Icons on the right (always shown)
                    Row(
                      children: [
                        _icon(Icons.search, onTap: () => context.go('/search')),
                        // navigate to SignInPage when person icon is pressed
                        _icon(Icons.person_outline,
                            onTap: () => context.go('/login_page')),
                        _cartIconWithBadge(context),

                        // Mobile menu button
                        if (isNarrow)
                          _icon(Icons.menu, onTap: () {
                            showModalBottomSheet(
                              context: context,
                              builder: (_) {
                                return Column(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    ListTile(
                                        leading: const Icon(Icons.home),
                                        title: const Text('Home'),
                                        onTap: () => context.go('/')),
                                    ListTile(
                                        leading: const Icon(Icons.shop),
                                        title: const Text('Shop'),
                                        onTap: () =>
                                            context.go('/collections')),
                                    ListTile(
                                        leading: const Icon(Icons.print),
                                        title:
                                            const Text('Print Shack - About'),
                                        onTap: () =>
                                            context.go('/print_shack_about')),
                                    ListTile(
                                        leading: const Icon(Icons.person),
                                        title: const Text(
                                            'Print Shack - Personalisation'),
                                        onTap: () =>
                                            context.go('/personalisation')),
                                    ListTile(
                                        leading: const Icon(Icons.local_offer),
                                        title: const Text('SALE!'),
                                        onTap: () => context.go('/sale')),
                                    ListTile(
                                        leading: const Icon(Icons.info),
                                        title: const Text('About'),
                                        onTap: () => context.go('/about')),
                                  ],
                                );
                              },
                            );
                          }),
                      ],
                    ),
                  ],
                ),
              );
            },
          ),
        ),
      ],
    );
  }

  Widget _cartIconWithBadge(BuildContext context) {
    final itemCount = globalCart.itemCount;

    return Stack(
      clipBehavior: Clip.none,
      children: [
        IconButton(
          icon: const Icon(Icons.shopping_bag_outlined,
              size: 20, color: Colors.grey),
          padding: const EdgeInsets.all(6),
          constraints: const BoxConstraints(minWidth: 32, minHeight: 32),
          onPressed: () => context.go('/cart'),
        ),
        if (itemCount > 0)
          Positioned(
            right: 0,
            top: 0,
            child: Container(
              padding: const EdgeInsets.all(4),
              decoration: const BoxDecoration(
                color: Color(0xFF4d2963),
                shape: BoxShape.circle,
              ),
              constraints: const BoxConstraints(
                minWidth: 18,
                minHeight: 18,
              ),
              child: Text(
                '$itemCount',
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 10,
                  fontWeight: FontWeight.bold,
                ),
                textAlign: TextAlign.center,
              ),
            ),
          ),
      ],
    );
  }

  Widget _icon(IconData icon, {VoidCallback? onTap}) {
    return IconButton(
      icon: Icon(icon, size: 20, color: Colors.grey),
      padding: const EdgeInsets.all(6),
      constraints: const BoxConstraints(minWidth: 32, minHeight: 32),
      onPressed: onTap ?? _placeholderCallbackForButtons,
    );
  }
}

/// Shared footer used on all pages.
class AppFooter extends StatelessWidget {
  const AppFooter({super.key});

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final bool isNarrow = constraints.maxWidth < 700;

        // ----------------------------------
        // NARROW SCREEN (Column layout)
        // ----------------------------------
        if (isNarrow) {
          return Container(
            width: double.infinity,
            color: Colors.grey[50],
            padding: const EdgeInsets.all(24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _footerColumn1(),
                const SizedBox(height: 32),
                _footerColumn2(),
                const SizedBox(height: 32),
                _footerColumn3(),
              ],
            ),
          );
        }

        // ----------------------------------
        // DESKTOP / WIDE SCREEN (Row layout)
        // ----------------------------------
        return Container(
          width: double.infinity,
          color: Colors.grey[50],
          padding: const EdgeInsets.all(40),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(child: _footerColumn1()),
              const SizedBox(width: 40),
              Expanded(child: _footerColumn2()),
              const SizedBox(width: 40),
              Expanded(child: _footerColumn3()),
            ],
          ),
        );
      },
    );
  }

  // --------------------------
  // COLUMN 1: Opening Hours
  // --------------------------
  Widget _footerColumn1() {
    return const Column(
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
    );
  }

  // --------------------------
  // COLUMN 2: Help Links
  // --------------------------
  Widget _footerColumn2() {
    return const Column(
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
        _FooterLink("Search"),
        SizedBox(height: 4),
        _FooterLink("Terms & Conditions of Sale Policy"),
      ],
    );
  }

  // --------------------------
  // COLUMN 3: Email subscribe
  // --------------------------
  Widget _footerColumn3() {
    return Column(
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
              height: 48,
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
    );
  }
}

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
    // ALWAYS load local assets via Image.asset (no network requests)
    final image = Image.asset(
      widget.imageUrl,
      fit: widget.fit,
      width: widget.width,
      height: widget.height,
      errorBuilder: (ctx, err, stack) => Container(
        color: Colors.grey.shade200,
        alignment: Alignment.center,
        child: const Icon(Icons.broken_image, color: Colors.grey),
      ),
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

class _FooterLink extends StatefulWidget {
  final String label;

  const _FooterLink(this.label);

  @override
  State<_FooterLink> createState() => _FooterLinkState();
}

class _FooterLinkState extends State<_FooterLink> {
  bool _hovered = false;

  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      onEnter: (_) => setState(() => _hovered = true),
      onExit: (_) => setState(() => _hovered = false),
      cursor: SystemMouseCursors.click,
      child: Text(
        widget.label,
        style: TextStyle(
          color: _hovered ? Colors.black54 : Colors.black87,
        ),
      ),
    );
  }
}
