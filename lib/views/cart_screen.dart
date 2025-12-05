import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:union_shop/layout.dart';
import 'package:union_shop/models/cart_model.dart';
import 'package:union_shop/services/order_service.dart';

// Shopping cart screen displaying cart items with quantity editing and checkout
// Allows users to view items, modify quantities, remove items, and place orders
class CartScreen extends StatefulWidget {
  final CartModel cart; // Cart state management
  final OrderService? orderService; // Optional order service for testing

  const CartScreen({super.key, required this.cart, this.orderService});

  @override
  State<CartScreen> createState() => _CartScreenState();
}

class _CartScreenState extends State<CartScreen> {
  late final OrderService _orderService;
  bool _isProcessingCheckout = false; // Prevent duplicate checkout requests

  @override
  void initState() {
    super.initState();
    // Initialize order service with provided instance or create new one
    _orderService = widget.orderService ?? OrderService();
    // Listen for cart changes to update UI
    widget.cart.addListener(_onCartChanged);
  }

  @override
  void dispose() {
    // Remove listener to prevent memory leaks
    widget.cart.removeListener(_onCartChanged);
    super.dispose();
  }

  // Rebuild UI when cart changes
  void _onCartChanged() {
    setState(() {});
  }

  // Process checkout: create order, clear cart, navigate to order history
  Future<void> _handleCheckout() async {
    // Validate cart is not empty
    if (widget.cart.items.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Your cart is empty')),
      );
      return;
    }

    // Show loading state
    setState(() {
      _isProcessingCheckout = true;
    });

    try {
      // Create order from cart items
      final orderId = await _orderService.createOrderFromCart(widget.cart);

      if (orderId != null) {
        // Clear cart after successful order
        widget.cart.clearCart();

        if (mounted) {
          // Show success message
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
      // Show error message if checkout fails
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(e.toString()),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      // Reset loading state
      if (mounted) {
        setState(() {
          _isProcessingCheckout = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    // Get cart items and check if empty
    final cartItems = widget.cart.items.values.toList();
    final isEmpty = cartItems.isEmpty;

    return Scaffold(
      body: SingleChildScrollView(
        child: Column(
          children: [
            const AppHeader(),

            // Main content with max width constraint for desktop
            Container(
              constraints: const BoxConstraints(maxWidth: 1200),
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 40),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Page title
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

                  // Show empty message or cart items
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
                        // Render each cart item
                        ...cartItems
                            .map((item) => _buildCartItem(context, item)),

                        const SizedBox(height: 32),

                        // Cart summary with checkout button
                        _buildCartSummary(context),
                      ],
                    ),
                ],
              ),
            ),

            const AppFooter(),
          ],
        ),
      ),
    );
  }

  // Build individual cart item row with image, details, quantity controls, and remove button
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
          // Product image (100x100)
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

          // Product details (title, color, size, price, quantity controls)
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Product title
                Text(
                  item.title,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 8),
                // Color option (only for clothing items)
                if (item.category == 'clothing' && item.color != null) ...[
                  Text(
                    'Color: ${item.color}',
                    style: const TextStyle(
                      fontSize: 14,
                      color: Colors.grey,
                    ),
                  ),
                  const SizedBox(height: 4),
                ],
                // Size option (only for clothing items)
                if (item.category == 'clothing' && item.size != null) ...[
                  Text(
                    'Size: ${item.size}',
                    style: const TextStyle(
                      fontSize: 14,
                      color: Colors.grey,
                    ),
                  ),
                  const SizedBox(height: 4),
                ],
                // Unit price
                Text(
                  '£${item.price.toStringAsFixed(2)} each',
                  style: const TextStyle(
                    fontSize: 14,
                    color: Colors.grey,
                  ),
                ),
                const SizedBox(height: 8),
                // Quantity controls with +/- buttons
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
                          // Decrease quantity button (removes item if quantity = 1)
                          InkWell(
                            onTap: () {
                              widget.cart.removeProduct(item.uniqueKey);
                            },
                            child: Container(
                              padding: const EdgeInsets.all(8),
                              child: const Icon(Icons.remove, size: 16),
                            ),
                          ),
                          // Current quantity display
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
                          // Increase quantity button
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

          // Item total price and remove button
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              // Total price for this item (quantity × unit price)
              Text(
                '£${item.totalPrice.toStringAsFixed(2)}',
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 8),
              // Remove item button (deletes completely regardless of quantity)
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

  // Build cart summary panel with item count, subtotal, and checkout button
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
          // Item count and total price
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

          // Tax and shipping notice
          const Text(
            'Taxes and shipping calculated at checkout',
            style: TextStyle(
              fontSize: 12,
              color: Colors.grey,
              fontStyle: FontStyle.italic,
            ),
          ),
          const SizedBox(height: 24),

          // Checkout button with loading state
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
