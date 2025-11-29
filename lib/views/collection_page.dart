import 'package:flutter/material.dart';
import 'package:union_shop/layout.dart'; // AppHeader, AppFooter

class CollectionPage extends StatelessWidget {
  final String slug;
  const CollectionPage({super.key, this.slug = ''});

  @override
  Widget build(BuildContext context) {
    final title =
        slug.isEmpty ? 'Collection' : slug.replaceAll('-', ' ').toUpperCase();

    return Scaffold(
      body: SingleChildScrollView(
        child: Column(
          children: [
            const AppHeader(),

            Padding(
              padding:
                  const EdgeInsets.symmetric(vertical: 24.0, horizontal: 16.0),
              child: Center(
                child: Text(
                  title,
                  style: const TextStyle(
                      fontSize: 28, fontWeight: FontWeight.bold),
                  textAlign: TextAlign.center,
                ),
              ),
            ),

            // placeholder for collection content
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0),
              child: Center(
                child: Text(
                  'Products for "$slug" will appear here.',
                  style: const TextStyle(color: Colors.grey),
                ),
              ),
            ),

            const SizedBox(height: 48),
            const AppFooter(),
          ],
        ),
      ),
    );
  }
}
