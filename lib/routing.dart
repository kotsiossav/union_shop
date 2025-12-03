import 'package:go_router/go_router.dart';
import 'package:union_shop/views/product_page.dart';
import 'package:union_shop/views/homepage.dart';
import 'package:union_shop/views/about_page.dart';
import 'package:union_shop/views/print_shack/print-shack_about.dart';
import 'package:union_shop/views/print_shack/personalisation.dart';
import 'package:union_shop/views/collections_page.dart';
import 'package:union_shop/views/collection_page.dart';
import 'package:union_shop/views/sign_in_page.dart';
import 'package:union_shop/views/register_page.dart';
import 'package:union_shop/views/cart_screen.dart';
import 'package:union_shop/views/search_page.dart';
import 'package:union_shop/views/order_history_page.dart';
import 'package:union_shop/models/cart_model.dart';

// Global cart instance shared across the app
final globalCart = CartModel();

GoRouter createRouter() {
  return GoRouter(
    initialLocation: '/',
    routes: [
      GoRoute(
        path: '/',
        builder: (context, state) => const HomeScreen(),
      ),
      GoRoute(
        path: '/about',
        builder: (context, state) => const AboutPage(),
      ),
      // Print Shack about page
      GoRoute(
        path: '/print_shack_about',
        builder: (context, state) => const PrintShackAbout(),
      ),
      // personalisation page
      GoRoute(
        path: '/personalisation',
        builder: (context, state) => const PersonilationPage(),
      ),
      // collections index
      GoRoute(
        path: '/collections',
        builder: (context, state) => const CollectionsPage(),
      ),
      // dynamic collection route (use slug in the URL, e.g. /collections/autumn-favourites)
      GoRoute(
        path: '/collections/:slug',
        builder: (context, state) {
          final slug = state.pathParameters['slug'] ?? '';
          return CollectionPage(slug: slug);
        },
        routes: [
          // nested product route: /collections/:slug/products/:productSlug
          GoRoute(
            path: 'products/:productSlug',
            builder: (context, state) {
              final args = state.extra as Map<String, dynamic>?;
              final slug = state.pathParameters['productSlug']!;
              final title = Uri.decodeComponent(slug).replaceAll('-', ' ');

              double parsePrice(Object? raw) {
                if (raw is num) return raw.toDouble();
                if (raw is String) {
                  return double.tryParse(
                          raw.replaceAll(RegExp(r'[^0-9.]'), '')) ??
                      0.0;
                }
                return 0.0;
              }

              return ProductPage(
                imageUrl: args?['imageUrl'] ?? '',
                title: title,
                price: parsePrice(args?['price']),
                category: args?['category'] ?? 'unknown',
                cart: globalCart,
              );
            },
          ),
        ],
      ),
      // sale page

      // search page
      GoRoute(
        path: '/search',
        builder: (context, state) {
          final query = state.uri.queryParameters['q'];
          return SearchPage(initialQuery: query);
        },
      ),

      // cart page
      GoRoute(
        path: '/cart',
        builder: (context, state) => CartScreen(cart: globalCart),
      ),

      // login page
      GoRoute(
        path: '/login_page',
        builder: (context, state) => const SignInPage(),
      ),

      // register page
      GoRoute(
        path: '/register',
        builder: (context, state) => const RegisterPage(),
      ),

      // order history page
      GoRoute(
        path: '/order_history',
        builder: (context, state) => const OrderHistoryPage(),
      ),
      // product routes at root using slug (keep this last so other routes match first)
      GoRoute(
        path: '/:productSlug',
        builder: (context, state) {
          final args = state.extra as Map<String, dynamic>?;

          final slug = state.pathParameters['productSlug']!;
          final title = Uri.decodeComponent(slug).replaceAll('-', ' ');

          double parsePrice(Object? raw) {
            if (raw is num) return raw.toDouble();
            if (raw is String) {
              return double.tryParse(raw.replaceAll(RegExp(r'[^0-9.]'), '')) ??
                  0.0;
            }
            return 0.0;
          }

          return ProductPage(
            imageUrl: args?['imageUrl'] ?? '',
            title: title,
            price: parsePrice(args?['price']),
            category: args?['category'] ?? 'unknown',
            cart: globalCart,
          );
        },
      ),
    ],
  );
}
