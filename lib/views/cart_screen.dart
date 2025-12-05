import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:union_shop/layout.dart';
import 'package:union_shop/models/cart_model.dart';
import 'package:union_shop/services/order_service.dart';

class CartScreen extends StatefulWidget {
  final CartModel cart;
  final OrderService? orderService;

  const CartScreen({super.key, required this.cart, this.orderService});

  @override
  State<CartScreen> createState() => _CartScreenState();
}

class _CartScreenState extends State<CartScreen> {
  late final OrderService _orderService;
  bool _isProcessingCheckout = false;

  @override
  void initState() {
    super.initState();
    _orderService = widget.orderService ?? OrderService();
    widget.cart.addListener(_onCartChanged);
  }

  @override
  void dispose() {
    widget.cart.removeListener(_onCartChanged);
    super.dispose();
  }

  void _onCartChanged() {
    setState(() {});
  }

  Future<void> _handleCheckout() async {
    if (widget.cart.items.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Your cart is empty')),
      );
      return;
    }

    setState(() {
      _isProcessingCheckout = true;
    });

    try {
      final orderId = await _orderService.createOrderFromCart(widget.cart);

      if (orderId != null) {
        // Clear cart after successful order
        widget.cart.clearCart();

        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Order placed successfully!'),
              backgroundColor: Colors.green,
            ),
          );
          // Navigate to order history
          context.go('/order_history');
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(e.toString()),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isProcessingCheckout = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final cartItems = widget.cart.items.values.toList();
    final isEmpty = cartItems.isEmpty;

    return Scaffold(
      body: SingleChildScrollView(
        child: Column(
          children: [
            // Header
            const AppHeader(),

            // Main content
            Container(
              constraints: const BoxConstraints(maxWidth: 1200),
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 40),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Title
                  const Text(
                    'Your Cart',
                    style: TextStyle(
                      fontSize: 32,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 16),

                  // Continue shopping link
                  InkWell(
                    onTap: () => context.go('/'),
                    child: const Text(
                      'CONTINUE SHOPPING',
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w500,
                        decoration: TextDecoration.underline,
                      ),
                    ),
                  ),
                  const SizedBox(height: 32),

                  // Cart content
                  if (isEmpty)
                    const Center(
                      child: Padding(
                        padding: EdgeInsets.all(40.0),
                        child: Text(
                          'Your cart is currently empty.',
                          style: TextStyle(fontSize: 16, color: Colors.grey),
                        ),
                      ),
                    )
                  else
                    Column(
                      children: [
                        // Cart items list
                        ...cartItems
                            .map((item) => _buildCartItem(context, item)),

                        const SizedBox(height: 32),

                        // Cart summary
                        _buildCartSummary(context),
                      ],
                    ),
                ],
              ),
            ),

            // Footer
            const AppFooter(),
          ],
        ),
      ),
    );
  }

  Widget _buildCartItem(BuildContext context, CartItem item) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 16),
      decoration: const BoxDecoration(
        border: Border(
          bottom: BorderSide(color: Colors.grey, width: 0.5),
        ),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Product image
          Container(
            width: 100,
            height: 100,
            decoration: BoxDecoration(
              border: Border.all(color: Colors.grey.shade300),
            ),
            child: Image.asset(
              item.imageUrl,
              fit: BoxFit.cover,
              errorBuilder: (context, error, stack) => const Icon(Icons.image),
            ),
          ),
          const SizedBox(width: 16),

          // Product details
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  item.title,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 8),
                if (item.color != null) ...[
                  Text(
                    'Color: ${item.color}',
                    style: const TextStyle(
                      fontSize: 14,
                      color: Colors.grey,
                    ),
                  ),
                  const SizedBox(height: 4),
                ],
                if (item.size != null) ...[
                  Text(
                    'Size: ${item.size}',
                    style: const TextStyle(
                      fontSize: 14,
                      color: Colors.grey,
                    ),
                  ),
                  const SizedBox(height: 4),
                ],
                Text(
                  '£${item.price.toStringAsFixed(2)} each',
                  style: const TextStyle(
                    fontSize: 14,
                    color: Colors.grey,
                  ),
                ),
                const SizedBox(height: 8),
                // Quantity controls
                Wrap(
                  spacing: 8,
                  crossAxisAlignment: WrapCrossAlignment.center,
                  children: [
                    const Text(
                      'Quantity: ',
                      style:
                          TextStyle(fontSize: 14, fontWeight: FontWeight.w500),
                    ),
                    Container(
                      decoration: BoxDecoration(
                        border: Border.all(color: Colors.grey.shade400),
                        borderRadius: BorderRadius.circular(4),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          // Decrease button
                          InkWell(
                            onTap: () {
                              widget.cart.removeProduct(item.uniqueKey);
                            },
                            child: Container(
                              padding: const EdgeInsets.all(8),
                              child: const Icon(Icons.remove, size: 16),
                            ),
                          ),
                          // Quantity display
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 12),
                            decoration: BoxDecoration(
                              border: Border(
                                left: BorderSide(color: Colors.grey.shade400),
                                right: BorderSide(color: Colors.grey.shade400),
                              ),
                            ),
                            child: Text(
                              '${item.quantity}',
                              style: const TextStyle(
                                fontSize: 14,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ),
                          // Increase button
                          InkWell(
                            onTap: () {
                              widget.cart.addProduct(
                                title: item.title,
                                imageUrl: item.imageUrl,
                                price: item.price,
                                category: item.category,
                                collection: item.collection,
                                color: item.color,
                                size: item.size,
                              );
                            },
                            child: Container(
                              padding: const EdgeInsets.all(8),
                              child: const Icon(Icons.add, size: 16),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),

          // Item total and remove
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                '£${item.totalPrice.toStringAsFixed(2)}',
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 8),
              TextButton(
                onPressed: () {
                  widget.cart.removeProductCompletely(item.uniqueKey);
                },
                child: const Text(
                  'Remove',
                  style: TextStyle(
                    decoration: TextDecoration.underline,
                    color: Colors.red,
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildCartSummary(BuildContext context) {
    final itemCount = widget.cart.totalQuantity;

    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Colors.grey.shade50,
        border: Border.all(color: Colors.grey.shade300),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Item count
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Items ($itemCount)',
                style: const TextStyle(fontSize: 14, color: Colors.grey),
              ),
              Text(
                '£${widget.cart.totalPrice.toStringAsFixed(2)}',
                style: const TextStyle(fontSize: 14, color: Colors.grey),
              ),
            ],
          ),
          const Divider(height: 24),

          // Subtotal
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'Subtotal',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              Text(
                '£${widget.cart.totalPrice.toStringAsFixed(2)}',
                style:
                    const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
            ],
          ),
          const SizedBox(height: 12),

          const Text(
            'Taxes and shipping calculated at checkout',
            style: TextStyle(
              fontSize: 12,
              color: Colors.grey,
              fontStyle: FontStyle.italic,
            ),
          ),
          const SizedBox(height: 24),

          // Checkout button
          SizedBox(
            height: 50,
            child: ElevatedButton(
              onPressed: _isProcessingCheckout ? null : _handleCheckout,
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF4d2963),
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(4),
                ),
              ),
              child: _isProcessingCheckout
                  ? const SizedBox(
                      height: 20,
                      width: 20,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        color: Colors.white,
                      ),
                    )
                  : const Text(
                      'CHECK OUT',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
            ),
          ),
        ],
      ),
    );
  }
}
