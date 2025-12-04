import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:union_shop/models/cart_model.dart';
import 'package:union_shop/services/auth_service.dart';
import 'package:union_shop/routing.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:url_strategy/url_strategy.dart';
import 'package:provider/provider.dart';
import 'firebase_options.dart';

// Create a global instance of AuthService to be shared across the app
final authService = AuthService();

Future<void> main() async {
  // Configure web URLs to use clean paths without hash (#) symbols
  setPathUrlStrategy();

  // Initialize Flutter framework before Firebase setup
  WidgetsFlutterBinding.ensureInitialized();

  // Enable URL updates when using imperative navigation (context.go, context.push)
  GoRouter.optionURLReflectsImperativeAPIs = true;

  // Initialize Firebase with platform-specific configuration (Android, iOS, Web)
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  // Start the Flutter application
  runApp(const UnionShopApp());
}

// Root widget of the application - sets up providers and routing
class UnionShopApp extends StatelessWidget {
  const UnionShopApp({super.key});

  @override
  Widget build(BuildContext context) {
    // Create the router with all app routes configured
    final router = createRouter();

    // Wrap the app with MultiProvider to make CartModel and AuthService
    // available to all descendant widgets via Provider
    return MultiProvider(
      providers: [
        // CartModel provides shopping cart state management with real-time updates
        ChangeNotifierProvider<CartModel>.value(value: globalCart),
        // AuthService handles user authentication (sign in, register, sign out)
        Provider<AuthService>.value(value: authService),
      ],
      child: MaterialApp.router(
        title: 'Union Shop',
        // Hide the debug banner in top-right corner
        debugShowCheckedModeBanner: false,
        // Define the app's color scheme based on the university purple
        theme: ThemeData(
          colorScheme: ColorScheme.fromSeed(seedColor: const Color(0xFF4d2963)),
        ),
        // Use GoRouter for declarative routing with URL support
        routerConfig: router,
      ),
    );
  }
}
