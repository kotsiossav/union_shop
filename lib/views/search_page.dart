import 'package:flutter/material.dart';
import 'package:union_shop/layout.dart';

class SearchPage extends StatelessWidget {
  const SearchPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SingleChildScrollView(
        child: Column(
          children: [
            const AppHeader(),

            // Search content
            Padding(
              padding: const EdgeInsets.all(40.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Search',
                    style: TextStyle(
                      fontSize: 32,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 24),
                  TextField(
                    decoration: InputDecoration(
                      hintText: 'Search for products...',
                      prefixIcon: const Icon(Icons.search),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(4),
                      ),
                    ),
                  ),
                  const SizedBox(height: 40),
                  const Text(
                    'Search results will appear here',
                    style: TextStyle(color: Colors.grey),
                  ),
                ],
              ),
            ),

            const AppFooter(),
          ],
        ),
      ),
    );
  }
}
