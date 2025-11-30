import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:union_shop/views/product_page.dart';
import 'package:union_shop/views/homepage.dart';
import 'package:union_shop/views/about_page.dart';
import 'package:union_shop/views/print_shack/print-shack_about.dart';
import 'package:union_shop/views/print_shack/personalisation.dart';
import 'package:union_shop/views/collections_page.dart';
import 'package:union_shop/views/collection_page.dart';
import 'package:union_shop/views/sign_in.dart';
import 'package:union_shop/views/cart_screen.dart';
import 'package:union_shop/views/search_page.dart';
import 'package:union_shop/models/cart_model.dart';

import 'package:firebase_core/firebase_core.dart';
import 'package:url_strategy/url_strategy.dart';
import 'firebase_options.dart';

// Global cart instance shared across the app
final globalCart = CartModel();

Future<void> main() async {
  // remove the hash (#) from web URLs
  setPathUrlStrategy();

  WidgetsFlutterBinding.ensureInitialized();

  GoRouter.optionURLReflectsImperativeAPIs = true; // ← IMPORTANT

  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  runApp(const UnionShopApp());
}

class UnionShopApp extends StatelessWidget {
  const UnionShopApp({super.key});

  @override
  Widget build(BuildContext context) {
    final _router = GoRouter(
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
    );

    return MaterialApp.router(
      title: 'Union Shop',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: const Color(0xFF4d2963)),
      ),
      routerConfig: _router,
    );
  }
}
