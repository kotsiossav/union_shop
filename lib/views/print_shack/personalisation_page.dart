import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:union_shop/layout.dart';
import 'package:union_shop/routing.dart';

/// Page for customizing products with personalized text or logos
class PersonilationPage extends StatefulWidget {
  final FirebaseFirestore? firestore;

  const PersonilationPage({super.key, this.firestore});

  @override
  State<PersonilationPage> createState() => _PersonilationPageState();
}

class _PersonilationPageState extends State<PersonilationPage> {
  /// Available personalization options (text lines or logo sizes)
  final List<String> _personalisationOptions = [
    'One line of text',
    'Two lines of text',
    'Three lines of text',
    'Four lines of text',
    'Small logo',
    'Large logo',
  ];

  /// Currently selected personalization option
  late final ValueNotifier<String?> _selectedPersonalisation;

  /// Text input controllers for each line of text
  final List<TextEditingController> _lineControllers = [];

  /// Product quantity (reactive to avoid full page rebuild)
  final ValueNotifier<int> _quantity = ValueNotifier<int>(1);

  /// Adjusts number of text controllers based on selected option
  void _updateControllersForSelection(String? selection) {
    int count = 1;
    final s = (selection ?? '').toLowerCase();
    if (s.startsWith('one'))
      count = 1;
    else if (s.startsWith('two'))
      count = 2;
    else if (s.startsWith('three'))
      count = 3;
    else if (s.startsWith('four'))
      count = 4;
    else if (s.contains('small') || s.contains('large')) count = 1;

    /// Add controllers if needed
    while (_lineControllers.length < count) {
      _lineControllers.add(TextEditingController());
    }

    /// Remove and dispose extra controllers
    while (_lineControllers.length > count) {
      _lineControllers.removeLast().dispose();
    }
  }

  /// Fetches personalisation product from Firestore
  Future<Map<String, dynamic>?> _fetchPersonalisationProduct() async {
    final firestore = widget.firestore ?? FirebaseFirestore.instance;
    final col = firestore.collection('products');
    var q = await col.where('cat', isEqualTo: 'personalisation').limit(1).get();
    if (q.docs.isEmpty) {
      q = await col.where('title', isEqualTo: 'Personalisation').limit(1).get();
    }
    if (q.docs.isEmpty) return null;
    return q.docs.first.data();
  }

  /// Extracts image URL from product data
  String _extractImage(Map<String, dynamic> d) {
    return (d['image_url'] ?? d['imageUrl'] ?? d['image'] ?? '') as String;
  }

  /// Extracts product title from product data
  String _extractTitle(Map<String, dynamic> d) {
    return (d['title'] ?? '') as String;
  }

  /// Parses price from various formats (number or string)
  double _parsePrice(dynamic raw) {
    if (raw == null) return 0.0;
    if (raw is num) return raw.toDouble();
    final s = raw.toString();
    final numeric = s.replaceAll(RegExp(r'[^0-9.]'), '');
    return double.tryParse(numeric) ?? 0.0;
  }

  /// Formats price as currency string
  String _formatPrice(double p) => '£${p.toStringAsFixed(2)}';

  /// Builds product details section with options and quantity selector
  Widget _buildProductDetails(String title, double totalPrice, bool isMobile) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        /// Product title
        Text(
          title.isNotEmpty ? title : 'Personalisation',
          style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 8),

        /// Product price (updates dynamically with selection)
        Text(
          _formatPrice(totalPrice),
          style: const TextStyle(fontSize: 18, color: Colors.black87),
        ),
        const SizedBox(height: 12),
        const Text(
          'Choose personalisation option',
          style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
        ),
        const SizedBox(height: 8),

        /// Dropdown for selecting personalization type
        ValueListenableBuilder<String?>(
          valueListenable: _selectedPersonalisation,
          builder: (context, selectedValue, child) {
            return Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                /// Dropdown menu with all personalization options
                DropdownButton<String>(
                  value: selectedValue,
                  isExpanded: true,
                  items: _personalisationOptions
                      .map((opt) => DropdownMenuItem(
                            value: opt,
                            child: Text(opt),
                          ))
                      .toList(),
                  onChanged: (v) {
                    _selectedPersonalisation.value = v;
                    _updateControllersForSelection(v);
                  },
                ),
                const SizedBox(height: 12),

                /// Dynamic text input fields (count depends on selected option)
                Column(
                  children: List.generate(
                    _lineControllers.length,
                    (i) => Padding(
                      padding: const EdgeInsets.only(bottom: 8),
                      child: TextField(
                        controller: _lineControllers[i],
                        decoration: InputDecoration(
                          labelText: _lineControllers.length > 1
                              ? 'Line ${i + 1}'
                              : 'Text',
                          border: OutlineInputBorder(),
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            );
          },
        ),
        const SizedBox(height: 16),

        /// Quantity selector with increment/decrement buttons
        ValueListenableBuilder<int>(
          valueListenable: _quantity,
          builder: (context, quantity, child) {
            return Row(
              mainAxisSize: isMobile ? MainAxisSize.max : MainAxisSize.min,
              children: [
                const Text(
                  'Quantity:',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
                ),
                const SizedBox(width: 16),
                IconButton(
                  onPressed: quantity > 1 ? () => _quantity.value-- : null,
                  icon: const Icon(Icons.remove),
                ),
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  decoration: BoxDecoration(
                    border: Border.all(color: Colors.grey),
                    borderRadius: BorderRadius.circular(4),
                  ),
                  child: Text(
                    '$quantity',
                    style: const TextStyle(fontSize: 16),
                  ),
                ),
                IconButton(
                  onPressed: quantity < 99 ? () => _quantity.value++ : null,
                  icon: const Icon(Icons.add),
                ),
              ],
            );
          },
        ),
      ],
    );
  }

