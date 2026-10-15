import 'package:flutter/material.dart';
import '../data/mock_data.dart';
import '../theme.dart';
import 'product_list_screen.dart';

class SearchScreen extends StatefulWidget {
  const SearchScreen({super.key});

  @override
  State<SearchScreen> createState() => _SearchScreenState();
}

class _SearchScreenState extends State<SearchScreen> {
  final _ctrl = TextEditingController();
  static final List<String> _recent = [];
  String _q = '';

  static const _popular = ['Sneakers', 'Dresses', 'Frocks', 'Shirts', 'Watches', 'Handbags', 'Sunglasses'];

  List<String> get _suggestions {
    if (_q.isEmpty) return [];
    final q = _q.toLowerCase();
    final terms = <String>{
      ...allProducts.map((p) => p.brand),
      ...allProducts.map((p) => '${p.category} ${p.subCategory}'),
      ...allProducts.map((p) => p.subCategory),
    };
    return terms.where((t) => t.toLowerCase().contains(q)).take(8).toList();
  }

  void _submit(String q) {
    q = q.trim();
    if (q.isEmpty) return;
    _recent
      ..remove(q)
      ..insert(0, q);
    if (_recent.length > 6) _recent.removeLast();
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (_) => ProductListScreen(title: q, query: q)),
    );
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: TextField(
          controller: _ctrl,
          autofocus: true,
          textInputAction: TextInputAction.search,
          onChanged: (v) => setState(() => _q = v),
          onSubmitted: _submit,
          decoration: const InputDecoration(
            hintText: 'Search for brands and products',
            border: InputBorder.none,
          ),
        ),
        actions: [
          if (_q.isNotEmpty)
            IconButton(
              icon: const Icon(Icons.close),
              onPressed: () => setState(() {
                _ctrl.clear();
                _q = '';
              }),
            ),
        ],
      ),
      body: _q.isNotEmpty
          ? ListView(
              children: _suggestions
                  .map((s) => ListTile(
                        leading: const Icon(Icons.search, color: AppColors.grey),
                        title: Text(s),
                        onTap: () => _submit(s),
                      ))
                  .toList(),
            )
          : ListView(
              padding: const EdgeInsets.all(16),
              children: [
                if (_recent.isNotEmpty) ...[
                  const Text('RECENT SEARCHES', style: TextStyle(fontWeight: FontWeight.w800)),
                  const SizedBox(height: 10),
                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: _recent
                        .map((r) => ActionChip(
                              avatar: const Icon(Icons.history, size: 16),
                              label: Text(r),
                              onPressed: () => _submit(r),
                            ))
                        .toList(),
                  ),
                  const SizedBox(height: 24),
                ],
                const Text('POPULAR SEARCHES', style: TextStyle(fontWeight: FontWeight.w800)),
                const SizedBox(height: 10),
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: _popular
                      .map((r) => ActionChip(
                            avatar: const Icon(Icons.trending_up, size: 16),
                            label: Text(r),
                            onPressed: () => _submit(r),
                          ))
                      .toList(),
                ),
              ],
            ),
    );
  }
}
