import 'package:flutter/material.dart';
import 'package:union_shop/layout.dart';

class PrintShackAbout extends StatelessWidget {
  const PrintShackAbout({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Print Shack')),
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
                    'Make It Yours at The Union Print Shack',
                    style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                  ),
                  SizedBox(height: 12),
                  Text(
                    'Want to add a personal touch? We\'ve got you covered with heat-pressed customisation on all our clothing. Swing by the shop - our team\'s always happy to help you pick the right gear and answer any questions.',
                    style: TextStyle(fontSize: 16, color: Colors.black87),
                  ),
                  SizedBox(height: 16),
                  Text(
                    'Uni Gear or Your Gear - We\'ll Personalise It',
                    style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                  ),
                  SizedBox(height: 8),
                  Text(
                    'Whether you\'re repping your university or putting your own spin on a hoodie you already own, we\'ve got you covered. We can personalise official uni-branded clothing and your own items - just bring them in and let\'s get creative!',
                    style: TextStyle(fontSize: 16, color: Colors.black87),
                  ),
                  SizedBox(height: 16),
                  Text(
                    'Simple Pricing, No Surprises',
                    style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                  ),
                  SizedBox(height: 8),
                  Text(
                    'Customising your gear won\'t break the bank - just £3 for one line of text or a small chest logo, and £5 for two lines or a large back logo. Turnaround time is up to three working days, and we\'ll let you know as soon as it\'s ready to collect.',
                    style: TextStyle(fontSize: 16, color: Colors.black87),
                  ),
                  SizedBox(height: 16),
                  Text(
                    'Personalisation Terms & Conditions',
                    style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                  ),
                  SizedBox(height: 8),
                  Text(
                    'We will print your clothing exactly as you have provided it to us, whether online or in person. We are not responsible for any spelling errors. Please ensure your chosen text is clearly displayed in either capitals or lowercase. Refunds are not provided for any personalised items.',
                    style: TextStyle(fontSize: 16, color: Colors.black87),
                  ),
                  SizedBox(height: 16),
                  Text(
                    'Ready to Make It Yours?',
                    style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                  ),
                  SizedBox(height: 8),
                  Text(
                    'Pop in or get in touch today - let\'s create something uniquely you with our personalisation service - The Union Print Shack!',
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