  /// Initialize with first option selected and create initial controllers
  @override
  void initState() {
    super.initState();
    _selectedPersonalisation =
        ValueNotifier<String?>(_personalisationOptions.first);
    _updateControllersForSelection(_selectedPersonalisation.value);
  }

  /// Clean up controllers and notifiers to prevent memory leaks
  @override
  void dispose() {
    for (var c in _lineControllers) {
      c.dispose();
    }
    _selectedPersonalisation.dispose();
    _quantity.dispose();
    super.dispose();
  }

  /// Build page with product data from Firestore
  @override
  Widget build(BuildContext context) {
    return FutureBuilder<Map<String, dynamic>?>(
      future: _fetchPersonalisationProduct(),
      builder: (context, snap) {
        /// Show loading spinner while fetching product data
        if (snap.connectionState == ConnectionState.waiting) {
          return Scaffold(
            appBar: AppBar(title: const Text('Print Shack — Personalisation')),
            body: const Column(
              children: [
                AppHeader(),
                Expanded(child: Center(child: CircularProgressIndicator())),
                AppFooter(),
              ],
            ),
          );
        }

        /// Show error message if product not found
        if (!snap.hasData || snap.data == null) {
          return Scaffold(
            appBar: AppBar(title: const Text('Print Shack — Personalisation')),
            body: const Column(
              children: [
                AppHeader(),
                Expanded(
                  child: Padding(
                    padding: EdgeInsets.all(24.0),
                    child: Center(
                      child: Text(
                        'Personalisation product not found in the database.',
                        textAlign: TextAlign.center,
                      ),
                    ),
                  ),
                ),
                AppFooter(),
              ],
            ),
          );
        }

        /// Extract and process product data
        final data = snap.data!;
        final rawImage = _extractImage(data);
        final imageUrl = rawImage
            .toString()
            .replaceAll(RegExp("^['\"]+ |['\"]+ \$"), '')
            .replaceAll('\\', '/')
            .trim();

        final title = _extractTitle(data);
        final price = _parsePrice(data['price']);

        /// Check if image is from network or local asset
        final bool isNetwork = imageUrl.startsWith('http');

        /// Build responsive layout that adapts to screen size
        return Scaffold(
          appBar: AppBar(title: const Text('Print Shack — Personalisation')),
          body: SingleChildScrollView(
            child: Column(
              children: [
                const AppHeader(),
                Padding(
                  padding: const EdgeInsets.all(24.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      /// Product preview card with dynamic pricing
                      ValueListenableBuilder<String?>(
                        valueListenable: _selectedPersonalisation,
                        builder: (context, selectedValue, child) {
                          /// Calculate extra charges based on selection
                          final sel = (selectedValue ?? '').toLowerCase();
                          int linesCount = 0;
                          if (sel.startsWith('one')) {
                            linesCount = 1;
                          } else if (sel.startsWith('two'))
                            linesCount = 2;
                          else if (sel.startsWith('three'))
                            linesCount = 3;
                          else if (sel.startsWith('four')) linesCount = 4;

                          /// Pricing: £2/line for text, £4 for large logo, £0 for small logo
                          final double extra;
                          if (sel.contains('line') && linesCount > 0) {
                            extra = linesCount * 2.0;
                          } else if (sel.contains('large')) {
                            extra = 4.0;
                          } else {
                            extra = 0.0;
                          }
                          final double totalPrice = price + extra;

                          /// Responsive layout: mobile (column) vs desktop (row)
                          return LayoutBuilder(
                            builder: (context, constraints) {
                              final isMobile = constraints.maxWidth < 600;

                              return Card(
                                elevation: 2,
                                child: Padding(
                                  padding: const EdgeInsets.all(16.0),
                                  child: isMobile
                                      ? Column(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          children: [
                                            /// Mobile: image above details
                                            Center(
                                              child: SizedBox(
                                                width: double.infinity,
                                                height: 260,
                                                child: isNetwork
                                                    ? Image.network(
                                                        imageUrl,
                                                        fit: BoxFit.cover,
                                                        errorBuilder: (ctx, err,
                                                                st) =>
                                                            const Center(
                                                                child: Icon(
                                                                    Icons.image,
                                                                    size: 56,
                                                                    color: Colors
                                                                        .grey)),
                                                      )
                                                    : Image.asset(
                                                        imageUrl.isEmpty
                                                            ? 'assets/images/personalisation_placeholder.png'
                                                            : imageUrl,
                                                        fit: BoxFit.cover,
                                                        errorBuilder: (ctx, err,
                                                                st) =>
                                                            const Center(
                                                                child: Icon(
                                                                    Icons.image,
                                                                    size: 56,
                                                                    color: Colors
                                                                        .grey)),
                                                      ),
                                              ),
                                            ),
                                            const SizedBox(height: 16),
                                            _buildProductDetails(
                                                title, totalPrice, isMobile),
                                          ],
                                        )
                                      : Row(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          children: [
                                            /// Desktop: image on left side
                                            SizedBox(
                                              width: 260,
                                              height: 260,
                                              child: isNetwork
                                                  ? Image.network(
                                                      imageUrl,
                                                      fit: BoxFit.cover,
                                                      errorBuilder: (ctx, err,
                                                              st) =>
                                                          const Center(
                                                              child: Icon(
                                                                  Icons.image,
                                                                  size: 56,
                                                                  color: Colors
                                                                      .grey)),
                                                    )
                                                  : Image.asset(
                                                      imageUrl.isEmpty
                                                          ? 'assets/images/personalisation_placeholder.png'
                                                          : imageUrl,
                                                      fit: BoxFit.cover,
                                                      errorBuilder: (ctx, err,
                                                              st) =>
                                                          const Center(
                                                              child: Icon(
                                                                  Icons.image,
                                                                  size: 56,
                                                                  color: Colors
                                                                      .grey)),
                                                    ),
                                            ),
                                            const SizedBox(width: 20),
                                            Expanded(
                                              child: _buildProductDetails(
                                                  title, totalPrice, isMobile),
                                            ),
                                          ],
                                        ),
                                ),
                              );
                            },
                          );
                        },
                      ),

                      const SizedBox(height: 24),

                      /// Add to cart button with current price
                      ValueListenableBuilder<String?>(
                        valueListenable: _selectedPersonalisation,
                        builder: (context, selectedValue, child) {
                          /// Recalculate price for cart
                          final sel = (selectedValue ?? '').toLowerCase();
                          int linesCount = 0;
                          if (sel.startsWith('one')) {
                            linesCount = 1;
                          } else if (sel.startsWith('two'))
                            linesCount = 2;
                          else if (sel.startsWith('three'))
                            linesCount = 3;
                          else if (sel.startsWith('four')) linesCount = 4;

                          final double extra;
                          if (sel.contains('line') && linesCount > 0) {
                            extra = linesCount * 2.0;
                          } else if (sel.contains('large')) {
                            extra = 4.0;
                          } else {
                            extra = 0.0;
                          }
                          final double totalPrice = price + extra;

                          return Center(
                            child: SizedBox(
                              width: 280,
                              child: ElevatedButton(
                                onPressed: () {
                                  /// Collect entered text from all input fields
                                  final lines = _lineControllers
                                      .map((c) => c.text.trim())
                                      .where((t) => t.isNotEmpty)
                                      .toList();

                                  /// Build product details string for cart
                                  final details = [
                                    _selectedPersonalisation.value ?? '',
                                    if (lines.isNotEmpty)
                                      'Text: ${lines.join(" • ")}'
                                  ].where((s) => s.isNotEmpty).join(' — ');

                                  final titleLabel = title.isNotEmpty
                                      ? title
                                      : 'Personalisation';
                                  final titleWithDetails = details.isNotEmpty
                                      ? '$titleLabel ($details)'
                                      : titleLabel;
                                  final priceLabel = _formatPrice(totalPrice);
                                  final quantityText = _quantity.value > 1
                                      ? ' (×${_quantity.value})'
                                      : '';

                                  /// Add items to cart (multiple if quantity > 1)
                                  for (int i = 0; i < _quantity.value; i++) {
                                    globalCart.addProduct(
                                      title: titleWithDetails,
                                      imageUrl: imageUrl,
                                      price: totalPrice,
                                      category: 'personalisation',
                                    );
                                  }

                                  /// Show confirmation message
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    SnackBar(
                                      content: Text(
                                          'Added "$titleLabel"${details.isNotEmpty ? " ($details)" : ""}$quantityText — $priceLabel to cart'),
                                    ),
                                  );
                                },
                                child: const Padding(
                                  padding: EdgeInsets.symmetric(vertical: 12.0),
                                  child: Text('Add to cart',
                                      style: TextStyle(fontSize: 16)),
                                ),
                              ),
                            ),
                          );
                        },
                      ),
                      const SizedBox(height: 24),
                    ],
                  ),
                ),
                const AppFooter(),
              ],
            ),
          ),
        );
      },
    );
  }
}
