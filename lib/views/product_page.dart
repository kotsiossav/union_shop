import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:union_shop/layout.dart';
import 'package:union_shop/models/cart_model.dart';

class ProductPage extends StatefulWidget {
  final String imageUrl; // asset or network
  final String title;
  final double price;
  final double? discPrice; // optional discount price
  final String category;
  final CartModel cart;

  const ProductPage({
    super.key,
    required this.imageUrl,
    required this.title,
    required this.price,
    this.discPrice,
    required this.category,
    required this.cart,
  });

  @override
  State<ProductPage> createState() => _ProductPageState();
}

class _ProductPageState extends State<ProductPage> {
  int _quantity = 1;
  late final TextEditingController _qtyController;

  // dropdown state for clothing
  final List<String> _colors = ['Black', 'White', 'Navy', 'Red'];
  final List<String> _sizes = ['S', 'M', 'L', 'XL'];
  String? _selectedColor;
  String? _selectedSize;

  void navigateToHome(BuildContext context) {
    Navigator.pushNamedAndRemoveUntil(context, '/', (_) => false);
  }

  void placeholderCallbackForButtons() {}

  @override
  void initState() {
    super.initState();
    // Initialize quantity text controller with default value
    _qtyController = TextEditingController(text: '$_quantity');
    // Set default color and size selections if available
    _selectedColor = _colors.isNotEmpty ? _colors.first : null;
    _selectedSize = _sizes.isNotEmpty ? _sizes.first : null;
  }

  @override
  void dispose() {
    // Clean up text controller to prevent memory leaks
    _qtyController.dispose();
    super.dispose();
  }

  // Increase quantity by 1 and update text field
  void _increment() {
    setState(() {
      _quantity++;
      _qtyController.text = '$_quantity';
    });
  }

  // Decrease quantity by 1 (minimum is 1) and update text field
  void _decrement() {
    if (_quantity > 1) {
      setState(() {
        _quantity--;
        _qtyController.text = '$_quantity';
      });
    }
  }

