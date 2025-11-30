import 'package:flutter/material.dart';
import 'package:union_shop/layout.dart';

class PrintShackAbout extends StatelessWidget {
  const PrintShackAbout({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Print Shack')),
      body: Column(
        children: const [
          AppHeader(),
          Expanded(
            child: SingleChildScrollView(
              padding: EdgeInsets.all(24.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'About Print Shack',
                    style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                  ),
                  SizedBox(height: 12),
                  Text(
                    'This is a placeholder about page for Print Shack. '
                    'Replace this text with your actual content.',
                    style: TextStyle(fontSize: 16, color: Colors.black87),
                  ),
                ],
              ),
            ),
          ),
          AppFooter(),
        ],
      ),
    );
  }
}
