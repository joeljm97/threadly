import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../data/mock_data.dart';
import '../models/product.dart';
import '../providers/shop_provider.dart';
import '../theme.dart';
import '../widgets/product_card.dart';

class ProductDetailScreen extends StatefulWidget {
  final Product product;
  const ProductDetailScreen({super.key, required this.product});

  @override
  State<ProductDetailScreen> createState() => _ProductDetailScreenState();
}

class _ProductDetailScreenState extends State<ProductDetailScreen> {
  int _image = 0;
  String? _size;
  final _pincode = TextEditingController();
  String? _deliveryMsg;

  @override
  void initState() {
    super.initState();
    final p = widget.product;
    if (p.sizes.length == 1) _size = p.sizes.first;
    WidgetsBinding.instance.addPostFrameCallback((_) => context.read<ShopProvider>().markViewed(p));
  }

  @override
  void dispose() {
    _pincode.dispose();
    super.dispose();
  }

  void _addToBag() {
    final shop = context.read<ShopProvider>();
    if (_size == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please select a size'), behavior: SnackBarBehavior.floating),
      );
      return;
    }
    shop.addToCart(widget.product, _size!);
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: const Text('Added to bag'),
        behavior: SnackBarBehavior.floating,
        action: SnackBarAction(label: 'GO TO BAG', onPressed: () => Navigator.pushNamed(context, '/bag')),
      ),
    );
  }

  void _checkPincode() {
    final pin = _pincode.text.trim();
    setState(() {
      if (!RegExp(r'^[1-9][0-9]{5}$').hasMatch(pin)) {
        _deliveryMsg = 'Enter a valid 6-digit pincode';
      } else {
        final days = 2 + int.parse(pin.substring(5)) % 4;
        final date = DateTime.now().add(Duration(days: days));
        const months = ['Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun', 'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'];
        _deliveryMsg = 'Get it by ${date.day} ${months[date.month - 1]} • Pay on delivery available';
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final p = widget.product;
    final shop = context.watch<ShopProvider>();
    final wished = shop.isWishlisted(p);
    final similar = allProducts.where((e) => e.subCategory == p.subCategory && e.id != p.id).take(6).toList();

    return Scaffold(
      appBar: AppBar(
        title: Text(p.brand, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w700)),
        actions: [
          IconButton(
            icon: const Icon(Icons.share_outlined),
            onPressed: () => ScaffoldMessenger.of(context)
                .showSnackBar(const SnackBar(content: Text('Share link copied'))),
          ),
          const ShopActions(),
        ],
      ),
      body: ListView(
        children: [
          AspectRatio(
            aspectRatio: 3 / 4,
            child: Stack(children: [
              PageView.builder(
                itemCount: p.images.length,
                onPageChanged: (i) => setState(() => _image = i),
                itemBuilder: (_, i) => i == 0
                    ? Hero(tag: 'img_${p.id}', child: NetImage(p.images[i], fit: BoxFit.contain))
                    : NetImage(p.images[i], fit: BoxFit.contain),
              ),
              Positioned(left: 12, bottom: 12, child: RatingChip(p)),
              Positioned(
                bottom: 14,
                left: 0,
                right: 0,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: List.generate(
                    p.images.length,
                    (i) => Container(
                      margin: const EdgeInsets.all(3),
                      width: 7,
                      height: 7,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: _image == i ? AppColors.primary : Colors.white70,
                      ),
                    ),
                  ),
                ),
              ),
            ]),
          ),
          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Text.rich(TextSpan(children: [
                TextSpan(text: '${p.brand}  ', style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 18)),
                TextSpan(text: p.name, style: const TextStyle(color: AppColors.grey, fontSize: 17)),
              ])),
              const SizedBox(height: 10),
              PriceRow(p, size: 19),
              const Text('inclusive of all taxes',
                  style: TextStyle(color: AppColors.green, fontWeight: FontWeight.w600, fontSize: 13)),
            ]),
          ),
          const Divider(thickness: 8, color: AppColors.light),

          // Size selector
          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Row(children: [
                const Text('SELECT SIZE', style: TextStyle(fontWeight: FontWeight.w800)),
                const Spacer(),
                TextButton(
                  onPressed: () => _showSizeChart(context),
                  child: const Text('SIZE CHART',
                      style: TextStyle(color: AppColors.primary, fontWeight: FontWeight.w700)),
                ),
              ]),
              const SizedBox(height: 8),
              Wrap(
                spacing: 10,
                runSpacing: 10,
                children: p.sizes.map((s) {
                  final sel = _size == s;
                  return GestureDetector(
                    onTap: () => setState(() => _size = s),
                    child: Container(
                      constraints: const BoxConstraints(minWidth: 50),
                      height: 50,
                      padding: const EdgeInsets.symmetric(horizontal: 14),
                      alignment: Alignment.center,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(25),
                        border: Border.all(
                            color: sel ? AppColors.primary : const Color(0xFFBFC0C6), width: sel ? 1.6 : 1),
                        color: sel ? AppColors.primary.withValues(alpha: 0.06) : null,
                      ),
                      child: Text(s,
                          style: TextStyle(
                              fontWeight: FontWeight.w700, color: sel ? AppColors.primary : AppColors.dark)),
                    ),
                  );
                }).toList(),
              ),
            ]),
          ),
          const Divider(thickness: 8, color: AppColors.light),

          // Delivery
          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              const Text('DELIVERY OPTIONS', style: TextStyle(fontWeight: FontWeight.w800)),
              const SizedBox(height: 10),
              TextField(
                controller: _pincode,
                keyboardType: TextInputType.number,
                maxLength: 6,
                decoration: InputDecoration(
                  hintText: 'Enter pincode',
                  counterText: '',
                  isDense: true,
                  border: const OutlineInputBorder(),
                  suffixIcon: TextButton(
                    onPressed: _checkPincode,
                    child: const Text('CHECK',
                        style: TextStyle(color: AppColors.primary, fontWeight: FontWeight.w700)),
                  ),
                ),
              ),
              if (_deliveryMsg != null)
                Padding(
                  padding: const EdgeInsets.only(top: 8),
                  child: Text(_deliveryMsg!, style: const TextStyle(fontSize: 13)),
                ),
              const SizedBox(height: 12),
              const _Perk(Icons.local_shipping_outlined, 'Free delivery on orders above ₹799'),
              const _Perk(Icons.payments_outlined, 'Pay on delivery available'),
              const _Perk(Icons.autorenew, 'Easy 14 days return & exchange'),
            ]),
          ),
          const Divider(thickness: 8, color: AppColors.light),

          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              const Text('PRODUCT DETAILS', style: TextStyle(fontWeight: FontWeight.w800)),
              const SizedBox(height: 8),
              Text(p.description, style: const TextStyle(height: 1.5)),
            ]),
          ),

          if (similar.isNotEmpty) ...[
            const Divider(thickness: 8, color: AppColors.light),
            const Padding(
              padding: EdgeInsets.fromLTRB(16, 16, 16, 12),
              child: Text('SIMILAR PRODUCTS', style: TextStyle(fontWeight: FontWeight.w800)),
            ),
            SizedBox(
              height: 290,
              child: ListView.separated(
                scrollDirection: Axis.horizontal,
                padding: const EdgeInsets.symmetric(horizontal: 12),
                itemCount: similar.length,
                separatorBuilder: (_, __) => const SizedBox(width: 8),
                itemBuilder: (_, i) => SizedBox(width: 150, child: ProductCard(similar[i])),
              ),
            ),
            const SizedBox(height: 16),
          ],
        ],
      ),
      bottomNavigationBar: SafeArea(
        child: Container(
          padding: const EdgeInsets.all(12),
          decoration: const BoxDecoration(
            color: Colors.white,
            border: Border(top: BorderSide(color: Color(0xFFEAEAEC))),
          ),
          child: Row(children: [
            Expanded(
              child: OutlinedButton.icon(
                onPressed: () => shop.toggleWishlist(p),
                icon: Icon(wished ? Icons.favorite : Icons.favorite_border,
                    color: wished ? AppColors.primary : AppColors.dark),
                label: Text(wished ? 'WISHLISTED' : 'WISHLIST'),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: ElevatedButton.icon(
                onPressed: shop.inCart(p) && _size == null
                    ? () => Navigator.pushNamed(context, '/bag')
                    : _addToBag,
                icon: const Icon(Icons.shopping_bag_outlined),
                label: Text(shop.inCart(p) && _size == null ? 'GO TO BAG' : 'ADD TO BAG'),
              ),
            ),
          ]),
        ),
      ),
    );
  }

  void _showSizeChart(BuildContext context) {
    showModalBottomSheet(
      context: context,
      builder: (_) => SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(mainAxisSize: MainAxisSize.min, crossAxisAlignment: CrossAxisAlignment.start, children: [
            const Text('Size Chart (inches)', style: TextStyle(fontWeight: FontWeight.w800, fontSize: 16)),
            const SizedBox(height: 12),
            Table(
              border: TableBorder.all(color: const Color(0xFFEAEAEC)),
              children: const [
                TableRow(children: [_Cell('Size', bold: true), _Cell('Chest', bold: true), _Cell('Length', bold: true)]),
                TableRow(children: [_Cell('S'), _Cell('38'), _Cell('27')]),
                TableRow(children: [_Cell('M'), _Cell('40'), _Cell('28')]),
                TableRow(children: [_Cell('L'), _Cell('42'), _Cell('29')]),
                TableRow(children: [_Cell('XL'), _Cell('44'), _Cell('30')]),
              ],
            ),
          ]),
        ),
      ),
    );
  }
}

class _Cell extends StatelessWidget {
  final String text;
  final bool bold;
  const _Cell(this.text, {this.bold = false});

  @override
  Widget build(BuildContext context) => Padding(
        padding: const EdgeInsets.all(10),
        child: Text(text, style: TextStyle(fontWeight: bold ? FontWeight.w700 : FontWeight.normal)),
      );
}

class _Perk extends StatelessWidget {
  final IconData icon;
  final String text;
  const _Perk(this.icon, this.text);

  @override
  Widget build(BuildContext context) => Padding(
        padding: const EdgeInsets.symmetric(vertical: 5),
        child: Row(children: [
          Icon(icon, size: 20, color: AppColors.dark),
          const SizedBox(width: 10),
          Expanded(child: Text(text, style: const TextStyle(fontSize: 13))),
        ]),
      );
}
