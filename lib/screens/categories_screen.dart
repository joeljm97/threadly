import 'package:flutter/material.dart';
import '../data/mock_data.dart';
import '../theme.dart';
import '../widgets/product_card.dart';
import 'product_list_screen.dart';

class CategoriesScreen extends StatelessWidget {
  const CategoriesScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Categories', style: TextStyle(fontWeight: FontWeight.w700)),
        actions: const [ShopActions()],
      ),
      body: ListView.builder(
        itemCount: categories.length,
        itemBuilder: (_, i) {
          final c = categories[i];
          final subs = allProducts.where((p) => p.category == c).map((p) => p.subCategory).toSet().toList();
          return Theme(
            data: Theme.of(context).copyWith(dividerColor: Colors.transparent),
            child: ExpansionTile(
              tilePadding: EdgeInsets.zero,
              title: Container(
                height: 96,
                color: [
                  const Color(0xFFFFF0F2),
                  const Color(0xFFEFF6FF),
                  const Color(0xFFFFF8E7),
                  const Color(0xFFEFFAF5),
                  const Color(0xFFF4F0FF),
                ][i % 5],
                child: Row(children: [
                  const SizedBox(width: 20),
                  Expanded(
                    child: Text(c.toUpperCase(),
                        style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w800, letterSpacing: 1)),
                  ),
                  SizedBox(width: 110, height: 96, child: NetImage(categoryImages[c]!)),
                ]),
              ),
              trailing: const SizedBox.shrink(),
              children: [
                ListTile(
                  title: Text('All $c', style: const TextStyle(fontWeight: FontWeight.w700)),
                  trailing: const Icon(Icons.chevron_right, color: AppColors.grey),
                  onTap: () => Navigator.push(context,
                      MaterialPageRoute(builder: (_) => ProductListScreen(title: c, category: c))),
                ),
                ...subs.map((s) => ListTile(
                      title: Text(s),
                      trailing: const Icon(Icons.chevron_right, color: AppColors.grey),
                      onTap: () => Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (_) => ProductListScreen(title: '$c $s', category: c, subCategory: s)),
                      ),
                    )),
              ],
            ),
          );
        },
      ),
    );
  }
}
