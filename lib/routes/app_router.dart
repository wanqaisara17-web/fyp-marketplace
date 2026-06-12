import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../features/auth/screens/splash_screen.dart';
import '../features/auth/screens/login_screen.dart';
import '../features/auth/screens/register_screen.dart';
import '../features/auth/screens/otp_screen.dart';
import '../features/marketplace/screens/marketplace_shell.dart';
import '../features/marketplace/screens/product_detail_screen.dart';

class AppRouter {
  // Route names
  static const String splash = '/';
  static const String login = '/login';
  static const String register = '/register';
  static const String otp = '/otp';
  static const String home = '/home';
  static const String productDetail = '/product-detail';
  static const String productSearch = '/search';
  static const String profile = '/profile';
  static const String cart = '/cart';
  static const String orders = '/orders';

  static GoRouter router = GoRouter(
    initialLocation: login,
    routes: [
      GoRoute(
        path: splash,
        name: 'splash',
        builder: (context, state) => const SplashScreen(),
      ),

      GoRoute(
        path: login,
        name: 'login',
        builder: (context, state) => const LoginScreen(),
        pageBuilder: (context, state) =>
            const NoTransitionPage(child: LoginScreen()),
      ),

      GoRoute(
        path: register,
        name: 'register',
        builder: (context, state) => const RegisterScreen(),
        pageBuilder: (context, state) => CustomTransitionPage(
          transitionsBuilder: (context, animation, secondaryAnimation, child) {
            return SlideTransition(
              position: animation.drive(
                Tween(
                  begin: const Offset(1, 0),
                  end: Offset.zero,
                ).chain(CurveTween(curve: Curves.easeInOut)),
              ),
              child: child,
            );
          },
          child: const RegisterScreen(),
        ),
      ),

      GoRoute(
        path: otp,
        name: 'otp',
        builder: (context, state) =>
            OtpScreen(email: state.extra as String? ?? ''),
      ),

      // Main App Routes
      GoRoute(
        path: home,
        name: 'home',
        builder: (context, state) => const MarketplaceShell(),
        pageBuilder: (context, state) =>
            const NoTransitionPage(child: MarketplaceShell()),
      ),

      GoRoute(
        path: productDetail,
        name: 'productDetail',
        builder: (context, state) {
          final productId = state.uri.queryParameters['id'] ?? '';
          return ProductDetailScreen(productId: productId);
        },
      ),
    ],

    errorPageBuilder: (context, state) => MaterialPage(
      child: Scaffold(
        appBar: AppBar(title: const Text('Error')),
        body: Center(child: Text(state.error.toString())),
      ),
    ),
  );
}
