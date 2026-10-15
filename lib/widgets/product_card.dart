import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/product.dart';
import '../providers/shop_provider.dart';
import '../screens/product_detail_screen.dart';
import '../theme.dart';

class NetImage extends StatelessWidget {
  final String url;
  final BoxFit fit;
  const NetImage(this.url, {super.key, this.fit = BoxFit.cover});

  @override
  Widget build(BuildContext context) => CachedNetworkImage(
        imageUrl: url,
        fit: fit,
        width: double.infinity,
        height: double.infinity,
        placeholder: (_, __) => Container(color: AppColors.light),
        errorWidget: (_, __, ___) => Container(
          color: AppColors.light,
          child: const Icon(Icons.image_not_supported_outlined, color: AppColors.grey),
        ),
      );
}

class PriceRow extends StatelessWidget {
  final Product product;
  final double size;
  const PriceRow(this.product, {super.key, this.size = 13});

  @override
  Widget build(BuildContext context) {
    return Wrap(
      crossAxisAlignment: WrapCrossAlignment.center,
      spacing: 6,
      children: [
        Text(rupees(product.price), style: TextStyle(fontWeight: FontWeight.w700, fontSize: size)),
        if (product.discountPercent > 0) ...[
          Text(rupees(product.mrp),
              style: TextStyle(
                  color: AppColors.grey, fontSize: size - 1, decoration: TextDecoration.lineThrough)),
          Text('(${product.discountPercent}% OFF)',
              style: TextStyle(color: AppColors.discount, fontSize: size - 1, fontWeight: FontWeight.w600)),
        ],
      ],
    );
  }
}

class RatingChip extends StatelessWidget {
  final Product product;
  const RatingChip(this.product, {super.key});

  @override
  Widget build(BuildContext context) => Container(
        padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
        decoration: BoxDecoration(
          color: Colors.white.withValues(alpha: 0.9),
          borderRadius: BorderRadius.circular(3),
        ),
        child: Row(mainAxisSize: MainAxisSize.min, children: [
          Text(product.rating.toStringAsFixed(1),
              style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w700)),
          const Icon(Icons.star, size: 11, color: AppColors.green),
          Text(' | ${_short(product.ratingCount)}', style: const TextStyle(fontSize: 11, color: AppColors.grey)),
        ]),
      );

  static String _short(int n) => n >= 1000 ? '${(n / 1000).toStringAsFixed(1)}k' : '$n';
}

class ProductCard extends StatelessWidget {
  final Product product;
  const ProductCard(this.product, {super.key});

  @override
  Widget build(BuildContext context) {
    final shop = context.watch<ShopProvider>();
    final wished = shop.isWishlisted(product);
    return GestureDetector(
      onTap: () => Navigator.push(
          context, MaterialPageRoute(builder: (_) => ProductDetailScreen(product: product))),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Expanded(
          child: Stack(children: [
            Hero(tag: 'img_${product.id}', child: NetImage(product.images.first)),
            Positioned(left: 6, bottom: 6, child: RatingChip(product)),
            Positioned(
              right: 4,
              top: 4,
              child: InkWell(
                onTap: () => shop.toggleWishlist(product),
                child: CircleAvatar(
                  radius: 15,
                  backgroundColor: Colors.white.withValues(alpha: 0.9),
                  child: Icon(wished ? Icons.favorite : Icons.favorite_border,
                      size: 18, color: wished ? AppColors.primary : AppColors.dark),
                ),
              ),
            ),
          ]),
        ),
        Padding(
          padding: const EdgeInsets.fromLTRB(8, 8, 8, 10),
          child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Text(product.brand,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 14)),
            Text(product.name,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(color: AppColors.grey, fontSize: 12)),
            const SizedBox(height: 4),
            PriceRow(product, size: 13),
          ]),
        ),
      ]),
    );
  }
}

class ProductGrid extends StatelessWidget {
  final List<Product> products;
  final bool shrinkWrap;
  const ProductGrid(this.products, {super.key, this.shrinkWrap = false});

  @override
  Widget build(BuildContext context) => GridView.builder(
        shrinkWrap: shrinkWrap,
        physics: shrinkWrap ? const NeverScrollableScrollPhysics() : null,
        padding: EdgeInsets.zero,
        itemCount: products.length,
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 2,
          childAspectRatio: 0.56,
          crossAxisSpacing: 2,
          mainAxisSpacing: 2,
        ),
        itemBuilder: (_, i) => ProductCard(products[i]),
      );
}

/// App-bar action icons with badges (wishlist + bag), reused on several screens.
class ShopActions extends StatelessWidget {
  const ShopActions({super.key});

  @override
  Widget build(BuildContext context) {
    final shop = context.watch<ShopProvider>();
    return Row(mainAxisSize: MainAxisSize.min, children: [
      IconButton(
        icon: Badge(
          isLabelVisible: shop.wishlistIds.isNotEmpty,
          label: Text('${shop.wishlistIds.length}'),
          child: const Icon(Icons.favorite_border),
        ),
        onPressed: () => Navigator.pushNamed(context, '/wishlist'),
      ),
      IconButton(
        icon: Badge(
          isLabelVisible: shop.cartCount > 0,
          label: Text('${shop.cartCount}'),
          child: const Icon(Icons.shopping_bag_outlined),
        ),
        onPressed: () => Navigator.pushNamed(context, '/bag'),
      ),
    ]);
  }
}
