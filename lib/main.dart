import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'providers/shop_provider.dart';
import 'screens/cart_screen.dart';
import 'screens/main_shell.dart';
import 'screens/wishlist_screen.dart';
import 'theme.dart';

void main() {
  runApp(
    ChangeNotifierProvider(
      create: (_) => ShopProvider(),
      child: const ThreadlyApp(),
    ),
  );
}

class ThreadlyApp extends StatelessWidget {
  const ThreadlyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Threadly',
      debugShowCheckedModeBanner: false,
      theme: buildTheme(),
      home: const MainShell(),
      routes: {
        '/wishlist': (_) => const WishlistScreen(),
        '/bag': (_) => const CartScreen(),
      },
    );
  }
}
