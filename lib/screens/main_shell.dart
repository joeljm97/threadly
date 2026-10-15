import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/shop_provider.dart';
import '../theme.dart';
import 'cart_screen.dart';
import 'categories_screen.dart';
import 'home_screen.dart';
import 'profile_screen.dart';
import 'wishlist_screen.dart';

class MainShell extends StatefulWidget {
  const MainShell({super.key});

  @override
  State<MainShell> createState() => _MainShellState();
}

class _MainShellState extends State<MainShell> {
  int _index = 0;

  @override
  Widget build(BuildContext context) {
    final shop = context.watch<ShopProvider>();
    const pages = [
      HomeScreen(),
      CategoriesScreen(),
      WishlistScreen(embedded: true),
      CartScreen(embedded: true),
      ProfileScreen(),
    ];
    return Scaffold(
      body: IndexedStack(index: _index, children: pages),
      bottomNavigationBar: NavigationBar(
        selectedIndex: _index,
        onDestinationSelected: (i) => setState(() => _index = i),
        backgroundColor: Colors.white,
        indicatorColor: AppColors.primary.withValues(alpha: 0.12),
        height: 64,
        labelBehavior: NavigationDestinationLabelBehavior.alwaysShow,
        destinations: [
          const NavigationDestination(
              icon: Icon(Icons.home_outlined), selectedIcon: Icon(Icons.home), label: 'Home'),
          const NavigationDestination(
              icon: Icon(Icons.grid_view_outlined),
              selectedIcon: Icon(Icons.grid_view_rounded),
              label: 'Categories'),
          NavigationDestination(
            icon: Badge(
                isLabelVisible: shop.wishlistIds.isNotEmpty,
                label: Text('${shop.wishlistIds.length}'),
                child: const Icon(Icons.favorite_border)),
            selectedIcon: const Icon(Icons.favorite),
            label: 'Wishlist',
          ),
          NavigationDestination(
            icon: Badge(
                isLabelVisible: shop.cartCount > 0,
                label: Text('${shop.cartCount}'),
                child: const Icon(Icons.shopping_bag_outlined)),
            selectedIcon: const Icon(Icons.shopping_bag),
            label: 'Bag',
          ),
          const NavigationDestination(
              icon: Icon(Icons.person_outline), selectedIcon: Icon(Icons.person), label: 'Profile'),
        ],
      ),
    );
  }
}
