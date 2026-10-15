import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/product.dart';
import '../providers/shop_provider.dart';
import '../theme.dart';
import '../widgets/product_card.dart';

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final shop = context.watch<ShopProvider>();
    void soon() => ScaffoldMessenger.of(context)
        .showSnackBar(const SnackBar(content: Text('Coming soon'), behavior: SnackBarBehavior.floating));

    return Scaffold(
      backgroundColor: AppColors.light,
      appBar: AppBar(title: const Text('Profile', style: TextStyle(fontWeight: FontWeight.w700))),
      body: ListView(
        children: [
          Container(
            padding: const EdgeInsets.all(20),
            decoration: const BoxDecoration(
              gradient: LinearGradient(colors: [Color(0xFFFFE3E8), Color(0xFFFFF5F0)]),
            ),
            child: Row(children: [
              const CircleAvatar(
                radius: 34,
                backgroundColor: Colors.white,
                child: Icon(Icons.person, size: 40, color: AppColors.primary),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                  const Text('Guest User', style: TextStyle(fontWeight: FontWeight.w800, fontSize: 18)),
                  const SizedBox(height: 6),
                  SizedBox(
                    height: 34,
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(padding: const EdgeInsets.symmetric(horizontal: 16)),
                      onPressed: soon,
                      child: const Text('LOG IN / SIGN UP'),
                    ),
                  ),
                ]),
              ),
            ]),
          ),
          const SizedBox(height: 8),
          _Tile(Icons.inventory_2_outlined, 'Orders', 'Check your order status',
              trailing: shop.orders.isEmpty ? null : '${shop.orders.length}',
              onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const OrdersScreen()))),
          _Tile(Icons.favorite_border, 'Wishlist', 'Your most loved styles',
              onTap: () => Navigator.pushNamed(context, '/wishlist')),
          _Tile(Icons.location_on_outlined, 'Saved Addresses', 'Save addresses for a hassle-free checkout',
              onTap: soon),
          _Tile(Icons.credit_card, 'Saved Cards & UPI', 'Save payment methods for faster checkout', onTap: soon),
          _Tile(Icons.local_offer_outlined, 'Coupons', 'Manage coupons for additional savings', onTap: soon),
          _Tile(Icons.headset_mic_outlined, 'Help Center', 'Help regarding your recent purchases', onTap: soon),
          const SizedBox(height: 8),
          Container(
            color: Colors.white,
            padding: const EdgeInsets.all(16),
            child: const Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Text('FAQs', style: TextStyle(fontWeight: FontWeight.w600)),
              SizedBox(height: 12),
              Text('ABOUT US', style: TextStyle(fontWeight: FontWeight.w600)),
              SizedBox(height: 12),
              Text('TERMS OF USE', style: TextStyle(fontWeight: FontWeight.w600)),
              SizedBox(height: 12),
              Text('PRIVACY POLICY', style: TextStyle(fontWeight: FontWeight.w600)),
              SizedBox(height: 20),
              Text('APP VERSION 1.0.0', style: TextStyle(color: AppColors.grey, fontSize: 12)),
            ]),
          ),
        ],
      ),
    );
  }
}

class _Tile extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;
  final String? trailing;
  final VoidCallback onTap;
  const _Tile(this.icon, this.title, this.subtitle, {required this.onTap, this.trailing});

  @override
  Widget build(BuildContext context) => Container(
        color: Colors.white,
        child: Column(children: [
          ListTile(
            leading: Icon(icon, color: AppColors.dark),
            title: Text(title, style: const TextStyle(fontWeight: FontWeight.w700)),
            subtitle: Text(subtitle, style: const TextStyle(fontSize: 12)),
            trailing: Row(mainAxisSize: MainAxisSize.min, children: [
              if (trailing != null) Badge(label: Text(trailing!), backgroundColor: AppColors.primary),
              const Icon(Icons.chevron_right, color: AppColors.grey),
            ]),
            onTap: onTap,
          ),
          const Divider(height: 1, indent: 56),
        ]),
      );
}

class OrdersScreen extends StatelessWidget {
  const OrdersScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final orders = context.watch<ShopProvider>().orders;
    return Scaffold(
      backgroundColor: AppColors.light,
      appBar: AppBar(title: const Text('ORDERS', style: TextStyle(fontWeight: FontWeight.w800, fontSize: 16))),
      body: orders.isEmpty
          ? const Center(child: Text('No orders yet', style: TextStyle(color: AppColors.grey)))
          : ListView.builder(
              padding: const EdgeInsets.symmetric(vertical: 8),
              itemCount: orders.length,
              itemBuilder: (_, i) => _OrderCard(orders[i]),
            ),
    );
  }
}

class _OrderCard extends StatelessWidget {
  final Order order;
  const _OrderCard(this.order);

  @override
  Widget build(BuildContext context) {
    final d = order.placedAt;
    return Container(
      color: Colors.white,
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.all(14),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Row(children: [
          const CircleAvatar(
              radius: 14, backgroundColor: AppColors.green, child: Icon(Icons.inventory_2, size: 16, color: Colors.white)),
          const SizedBox(width: 10),
          Expanded(
            child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              const Text('Confirmed', style: TextStyle(fontWeight: FontWeight.w800, color: AppColors.green)),
              Text('On ${d.day}/${d.month}/${d.year} • #${order.id}',
                  style: const TextStyle(fontSize: 12, color: AppColors.grey)),
            ]),
          ),
          Text(rupees(order.amount), style: const TextStyle(fontWeight: FontWeight.w800)),
        ]),
        const SizedBox(height: 12),
        ...order.items.map((e) => Padding(
              padding: const EdgeInsets.only(bottom: 8),
              child: Row(children: [
                SizedBox(width: 50, height: 66, child: NetImage(e.product.images.first)),
                const SizedBox(width: 10),
                Expanded(
                  child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                    Text(e.product.brand, style: const TextStyle(fontWeight: FontWeight.w700)),
                    Text(e.product.name, maxLines: 1, overflow: TextOverflow.ellipsis,
                        style: const TextStyle(color: AppColors.grey, fontSize: 12)),
                    Text('Size: ${e.size} • Qty: ${e.quantity}', style: const TextStyle(fontSize: 12)),
                  ]),
                ),
              ]),
            )),
        Text('Paid via ${order.payment}', style: const TextStyle(fontSize: 12, color: AppColors.grey)),
      ]),
    );
  }
}
