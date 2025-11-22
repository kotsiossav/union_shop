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
      home: const HomeScreen(),
      initialRoute: '/',
      routes: {
        // We no longer use a static /product route because ProductPage needs an imageUrl
        '/about': (context) => const AboutPage(),
      },
    );
  }
}
