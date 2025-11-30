import 'package:flutter/material.dart';
import 'package:union_shop/layout.dart';

class PersonilationPage extends StatelessWidget {
  const PersonilationPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Print Shack — Personalisation')),
      body: const Column(
        children: [
          AppHeader(),
          Expanded(
            child: SingleChildScrollView(
              padding: EdgeInsets.all(24.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Personalisation',
                    style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                  ),
                  SizedBox(height: 12),
                  Text(
                    'Placeholder content for personalisation. Add form fields, pricing details or upload instructions here.',
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
