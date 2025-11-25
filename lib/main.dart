import 'package:flutter/material.dart';
import 'package:union_shop/product_page.dart';
import 'package:union_shop/homepage.dart';
import 'package:union_shop/about_page.dart';

void main() {
  runApp(const UnionShopApp());
}

class UnionShopApp extends StatelessWidget {
  const UnionShopApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Union Shop',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: const Color(0xFF4d2963)),
      ),
      initialRoute: '/',
      routes: {
        '/': (context) => const HomeScreen(),

        '/about': (context) => const AboutPage(),

        /// -------------- IMPORTANT: Add THIS route --------------
        '/product': (context) {
          final args = ModalRoute.of(context)!.settings.arguments
              as Map<String, dynamic>;

          return ProductPage(
            imageUrl: args['imageUrl'],
            title: args['title'],
            price: args['price'],
          );
        },
      },
    );
  }
}
