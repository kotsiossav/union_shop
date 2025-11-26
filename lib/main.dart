import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:union_shop/product_page.dart';
import 'package:union_shop/homepage.dart';
import 'package:union_shop/about_page.dart';
import 'package:union_shop/collections_page.dart'; // Added import for CollectionsPage

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

            // safe price conversion: handle int/double/String/null
            double parsePrice(Object? raw) {
              if (raw == null) return 0.0;
              if (raw is num) return raw.toDouble();
              final s = raw.toString();
              return double.tryParse(s) ?? 0.0;
            }

            final price = parsePrice(args?['price']);

            return ProductPage(
              imageUrl: imageUrl,
              title: title,
              price: price,
            );
          },
        ),
        // Example of a path param route if you prefer using an id:
        // GoRoute(
        //   path: '/product/:id',
        //   builder: (context, state) {
        //     final id = state.params['id']!;
        //     // use id to fetch product or pass extra data
        //     return ProductPage(...);
        //   },
        // ),
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
