import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:union_shop/layout.dart';
import 'package:union_shop/main.dart';

class PersonilationPage extends StatefulWidget {
  final FirebaseFirestore? firestore;

  const PersonilationPage({super.key, this.firestore});

  @override
  State<PersonilationPage> createState() => _PersonilationPageState();
}

class _PersonilationPageState extends State<PersonilationPage> {
  final List<String> _personalisationOptions = [
    'One line of text',
    'Two lines of text',
    'Three lines of text',
    'Four lines of text',
    'Small logo',
    'Large logo',
  ];
  late final ValueNotifier<String?> _selectedPersonalisation;

  // controllers for the dynamic text boxes
  final List<TextEditingController> _lineControllers = [];

  // quantity selector (using ValueNotifier to avoid full page rebuild)
  final ValueNotifier<int> _quantity = ValueNotifier<int>(1);

  // keep controllers count in sync with selection
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

    // add controllers if needed
    while (_lineControllers.length < count) {
      _lineControllers.add(TextEditingController());
    }
    // remove extra controllers
    while (_lineControllers.length > count) {
      _lineControllers.removeLast().dispose();
    }
  }

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

  String _extractImage(Map<String, dynamic> d) {
    return (d['image_url'] ?? d['imageUrl'] ?? d['image'] ?? '') as String;
  }

  String _extractTitle(Map<String, dynamic> d) {
    return (d['title'] ?? '') as String;
  }

  String _extractCategory(Map<String, dynamic> d) {
    return (d['cat'] ?? d['category'] ?? '') as String;
  }

  double _parsePrice(dynamic raw) {
    if (raw == null) return 0.0;
    if (raw is num) return raw.toDouble();
    final s = raw.toString();
    final numeric = s.replaceAll(RegExp(r'[^0-9.]'), '');
    return double.tryParse(numeric) ?? 0.0;
  }

  String _formatPrice(double p) => '£${p.toStringAsFixed(2)}';

  Widget _buildProductDetails(String title, double totalPrice, bool isMobile) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title.isNotEmpty ? title : 'Personalisation',
          style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 8),
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
        ValueListenableBuilder<String?>(
          valueListenable: _selectedPersonalisation,
          builder: (context, selectedValue, child) {
            return Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
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
                // dynamic text boxes based on selection
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
        // quantity selector (isolated rebuild)
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

  @override
  void initState() {
    super.initState();
    _selectedPersonalisation =
        ValueNotifier<String?>(_personalisationOptions.first);
    _updateControllersForSelection(_selectedPersonalisation.value);
  }

  @override
  void dispose() {
    for (var c in _lineControllers) {
      c.dispose();
    }
    _selectedPersonalisation.dispose();
    _quantity.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<Map<String, dynamic>?>(
      future: _fetchPersonalisationProduct(),
      builder: (context, snap) {
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

        final data = snap.data!;
        final rawImage = _extractImage(data);
        final imageUrl = rawImage
            .toString()
            .replaceAll(RegExp("^['\"]+|['\"]+\$"), '')
            .replaceAll('\\', '/')
            .trim();

        final title = _extractTitle(data);
        final price = _parsePrice(data['price']);
        // compute extra charge based on selected personalisation:
        final sel = (_selectedPersonalisation.value ?? '').toLowerCase();
        int linesCount = 0;
        if (sel.startsWith('one')) {
          linesCount = 1;
        } else if (sel.startsWith('two'))
          linesCount = 2;
        else if (sel.startsWith('three'))
          linesCount = 3;
        else if (sel.startsWith('four')) linesCount = 4;
        // extra only applies to "lines of text" options: £2 per extra line beyond the first
        final double extra = sel.contains('line') && linesCount > 1
            ? (linesCount - 1) * 2.0
            : 0.0;
        final double totalPrice = price + extra;
        final bool isNetwork = imageUrl.startsWith('http');

        // Responsive layout: use LayoutBuilder to adapt to screen size
        return Scaffold(
          appBar: AppBar(title: const Text('Print Shack — Personalisation')),
          body: Column(
            children: [
              const AppHeader(),
              Expanded(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.all(24.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // product preview card: responsive layout
                      LayoutBuilder(
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
                                        // Image on top for mobile
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
                                        // Image on left for desktop
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
                                                              color:
                                                                  Colors.grey)),
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
                                                              color:
                                                                  Colors.grey)),
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
                      ),

                      const SizedBox(height: 24),

                      // Add to cart button
                      Center(
                        child: SizedBox(
                          width: 280,
                          child: ElevatedButton(
                            onPressed: () {
                              final lines = _lineControllers
                                  .map((c) => c.text.trim())
                                  .where((t) => t.isNotEmpty)
                                  .toList();
                              final details = [
                                _selectedPersonalisation.value ?? '',
                                if (lines.isNotEmpty)
                                  'Text: ${lines.join(" • ")}'
                              ].where((s) => s.isNotEmpty).join(' — ');

                              final titleLabel =
                                  title.isNotEmpty ? title : 'Personalisation';
                              final titleWithDetails = details.isNotEmpty
                                  ? '$titleLabel ($details)'
                                  : titleLabel;
                              final priceLabel = _formatPrice(totalPrice);
                              final quantityText = _quantity.value > 1
                                  ? ' (×${_quantity.value})'
                                  : '';

                              // Add to cart with the specified quantity
                              for (int i = 0; i < _quantity.value; i++) {
                                globalCart.addProduct(
                                  title: titleWithDetails,
                                  imageUrl: imageUrl,
                                  price: totalPrice,
                                  category: 'personalisation',
                                );
                              }

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
                      ),
                      const SizedBox(height: 24),
                    ],
                  ),
                ),
              ),
              const AppFooter(),
            ],
          ),
        );
      },
    );
  }
}
