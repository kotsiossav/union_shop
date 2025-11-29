import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:union_shop/views/product_page.dart';
import 'package:union_shop/views/homepage.dart';
import 'package:union_shop/views/about_page.dart';
import 'package:union_shop/views/collections_page.dart';
import 'package:union_shop/views/collection_page.dart';
import 'package:union_shop/views/sign_in.dart';
import 'package:union_shop/views/sale_page.dart';
import 'package:firebase_core/firebase_core.dart';
import 'firebase_options.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

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
