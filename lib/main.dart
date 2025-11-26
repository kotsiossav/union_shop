import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:union_shop/product_page.dart';
import 'package:union_shop/homepage.dart';
import 'package:union_shop/about_page.dart';
import 'package:union_shop/collections_page.dart';

void main() {
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
        // Added route for /collections
        GoRoute(
          path: '/collections',
          builder: (context, state) => const CollectionsPage(),
        ),
        GoRoute(
          path: '/product',
          builder: (context, state) {
            final args = state.extra as Map<String, dynamic>?;
            final imageUrl = args?['imageUrl']?.toString() ?? '';
            final title = args?['title']?.toString() ?? '';
            double parsePrice(Object? raw) {
              if (raw == null) return 0.0;
              if (raw is num) return raw.toDouble();
              return double.tryParse(raw.toString()) ?? 0.0;
            }

            final price = parsePrice(args?['price']);

            return ProductPage(
              imageUrl: imageUrl,
              title: title,
              price: price,
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
