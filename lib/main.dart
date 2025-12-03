import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:union_shop/models/cart_model.dart';
import 'package:union_shop/services/auth_service.dart';
import 'package:union_shop/routing.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:url_strategy/url_strategy.dart';
import 'package:provider/provider.dart';
import 'firebase_options.dart';

final authService = AuthService();

Future<void> main() async {
  // remove the hash (#) from web URLs
  setPathUrlStrategy();

  WidgetsFlutterBinding.ensureInitialized();

  GoRouter.optionURLReflectsImperativeAPIs = true; // ← IMPORTANT

  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  runApp(const UnionShopApp());
}

class UnionShopApp extends StatelessWidget {
  const UnionShopApp({super.key});

  @override
  Widget build(BuildContext context) {
    final router = createRouter();

    return MultiProvider(
      providers: [
        ChangeNotifierProvider<CartModel>.value(value: globalCart),
        Provider<AuthService>.value(value: authService),
      ],
      child: MaterialApp.router(
        title: 'Union Shop',
        debugShowCheckedModeBanner: false,
        theme: ThemeData(
          colorScheme: ColorScheme.fromSeed(seedColor: const Color(0xFF4d2963)),
        ),
        routerConfig: router,
      ),
    );
  }
}
