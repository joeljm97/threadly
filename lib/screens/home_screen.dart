import 'dart:async';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../data/mock_data.dart';
import '../providers/shop_provider.dart';
import '../theme.dart';
import '../widgets/product_card.dart';
import 'product_list_screen.dart';
import 'search_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final _bannerCtrl = PageController();
  int _banner = 0;
  Timer? _timer;

  @override
  void initState() {
    super.initState();
    _timer = Timer.periodic(const Duration(seconds: 4), (_) {
      if (!_bannerCtrl.hasClients) return;
      final next = (_banner + 1) % banners.length;
      _bannerCtrl.animateToPage(next, duration: const Duration(milliseconds: 400), curve: Curves.easeOut);
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    _bannerCtrl.dispose();
    super.dispose();
  }

  void _openList(String title, {String? category, String? sub, int? minDiscount, int? maxPrice}) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => ProductListScreen(
          title: title,
          category: category,
          subCategory: sub,
          minDiscount: minDiscount,
          maxPrice: maxPrice,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final recent = context.watch<ShopProvider>().recentlyViewed;
    final deals = allProducts.where((p) => p.discountPercent >= 60).take(6).toList();
    final trending = [...allProducts]..sort((a, b) => b.ratingCount.compareTo(a.ratingCount));

    return Scaffold(
      appBar: AppBar(
        titleSpacing: 16,
        title: Text('threadly',
            style: TextStyle(
                fontWeight: FontWeight.w800, fontSize: 24, color: AppColors.primary, letterSpacing: -0.5)),
        actions: const [ShopActions(), SizedBox(width: 4)],
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(56),
          child: Padding(
            padding: const EdgeInsets.fromLTRB(16, 0, 16, 10),
            child: InkWell(
              onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const SearchScreen())),
              child: Container(
                height: 44,
                padding: const EdgeInsets.symmetric(horizontal: 12),
                decoration: BoxDecoration(
                  border: Border.all(color: const Color(0xFFD4D5D9)),
                  borderRadius: BorderRadius.circular(6),
                ),
                child: const Row(children: [
                  Icon(Icons.search, color: AppColors.grey),
                  SizedBox(width: 8),
                  Text('Search for brands and products', style: TextStyle(color: AppColors.grey)),
                ]),
              ),
            ),
          ),
        ),
      ),
      body: ListView(
        children: [
          // Category circles
          SizedBox(
            height: 104,
            child: ListView.separated(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
              itemCount: categories.length,
              separatorBuilder: (_, __) => const SizedBox(width: 14),
              itemBuilder: (_, i) {
                final c = categories[i];
                return GestureDetector(
                  onTap: () => _openList(c, category: c),
                  child: Column(children: [
                    ClipOval(child: SizedBox(width: 60, height: 60, child: NetImage(categoryImages[c]!))),
                    const SizedBox(height: 6),
                    Text(c, style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600)),
                  ]),
                );
              },
            ),
          ),

          // Banner carousel
          AspectRatio(
            aspectRatio: 2,
            child: PageView.builder(
              controller: _bannerCtrl,
              itemCount: banners.length,
              onPageChanged: (i) => setState(() => _banner = i),
              itemBuilder: (_, i) {
                final b = banners[i];
                return GestureDetector(
                  onTap: () => _openList(b['title']!, minDiscount: 50),
                  child: Stack(fit: StackFit.expand, children: [
                    NetImage(b['image']!),
                    Container(
                      decoration: const BoxDecoration(
                        gradient: LinearGradient(
                          begin: Alignment.centerLeft,
                          end: Alignment.centerRight,
                          colors: [Colors.black54, Colors.transparent],
                        ),
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.all(20),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(b['title']!,
                              style: const TextStyle(
                                  color: Colors.white, fontSize: 22, fontWeight: FontWeight.w800)),
                          const SizedBox(height: 4),
                          Text(b['subtitle']!,
                              style: const TextStyle(color: Colors.white, fontSize: 16)),
                          const SizedBox(height: 12),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                            color: Colors.white,
                            child: const Text('SHOP NOW',
                                style: TextStyle(fontWeight: FontWeight.w700, fontSize: 12)),
                          ),
                        ],
                      ),
                    ),
                  ]),
                );
              },
            ),
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: List.generate(
              banners.length,
              (i) => AnimatedContainer(
                duration: const Duration(milliseconds: 250),
                margin: const EdgeInsets.all(3),
                width: _banner == i ? 18 : 6,
                height: 6,
                decoration: BoxDecoration(
                  color: _banner == i ? AppColors.dark : const Color(0xFFD4D5D9),
                  borderRadius: BorderRadius.circular(3),
                ),
              ),
            ),
          ),

          // Price-point tiles
          const _SectionTitle('BUDGET BUYS'),
          SizedBox(
            height: 92,
            child: ListView(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: 12),
              children: [499, 799, 999, 1499].map((p) {
                return GestureDetector(
                  onTap: () => _openList('Under ₹$p', maxPrice: p),
                  child: Container(
                    width: 110,
                    margin: const EdgeInsets.only(right: 10),
                    decoration: BoxDecoration(
                      color: const Color(0xFFFFF0F2),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    alignment: Alignment.center,
                    child: Column(mainAxisSize: MainAxisSize.min, children: [
                      const Text('UNDER', style: TextStyle(fontSize: 11, letterSpacing: 1)),
                      Text('₹$p',
                          style: const TextStyle(
                              fontSize: 22, fontWeight: FontWeight.w800, color: AppColors.primary)),
                    ]),
                  ),
                );
              }).toList(),
            ),
          ),

          const _SectionTitle('DEAL OF THE DAY'),
          SizedBox(
            height: 290,
            child: ListView.separated(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: 12),
              itemCount: deals.length,
              separatorBuilder: (_, __) => const SizedBox(width: 8),
              itemBuilder: (_, i) => SizedBox(width: 150, child: ProductCard(deals[i])),
            ),
          ),

          if (recent.isNotEmpty) ...[
            const _SectionTitle('RECENTLY VIEWED'),
            SizedBox(
              height: 290,
              child: ListView.separated(
                scrollDirection: Axis.horizontal,
                padding: const EdgeInsets.symmetric(horizontal: 12),
                itemCount: recent.length,
                separatorBuilder: (_, __) => const SizedBox(width: 8),
                itemBuilder: (_, i) => SizedBox(width: 150, child: ProductCard(recent[i])),
              ),
            ),
          ],

          const _SectionTitle('TRENDING NOW'),
          ProductGrid(trending.take(10).toList(), shrinkWrap: true),
          Padding(
            padding: const EdgeInsets.all(16),
            child: OutlinedButton(
              onPressed: () => _openList('All Products'),
              child: const Text('VIEW ALL PRODUCTS'),
            ),
          ),
        ],
      ),
    );
  }
}

class _SectionTitle extends StatelessWidget {
  final String text;
  const _SectionTitle(this.text);

  @override
  Widget build(BuildContext context) => Padding(
        padding: const EdgeInsets.fromLTRB(16, 22, 16, 12),
        child: Text(text,
            style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w800, letterSpacing: 1.2)),
      );
}
