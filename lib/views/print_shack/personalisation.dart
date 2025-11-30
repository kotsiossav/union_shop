import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:union_shop/layout.dart';

class PersonilationPage extends StatefulWidget {
  const PersonilationPage({super.key});

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
  String? _selectedPersonalisation;

  // controllers for the dynamic text boxes
  final List<TextEditingController> _lineControllers = [];

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
    final col = FirebaseFirestore.instance.collection('products');
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

  @override
  void initState() {
    super.initState();
    _selectedPersonalisation = _personalisationOptions.first;
    _updateControllersForSelection(_selectedPersonalisation);
  }

  @override
  void dispose() {
    for (final c in _lineControllers) {
      c.dispose();
    }
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
        final sel = (_selectedPersonalisation ?? '').toLowerCase();
        int linesCount = 0;
        if (sel.startsWith('one'))
          linesCount = 1;
        else if (sel.startsWith('two'))
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

        // Single scroll view for the whole page (no nested scrollables).
        // Product header (image/title/price) will be part of the same scroll,
        // avoiding nested scrolling behaviour.
        return Scaffold(
          appBar: AppBar(title: const Text('Print Shack — Personalisation')),
          body: SingleChildScrollView(
            padding: const EdgeInsets.all(24.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const AppHeader(),

                // product preview card: image left, title on right, price below title
                Card(
                  elevation: 2,
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        SizedBox(
                          width: 260,
                          height: 260,
                          child: isNetwork
                              ? Image.network(
                                  imageUrl,
                                  fit: BoxFit.cover,
                                  errorBuilder: (ctx, err, st) => const Center(
                                      child: Icon(Icons.image,
                                          size: 56, color: Colors.grey)),
                                )
                              : Image.asset(
                                  imageUrl.isEmpty
                                      ? 'assets/images/personalisation_placeholder.png'
                                      : imageUrl,
                                  fit: BoxFit.cover,
                                  errorBuilder: (ctx, err, st) => const Center(
                                      child: Icon(Icons.image,
                                          size: 56, color: Colors.grey)),
                                ),
                        ),
                        const SizedBox(width: 20),

                        // limit details column width so it doesn't take the whole row
                        ConstrainedBox(
                          constraints: const BoxConstraints(maxWidth: 360),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                title.isNotEmpty ? title : 'Personalisation',
                                style: const TextStyle(
                                    fontSize: 22, fontWeight: FontWeight.bold),
                              ),
                              const SizedBox(height: 8),
                              Text(
                                // show base + extra dynamically
                                _formatPrice(totalPrice),
                                style: const TextStyle(
                                    fontSize: 18, color: Colors.black87),
                              ),
                              const SizedBox(height: 12),
                              const Text(
                                'Choose personalisation option',
                                style: TextStyle(
                                    fontSize: 16, fontWeight: FontWeight.w600),
                              ),
                              const SizedBox(height: 8),
                              DropdownButton<String>(
                                value: _selectedPersonalisation,
                                isExpanded: true,
                                items: _personalisationOptions
                                    .map((opt) => DropdownMenuItem(
                                          value: opt,
                                          child: Text(opt),
                                        ))
                                    .toList(),
                                onChanged: (v) {
                                  setState(() {
                                    _selectedPersonalisation = v;
                                    _updateControllersForSelection(v);
                                  });
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
                          ),
                        ),
                      ],
                    ),
                  ),
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
                          _selectedPersonalisation ?? '',
                          if (lines.isNotEmpty) 'Text: ${lines.join(" • ")}'
                        ].where((s) => s.isNotEmpty).join(' — ');

                        final titleLabel =
                            title.isNotEmpty ? title : 'Personalisation';
                        final priceLabel = _formatPrice(totalPrice);

                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text(
                                'Added "$titleLabel"${details.isNotEmpty ? " ($details)" : ""} — $priceLabel to cart'),
                          ),
                        );
                        // TODO: hook into real cart state / backend/add quantity field
                      },
                      child: const Padding(
                        padding: EdgeInsets.symmetric(vertical: 12.0),
                        child:
                            Text('Add to cart', style: TextStyle(fontSize: 16)),
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 24),
                const AppFooter(),
              ],
            ),
          ),
        );
      },
    );
  }
}
