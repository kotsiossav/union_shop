import 'package:flutter/material.dart';
import 'package:union_shop/layout.dart';
import 'package:union_shop/app_styles.dart';

class AboutPage extends StatelessWidget {
  const AboutPage({super.key});

  void navigateToHome(BuildContext context) {
    Navigator.pushNamedAndRemoveUntil(context, '/', (route) => false);
  }

  void placeholderCallbackForButtons() {}

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SingleChildScrollView(
        child: Column(
          children: [
            // Header from layout.dart
            AppHeader(
              onHome: () => navigateToHome(context),
              onShop: placeholderCallbackForButtons,
              onSale: placeholderCallbackForButtons,
              onPrintShack: placeholderCallbackForButtons,
              onAbout: placeholderCallbackForButtons,
            ),

            // About content
            Padding(
              padding: const EdgeInsets.all(40.0),
              child: Center(
                child: ConstrainedBox(
                  constraints: const BoxConstraints(maxWidth: 800),
                  child: const Column(
                    crossAxisAlignment: CrossAxisAlignment.center, // was start
                    children: [
                      // Big "About Us" heading
                      Text(
                        'About Us',
                        style: TextStyle(
                          fontSize: 48, // big title size
                          fontWeight: FontWeight.bold,
                        ),
                        textAlign: TextAlign.center, // center heading text
                      ),
                      SizedBox(height: 24),

                      // Body text
                      Text(
                        'Welcome to the Union Shop!\n\n'
                        'We’re dedicated to giving you the very best University branded products, '
                        'with a range of clothing and merchandise available to shop all year round! '
                        'We even offer an exclusive personalisation service!\n\n'
                        'All online purchases are available for delivery or instore collection!\n\n'
                        'We hope you enjoy our products as much as we enjoy offering them to you. '
                        'If you have any questions or comments, please don’t hesitate to contact us '
                        'at hello@upsu.net.\n\n'
                        'Happy shopping!\n\n'
                        'The Union Shop & Reception Team​​​​​​​​​',
                        style: TextStyle(
                          fontSize: 18, // subtitle size
                          fontWeight: FontWeight.bold,
                          color: Colors.grey, // <-- make this text grey
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),

            // Footer from layout.dart
            const AppFooter(),
          ],
        ),
      ),
    );
  }
}