  // Add product(s) to cart and show confirmation message
  void _addToCart() {
    // Use discount price if available, otherwise use regular price
    final effectivePrice = widget.discPrice ?? widget.price;
    // Add each item individually to cart (for accurate quantity tracking)
    for (int i = 0; i < _quantity; i++) {
      widget.cart.addProduct(
        title: widget.title,
        imageUrl: widget.imageUrl,
        price: effectivePrice,
        category: widget.category,
        color: _selectedColor,
        size: _selectedSize,
      );
    }

    // Show success message
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Added $_quantity × ${widget.title} to cart'),
        duration: const Duration(seconds: 2),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final bool isNetwork = widget.imageUrl.startsWith('http');

    return Scaffold(
      appBar: AppBar(title: Text(widget.title)),
      body: SingleChildScrollView(
        child: Column(
          children: [
            // Header
            const AppHeader(),

            // MAIN PRODUCT LAYOUT
            LayoutBuilder(
              builder: (context, constraints) {
                final bool isNarrow = constraints.maxWidth < 600;

                return Container(
                  color: Colors.white,
                  padding: const EdgeInsets.only(
                    top: 32,
                    left: 16,
                    right: 16,
                    bottom:
                        60, // Extra bottom padding to prevent footer overlap
                  ),

                  // ---------- NARROW LAYOUT (Column) ----------
                  child: isNarrow
                      ? Column(
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                            // Image
                            if (widget.imageUrl.isNotEmpty)
                              SizedBox(
                                width: constraints.maxWidth * 0.8,
                                height: 300,
                                child: isNetwork
                                    ? Image.network(
                                        widget.imageUrl,
                                        fit: BoxFit.cover,
                                        key: const Key('product_image'),
                                      )
                                    : Image.asset(
                                        widget.imageUrl,
                                        fit: BoxFit.cover,
                                        key: const Key('product_image'),
                                      ),
                              ),
                            const SizedBox(height: 16),

                            // Title
                            Text(
                              widget.title,
                              style: const TextStyle(
                                fontSize: 28,
                                fontWeight: FontWeight.bold,
                              ),
                              textAlign: TextAlign.center,
                            ),
                            const SizedBox(height: 8),

                            // Price
                            if (widget.discPrice != null) ...[
                              Text(
                                '£${widget.discPrice!.toStringAsFixed(2)}',
                                style: const TextStyle(
                                  fontSize: 24,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.red,
                                ),
                                textAlign: TextAlign.center,
                              ),
                              const SizedBox(height: 4),
                              Text(
                                '£${widget.price.toStringAsFixed(2)}',
                                style: const TextStyle(
                                  fontSize: 18,
                                  color: Colors.grey,
                                  decoration: TextDecoration.lineThrough,
                                ),
                                textAlign: TextAlign.center,
                              ),
                            ] else
                              Text(
                                '£${widget.price.toStringAsFixed(2)}',
                                style: const TextStyle(
                                  fontSize: 24,
                                  fontWeight: FontWeight.bold,
                                  color: Color(0xFF4d2963),
                                ),
                                textAlign: TextAlign.center,
                              ),
                            const SizedBox(height: 24),

                            // Description
                            const Text(
                              'Description',
                              style: TextStyle(
                                fontSize: 20,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                            const SizedBox(height: 8),
                            const Text(
                              'This is a placeholder description for the product.',
                              style: TextStyle(
                                fontSize: 16,
                                color: Colors.grey,
                              ),
                              textAlign: TextAlign.center,
                            ),

                            const SizedBox(height: 16),
                            // Quantity selector
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.center,
                              children: [
                                const Text(
                                  'Quantity',
                                  style: TextStyle(
                                      fontSize: 16,
                                      fontWeight: FontWeight.w600),
                                ),
                                const SizedBox(height: 8),
                                Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    IconButton(
                                      onPressed: _decrement,
                                      icon: const Icon(
                                          Icons.remove_circle_outline),
                                    ),
                                    // wider, editable field
                                    SizedBox(
                                      width: 100,
                                      child: TextField(
                                        controller: _qtyController,
                                        textAlign: TextAlign.center,
                                        keyboardType: TextInputType.number,
                                        inputFormatters: [
                                          FilteringTextInputFormatter.digitsOnly
                                        ],
                                        decoration: InputDecoration(
                                          contentPadding:
                                              const EdgeInsets.symmetric(
                                                  vertical: 8),
                                          border: OutlineInputBorder(
                                            borderRadius:
                                                BorderRadius.circular(6),
                                          ),
                                        ),
                                        onChanged: (value) {
                                          final v = int.tryParse(value);
                                          if (v == null || v < 1) {
                                            // don't update state for empty/invalid while typing
                                            return;
                                          }
                                          setState(() => _quantity = v);
                                        },
                                        onEditingComplete: () {
                                          var v = int.tryParse(
                                                  _qtyController.text) ??
                                              1;
                                          if (v < 1) v = 1;
                                          setState(() {
                                            _quantity = v;
                                            _qtyController.text = '$_quantity';
                                          });
                                          FocusScope.of(context).unfocus();
                                        },
                                      ),
                                    ),
                                    IconButton(
                                      onPressed: _increment,
                                      icon:
                                          const Icon(Icons.add_circle_outline),
                                    ),
                                  ],
                                ),
                              ],
                            ),

                            // color & size for clothing (narrow) - only when appropriate
                            if (widget.category.toLowerCase() ==
                                'clothing') ...[
                              const SizedBox(height: 12),
                              Column(
                                crossAxisAlignment: CrossAxisAlignment.center,
                                children: [
                                  const Text(
                                    'Color',
                                    style: TextStyle(
                                        fontSize: 16,
                                        fontWeight: FontWeight.w600),
                                  ),
                                  const SizedBox(height: 8),
                                  DropdownButton<String>(
                                    value: _selectedColor,
                                    items: _colors
                                        .map((c) => DropdownMenuItem(
                                              value: c,
                                              child: Text(c),
                                            ))
                                        .toList(),
                                    onChanged: (v) =>
                                        setState(() => _selectedColor = v),
                                  ),
                                  const SizedBox(height: 12),
                                  const Text(
                                    'Size',
                                    style: TextStyle(
                                        fontSize: 16,
                                        fontWeight: FontWeight.w600),
                                  ),
                                  const SizedBox(height: 8),
                                  DropdownButton<String>(
                                    value: _selectedSize,
                                    items: _sizes
                                        .map((s) => DropdownMenuItem(
                                              value: s,
                                              child: Text(s),
                                            ))
                                        .toList(),
                                    onChanged: (v) =>
                                        setState(() => _selectedSize = v),
                                  ),
                                ],
                              ),
                            ],

                            const SizedBox(height: 16),
                            SizedBox(
                              width: 220,
                              child: ElevatedButton(
                                onPressed: _addToCart,
                                child: const Text('Add to cart'),
                              ),
                            ),
                            const SizedBox(
                                height: 32), // Extra spacing before footer
                          ],
                        )

                      // ---------- WIDE SCREEN LAYOUT (Row) ----------
                      : Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            // IMAGE
                            if (widget.imageUrl.isNotEmpty)
                              SizedBox(
                                width: 500,
                                height: 400,
                                child: isNetwork
                                    ? Image.network(
                                        widget.imageUrl,
                                        fit: BoxFit.cover,
                                        key: const Key('product_image'),
                                      )
                                    : Image.asset(
                                        widget.imageUrl,
                                        fit: BoxFit.cover,
                                        key: const Key('product_image'),
                                      ),
                              ),
                            const SizedBox(width: 16),

                            // TEXT CONTENT (scroll-disabled inner)
                            Expanded(
                              child: SingleChildScrollView(
                                physics: const NeverScrollableScrollPhysics(),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      widget.title,
                                      style: const TextStyle(
                                        fontSize: 32,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                    const SizedBox(height: 16),
                                    if (widget.discPrice != null) ...[
                                      Text(
                                        '£${widget.discPrice!.toStringAsFixed(2)}',
                                        style: const TextStyle(
                                          fontSize: 26,
                                          fontWeight: FontWeight.bold,
                                          color: Colors.red,
                                        ),
                                      ),
                                      const SizedBox(height: 4),
                                      Text(
                                        '£${widget.price.toStringAsFixed(2)}',
                                        style: const TextStyle(
                                          fontSize: 20,
                                          color: Colors.grey,
                                          decoration:
                                              TextDecoration.lineThrough,
                                        ),
                                      ),
                                    ] else
                                      Text(
                                        '£${widget.price.toStringAsFixed(2)}',
                                        style: const TextStyle(
                                          fontSize: 26,
                                          fontWeight: FontWeight.bold,
                                          color: Color(0xFF4d2963),
                                        ),
                                      ),
                                    const SizedBox(height: 24),
                                    const Text(
                                      'Description',
                                      style: TextStyle(
                                        fontSize: 20,
                                        fontWeight: FontWeight.w600,
                                      ),
                                    ),
                                    const SizedBox(height: 8),
                                    const Text(
                                      'This is a placeholder description for the product.',
                                      style: TextStyle(
                                        fontSize: 16,
                                        color: Colors.grey,
                                      ),
                                    ),

                                    const SizedBox(height: 16),
                                    // Quantity selector (wide)
                                    Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        const Text(
                                          'Quantity',
                                          style: TextStyle(
                                              fontSize: 16,
                                              fontWeight: FontWeight.w600),
                                        ),
                                        const SizedBox(height: 8),
                                        Row(
                                          children: [
                                            IconButton(
                                              onPressed: _decrement,
                                              icon: const Icon(
                                                  Icons.remove_circle_outline),
                                            ),
                                            // wider, editable field
                                            SizedBox(
                                              width: 100,
                                              child: TextField(
                                                controller: _qtyController,
                                                textAlign: TextAlign.center,
                                                keyboardType:
                                                    TextInputType.number,
                                                inputFormatters: [
                                                  FilteringTextInputFormatter
                                                      .digitsOnly
                                                ],
                                                decoration: InputDecoration(
                                                  contentPadding:
                                                      const EdgeInsets
                                                          .symmetric(
                                                          vertical: 8),
                                                  border: OutlineInputBorder(
                                                    borderRadius:
                                                        BorderRadius.circular(
                                                            6),
                                                  ),
                                                ),
                                                onChanged: (value) {
                                                  final v = int.tryParse(value);
                                                  if (v == null || v < 1) {
                                                    // don't update state for empty/invalid while typing
                                                    return;
                                                  }
                                                  setState(() => _quantity = v);
                                                },
                                                onEditingComplete: () {
                                                  var v = int.tryParse(
                                                          _qtyController
                                                              .text) ??
                                                      1;
                                                  if (v < 1) v = 1;
                                                  setState(() {
                                                    _quantity = v;
                                                    _qtyController.text =
                                                        '$_quantity';
                                                  });
                                                  FocusScope.of(context)
                                                      .unfocus();
                                                },
                                              ),
                                            ),
                                            IconButton(
                                              onPressed: _increment,
                                              icon: const Icon(
                                                  Icons.add_circle_outline),
                                            ),
                                          ],
                                        ),
                                      ],
                                    ),

                                    // color & size for clothing (wide) - only when appropriate
                                    if (widget.category.toLowerCase() ==
                                        'clothing') ...[
                                      const SizedBox(height: 16),
                                      Row(
                                        children: [
                                          // Color
                                          Column(
                                            crossAxisAlignment:
                                                CrossAxisAlignment.start,
                                            children: [
                                              const Text(
                                                'Color',
                                                style: TextStyle(
                                                    fontSize: 16,
                                                    fontWeight:
                                                        FontWeight.w600),
                                              ),
                                              const SizedBox(height: 8),
                                              DropdownButton<String>(
                                                value: _selectedColor,
                                                items: _colors
                                                    .map(
                                                        (c) => DropdownMenuItem(
                                                              value: c,
                                                              child: Text(c),
                                                            ))
                                                    .toList(),
                                                onChanged: (v) => setState(
                                                    () => _selectedColor = v),
                                              ),
                                            ],
                                          ),
                                          const SizedBox(width: 32),
                                          // Size
                                          Column(
                                            crossAxisAlignment:
                                                CrossAxisAlignment.start,
                                            children: [
                                              const Text(
                                                'Size',
                                                style: TextStyle(
                                                    fontSize: 16,
                                                    fontWeight:
                                                        FontWeight.w600),
                                              ),
                                              const SizedBox(height: 8),
                                              DropdownButton<String>(
                                                value: _selectedSize,
                                                items: _sizes
                                                    .map(
                                                        (s) => DropdownMenuItem(
                                                              value: s,
                                                              child: Text(s),
                                                            ))
                                                    .toList(),
                                                onChanged: (v) => setState(
                                                    () => _selectedSize = v),
                                              ),
                                            ],
                                          ),
                                        ],
                                      ),
                                    ],

                                    const SizedBox(height: 16),
                                    SizedBox(
                                      width: 220,
                                      child: ElevatedButton(
                                        onPressed: _addToCart,
                                        child: const Text('Add to cart'),
                                      ),
                                    ),
                                    const SizedBox(
                                        height:
                                            32), // Extra spacing before footer
                                  ],
                                ),
                              ),
                            ),
                          ],
                        ),
                );
              },
            ),

            const SizedBox(height: 40), // Add space between content and footer

            // Footer
            const AppFooter(),
          ],
        ),
      ),
    );
  }
}
