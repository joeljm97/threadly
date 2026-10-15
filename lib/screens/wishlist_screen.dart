import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../data/mock_data.dart';
import '../models/product.dart';
import '../providers/shop_provider.dart';
import '../theme.dart';
import '../widgets/product_card.dart';

class WishlistScreen extends StatelessWidget {
  /// true when shown as a bottom-nav tab (no back button).
  final bool embedded;
  const WishlistScreen({super.key, this.embedded = false});

  @override
  Widget build(BuildContext context) {
    final shop = context.watch<ShopProvider>();
    final items = allProducts.where((p) => shop.wishlistIds.contains(p.id)).toList();

    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: !embedded,
        title: Text.rich(TextSpan(children: [
          const TextSpan(text: 'WISHLIST  ', style: TextStyle(fontWeight: FontWeight.w800, fontSize: 16)),
          TextSpan(text: '${items.length} items', style: const TextStyle(color: AppColors.grey, fontSize: 13)),
        ])),
      ),
      body: items.isEmpty
          ? const _EmptyWishlist()
          : GridView.builder(
              padding: const EdgeInsets.all(8),
              itemCount: items.length,
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2,
                childAspectRatio: 0.52,
                crossAxisSpacing: 8,
                mainAxisSpacing: 8,
              ),
              itemBuilder: (_, i) => _WishCard(items[i]),
            ),
    );
  }
}

class _WishCard extends StatelessWidget {
  final Product product;
  const _WishCard(this.product);

  void _moveToBag(BuildContext context) {
    final shop = context.read<ShopProvider>();
    showModalBottomSheet(
      context: context,
      builder: (ctx) => SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(mainAxisSize: MainAxisSize.min, crossAxisAlignment: CrossAxisAlignment.start, children: [
            const Text('Select size', style: TextStyle(fontWeight: FontWeight.w800, fontSize: 16)),
            const SizedBox(height: 14),
            Wrap(
              spacing: 10,
              runSpacing: 10,
              children: product.sizes
                  .map((s) => OutlinedButton(
                        style: OutlinedButton.styleFrom(
                          shape: const StadiumBorder(),
                          padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 12),
                        ),
                        onPressed: () {
                          shop.addToCart(product, s);
                          shop.toggleWishlist(product);
                          Navigator.pop(ctx);
                          ScaffoldMessenger.of(context)
                              .showSnackBar(const SnackBar(content: Text('Moved to bag')));
                        },
                        child: Text(s),
                      ))
                  .toList(),
            ),
          ]),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final shop = context.read<ShopProvider>();
    return Container(
      decoration: BoxDecoration(border: Border.all(color: const Color(0xFFEAEAEC))),
      child: Column(children: [
        Expanded(
          child: Stack(children: [
            ProductCard(product),
            Positioned(
              top: 4,
              right: 4,
              child: InkWell(
                onTap: () => shop.toggleWishlist(product),
                child: const CircleAvatar(
                  radius: 15,
                  backgroundColor: Colors.white,
                  child: Icon(Icons.close, size: 16, color: AppColors.dark),
                ),
              ),
            ),
          ]),
        ),
        const Divider(height: 1),
        SizedBox(
          height: 42,
          width: double.infinity,
          child: TextButton(
            onPressed: () => _moveToBag(context),
            child: const Text('MOVE TO BAG',
                style: TextStyle(color: AppColors.primary, fontWeight: FontWeight.w800)),
          ),
        ),
      ]),
    );
  }
}

class _EmptyWishlist extends StatelessWidget {
  const _EmptyWishlist();

  @override
  Widget build(BuildContext context) => Center(
        child: Padding(
          padding: const EdgeInsets.all(32),
          child: Column(mainAxisSize: MainAxisSize.min, children: [
            Icon(Icons.favorite_border, size: 72, color: AppColors.primary.withValues(alpha: 0.5)),
            const SizedBox(height: 16),
            const Text('YOUR WISHLIST IS EMPTY', style: TextStyle(fontWeight: FontWeight.w800, fontSize: 16)),
            const SizedBox(height: 8),
            const Text('Add items that you like to your wishlist. Review them anytime and easily move them to the bag.',
                textAlign: TextAlign.center, style: TextStyle(color: AppColors.grey)),
          ]),
        ),
      );
}
