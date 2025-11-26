import 'package:flutter/material.dart';
import 'package:union_shop/layout.dart';

class CollectionsPage extends StatelessWidget {
  const CollectionsPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SingleChildScrollView(
        child: Column(
          children: [
            const AppHeader(),
            // Main content for collections (placeholder)
            Container(
              padding: const EdgeInsets.all(16),
              child: const Text('Collections Page Content Here'),
            ),
            const AppFooter(),
          ],
        ),
      ),
    );
  }
}
