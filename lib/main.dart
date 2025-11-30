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
import 'package:union_shop/views/sale_page.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:url_strategy/url_strategy.dart';
import 'firebase_options.dart';

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
          path: '/collection',
          builder: (context, state) => const CollectionsPage(),
        ),
        // dynamic collection route (use slug in the URL, e.g. /collection/autumn-favourites)
        GoRoute(
          path: '/collection/:slug',
          builder: (context, state) {
            final slug = state.pathParameters['slug'] ?? '';
            return CollectionPage(slug: slug);
          },
        ),
        // sale page
        GoRoute(
          path: '/sale',
          builder: (context, state) => const SalePage(),
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
