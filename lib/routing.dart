import 'package:go_router/go_router.dart';
import 'package:union_shop/views/product_page.dart';
import 'package:union_shop/views/homepage.dart';
import 'package:union_shop/views/about_page.dart';
import 'package:union_shop/views/print_shack/print-shack_about.dart';
import 'package:union_shop/views/print_shack/personalisation_page.dart';
import 'package:union_shop/views/collections_page.dart';
import 'package:union_shop/views/collection_page.dart';
import 'package:union_shop/views/sign_in_page.dart';
import 'package:union_shop/views/register_page.dart';
import 'package:union_shop/views/cart_page.dart';
import 'package:union_shop/views/search_page.dart';
import 'package:union_shop/views/order_history_page.dart';
import 'package:union_shop/models/cart_model.dart';

// Global shopping cart instance shared across all app routes and pages
// This persists cart state even when navigating between different pages
final globalCart = CartModel();

// Creates and configures the app's router with all navigation routes
// Uses GoRouter for declarative routing with URL path parameters and query strings
GoRouter createRouter() {
  return GoRouter(
    // Start users on the homepage when they first open the app
    initialLocation: '/',
    routes: [
      // Homepage route - displays featured products and collections
      GoRoute(
        path: '/',
        builder: (context, state) => const HomeScreen(),
      ),
      // About page route - company information and mission
      GoRoute(
        path: '/about',
        builder: (context, state) => const AboutPage(),
      ),
      // Print Shack information page - explains custom printing services
      GoRoute(
        path: '/print_shack_about',
        builder: (context, state) => const PrintShackAbout(),
      ),
      // Personalisation page - allows users to customize products with text/logos
      GoRoute(
        path: '/personalisation',
        builder: (context, state) => const PersonilationPage(),
      ),
      // Collections overview - grid of all product collections
      GoRoute(
        path: '/collections',
        builder: (context, state) => const CollectionsPage(),
      ),
      // Dynamic collection route - displays products filtered by collection
      // URL format: /collections/:slug (e.g., /collections/autumn-favourites)
      // The :slug parameter extracts the collection name from the URL
      GoRoute(
        path: '/collections/:slug',
        builder: (context, state) {
          final slug = state.pathParameters['slug'] ?? '';
          return CollectionPage(slug: slug);
        },
        routes: [
          // Nested product route within collection
          // URL format: /collections/:slug/products/:productSlug
          // Example: /collections/essential-range/products/blue-hoodie
          GoRoute(
            path: 'products/:productSlug',
            builder: (context, state) {
              // Extract navigation data passed via context.push()
              final args = state.extra as Map<String, dynamic>?;
              final slug = state.pathParameters['productSlug']!;
              // Convert URL slug back to readable title (blue-hoodie -> blue hoodie)
              final title = Uri.decodeComponent(slug).replaceAll('-', ' ');

              // Helper function to safely parse price from various formats
              // Handles both numeric types and string prices like "£29.99"
              double parsePrice(Object? raw) {
                if (raw is num) return raw.toDouble();
                if (raw is String) {
                  // Remove all non-numeric characters except decimal point
                  return double.tryParse(
                          raw.replaceAll(RegExp(r'[^0-9.]'), '')) ??
                      0.0;
                }
                return 0.0;
              }

              // Build the product page with extracted and parsed data
              return ProductPage(
                imageUrl: args?['imageUrl'] ?? '',
                title: title,
                price: parsePrice(args?['price']),
                // Parse discount price only if it exists
                discPrice: args?['discPrice'] != null
                    ? parsePrice(args!['discPrice'])
                    : null,
                category: args?['category'] ?? 'unknown',
                cart: globalCart,
              );
            },
          ),
        ],
      ),
      // Search page route - displays search results based on query parameter
      // URL format: /search?q=searchterm
      // Query parameter 'q' contains the user's search text
      GoRoute(
        path: '/search',
        builder: (context, state) {
          final query = state.uri.queryParameters['q'];
          return SearchPage(initialQuery: query);
        },
      ),

      // Shopping cart page - displays cart items with checkout functionality
      GoRoute(
        path: '/cart',
        builder: (context, state) => CartScreen(cart: globalCart),
      ),

      // User sign-in page - handles email/password authentication
      GoRoute(
        path: '/login_page',
        builder: (context, state) => const SignInPage(),
      ),

      // User registration page - creates new accounts
      GoRoute(
        path: '/register',
        builder: (context, state) => const RegisterPage(),
      ),

      // Order history page - displays user's past orders (requires authentication)
      GoRoute(
        path: '/order_history',
        builder: (context, state) => const OrderHistoryPage(),
      ),
      // Fallback product route at root level using slug
      // URL format: /:productSlug (e.g., /blue-hoodie)
      // This route MUST be last to avoid matching other specific routes
      // Used when products are accessed directly without collection context
      GoRoute(
        path: '/:productSlug',
        builder: (context, state) {
          // Extract navigation data passed via context.push()
          final args = state.extra as Map<String, dynamic>?;

          final slug = state.pathParameters['productSlug']!;
          // Decode URL-encoded slug and convert hyphens to spaces
          final title = Uri.decodeComponent(slug).replaceAll('-', ' ');

          // Helper function to convert various price formats to double
          double parsePrice(Object? raw) {
            if (raw is num) return raw.toDouble();
            if (raw is String) {
              // Strip currency symbols and convert to number
              return double.tryParse(raw.replaceAll(RegExp(r'[^0-9.]'), '')) ??
                  0.0;
            }
            return 0.0;
          }

          // Build product page with data from navigation parameters
          return ProductPage(
            imageUrl: args?['imageUrl'] ?? '',
            title: title,
            price: parsePrice(args?['price']),
            // Only parse discount price if it's provided
            discPrice: args?['discPrice'] != null
                ? parsePrice(args!['discPrice'])
                : null,
            category: args?['category'] ?? 'unknown',
            cart: globalCart,
          );
        },
      ),
    ],
  );
}
