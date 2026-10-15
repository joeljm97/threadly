import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/product.dart';
import '../providers/shop_provider.dart';
import '../theme.dart';
import '../widgets/product_card.dart';
import 'checkout_screen.dart';
import 'product_detail_screen.dart';

class CartScreen extends StatelessWidget {
  final bool embedded;
  const CartScreen({super.key, this.embedded = false});

  @override
  Widget build(BuildContext context) {
    final shop = context.watch<ShopProvider>();
    final items = shop.cartItems;

    return Scaffold(
      backgroundColor: items.isEmpty ? Colors.white : AppColors.light,
      appBar: AppBar(
        automaticallyImplyLeading: !embedded,
        title: const Text('SHOPPING BAG', style: TextStyle(fontWeight: FontWeight.w800, fontSize: 16)),
        actions: [
          IconButton(
            icon: const Icon(Icons.favorite_border),
            onPressed: () => Navigator.pushNamed(context, '/wishlist'),
          ),
        ],
      ),
      body: items.isEmpty
          ? const _EmptyBag()
          : ListView(
              children: [
                Container(
                  color: Colors.white,
                  padding: const EdgeInsets.all(14),
                  child: Row(children: [
                    const Icon(Icons.local_offer_outlined, size: 20),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Text(
                        shop.deliveryFee == 0
                            ? 'Yay! You get FREE delivery on this order'
                            : 'Add ${rupees(799 - shop.cartTotal)} more for FREE delivery',
                        style: const TextStyle(fontWeight: FontWeight.w600),
                      ),
                    ),
                  ]),
                ),
                const SizedBox(height: 8),
                ...items.map((e) => _CartTile(e)),
                const SizedBox(height: 8),
                PriceDetails(shop),
                const SizedBox(height: 16),
              ],
            ),
      bottomNavigationBar: items.isEmpty
          ? null
          : SafeArea(
              child: Container(
                color: Colors.white,
                padding: const EdgeInsets.all(12),
                child: Row(children: [
                  Expanded(
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(rupees(shop.payable),
                            style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 18)),
                        const Text('Total payable', style: TextStyle(color: AppColors.grey, fontSize: 12)),
                      ],
                    ),
                  ),
                  Expanded(
                    child: ElevatedButton(
                      onPressed: () => Navigator.push(
                          context, MaterialPageRoute(builder: (_) => const CheckoutScreen())),
                      child: const Text('PLACE ORDER'),
                    ),
                  ),
                ]),
              ),
            ),
    );
  }
}

class _CartTile extends StatelessWidget {
  final CartItem item;
  const _CartTile(this.item);

  @override
  Widget build(BuildContext context) {
    final shop = context.read<ShopProvider>();
    final p = item.product;
    return Container(
      color: Colors.white,
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.all(12),
      child: Column(children: [
        Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
          GestureDetector(
            onTap: () =>
                Navigator.push(context, MaterialPageRoute(builder: (_) => ProductDetailScreen(product: p))),
            child: SizedBox(width: 90, height: 120, child: NetImage(p.images.first, fit: BoxFit.contain)),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Text(p.brand, style: const TextStyle(fontWeight: FontWeight.w800)),
              Text(p.name, maxLines: 1, overflow: TextOverflow.ellipsis,
                  style: const TextStyle(color: AppColors.grey)),
              const SizedBox(height: 8),
              Row(children: [
                _Pill('Size: ${item.size}'),
                const SizedBox(width: 8),
                PopupMenuButton<int>(
                  initialValue: item.quantity,
                  onSelected: (q) => shop.setQuantity(item, q),
                  itemBuilder: (_) =>
                      List.generate(10, (i) => PopupMenuItem(value: i + 1, child: Text('${i + 1}'))),
                  child: _Pill('Qty: ${item.quantity}'),
                ),
              ]),
              const SizedBox(height: 8),
              Wrap(spacing: 6, crossAxisAlignment: WrapCrossAlignment.center, children: [
                Text(rupees(item.total), style: const TextStyle(fontWeight: FontWeight.w800)),
                if (p.discountPercent > 0) ...[
                  Text(rupees(item.mrpTotal),
                      style: const TextStyle(color: AppColors.grey, decoration: TextDecoration.lineThrough)),
                  Text('${p.discountPercent}% OFF',
                      style: const TextStyle(color: AppColors.discount, fontWeight: FontWeight.w600)),
                ],
              ]),
              const SizedBox(height: 6),
              const Row(children: [
                Icon(Icons.autorenew, size: 14),
                SizedBox(width: 4),
                Text('14 days return available', style: TextStyle(fontSize: 12)),
              ]),
            ]),
          ),
        ]),
        const Divider(height: 20),
        Row(children: [
          Expanded(
            child: TextButton(
              onPressed: () => shop.removeFromCart(item),
              child: const Text('REMOVE', style: TextStyle(color: AppColors.grey, fontWeight: FontWeight.w700)),
            ),
          ),
          const SizedBox(height: 20, child: VerticalDivider()),
          Expanded(
            child: TextButton(
              onPressed: () => shop.moveToWishlist(item),
              child: const Text('MOVE TO WISHLIST',
                  style: TextStyle(color: AppColors.primary, fontWeight: FontWeight.w700)),
            ),
          ),
        ]),
      ]),
    );
  }
}

class _Pill extends StatelessWidget {
  final String text;
  const _Pill(this.text);

  @override
  Widget build(BuildContext context) => Container(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
        color: AppColors.light,
        child: Row(mainAxisSize: MainAxisSize.min, children: [
          Text(text, style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 12)),
          const Icon(Icons.arrow_drop_down, size: 18),
        ]),
      );
}

class PriceDetails extends StatelessWidget {
  final ShopProvider shop;
  const PriceDetails(this.shop, {super.key});

  Widget _row(String l, String r, {Color? color, bool bold = false}) => Padding(
        padding: const EdgeInsets.symmetric(vertical: 5),
        child: Row(children: [
          Expanded(child: Text(l, style: TextStyle(fontWeight: bold ? FontWeight.w800 : FontWeight.normal))),
          Text(r, style: TextStyle(color: color, fontWeight: bold ? FontWeight.w800 : FontWeight.normal)),
        ]),
      );

  @override
  Widget build(BuildContext context) => Container(
        color: Colors.white,
        padding: const EdgeInsets.all(16),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Text('PRICE DETAILS (${shop.cartCount} Items)',
              style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 13)),
          const SizedBox(height: 10),
          _row('Total MRP', rupees(shop.cartMrp)),
          _row('Discount on MRP', '-${rupees(shop.cartDiscount)}', color: AppColors.green),
          _row('Platform Fee', rupees(shop.platformFee)),
          _row('Delivery Fee', shop.deliveryFee == 0 ? 'FREE' : rupees(shop.deliveryFee),
              color: shop.deliveryFee == 0 ? AppColors.green : null),
          const Divider(),
          _row('Total Amount', rupees(shop.payable), bold: true),
        ]),
      );
}

class _EmptyBag extends StatelessWidget {
  const _EmptyBag();

  @override
  Widget build(BuildContext context) => Center(
        child: Padding(
          padding: const EdgeInsets.all(32),
          child: Column(mainAxisSize: MainAxisSize.min, children: [
            Icon(Icons.shopping_bag_outlined, size: 72, color: AppColors.primary.withValues(alpha: 0.5)),
            const SizedBox(height: 16),
            const Text('Hey, it feels so light!', style: TextStyle(fontWeight: FontWeight.w800, fontSize: 18)),
            const SizedBox(height: 8),
            const Text("There is nothing in your bag. Let's add some items.",
                textAlign: TextAlign.center, style: TextStyle(color: AppColors.grey)),
            const SizedBox(height: 20),
            OutlinedButton(
              style: OutlinedButton.styleFrom(
                  foregroundColor: AppColors.primary,
                  side: const BorderSide(color: AppColors.primary),
                  padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14)),
              onPressed: () => Navigator.pushNamed(context, '/wishlist'),
              child: const Text('ADD ITEMS FROM WISHLIST'),
            ),
          ]),
        ),
      );
}
