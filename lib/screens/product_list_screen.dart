import 'package:flutter/material.dart';
import '../data/mock_data.dart';
import '../models/product.dart';
import '../theme.dart';
import '../widgets/product_card.dart';

enum SortBy { popularity, newest, priceLow, priceHigh, discount, rating }

const sortLabels = {
  SortBy.popularity: 'Popularity',
  SortBy.newest: "What's New",
  SortBy.priceHigh: 'Price - high to low',
  SortBy.priceLow: 'Price - low to high',
  SortBy.discount: 'Better Discount',
  SortBy.rating: 'Customer Rating',
};

class ProductListScreen extends StatefulWidget {
  final String title;
  final String? category;
  final String? subCategory;
  final int? minDiscount;
  final int? maxPrice;
  final String? query;

  const ProductListScreen({
    super.key,
    required this.title,
    this.category,
    this.subCategory,
    this.minDiscount,
    this.maxPrice,
    this.query,
  });

  @override
  State<ProductListScreen> createState() => _ProductListScreenState();
}

class _ProductListScreenState extends State<ProductListScreen> {
  SortBy _sort = SortBy.popularity;
  final Set<String> _brands = {};
  final Set<String> _subs = {};
  int _minDiscount = 0;
  RangeValues? _price;

  List<Product> get _base => allProducts.where((p) {
        if (widget.category != null && p.category != widget.category) return false;
        if (widget.subCategory != null && p.subCategory != widget.subCategory) return false;
        if (widget.minDiscount != null && p.discountPercent < widget.minDiscount!) return false;
        if (widget.maxPrice != null && p.price > widget.maxPrice!) return false;
        if (widget.query != null && widget.query!.isNotEmpty) {
          final q = widget.query!.toLowerCase();
          final hay = '${p.brand} ${p.name} ${p.category} ${p.subCategory}'.toLowerCase();
          if (!q.split(' ').where((w) => w.isNotEmpty).every(hay.contains)) return false;
        }
        return true;
      }).toList();

  List<Product> get _visible {
    final list = _base.where((p) {
      if (_brands.isNotEmpty && !_brands.contains(p.brand)) return false;
      if (_subs.isNotEmpty && !_subs.contains(p.subCategory)) return false;
      if (p.discountPercent < _minDiscount) return false;
      if (_price != null && (p.price < _price!.start || p.price > _price!.end)) return false;
      return true;
    }).toList();
    switch (_sort) {
      case SortBy.popularity:
        list.sort((a, b) => b.ratingCount.compareTo(a.ratingCount));
      case SortBy.newest:
        list.sort((a, b) => int.parse(b.id.substring(1)).compareTo(int.parse(a.id.substring(1))));
      case SortBy.priceLow:
        list.sort((a, b) => a.price.compareTo(b.price));
      case SortBy.priceHigh:
        list.sort((a, b) => b.price.compareTo(a.price));
      case SortBy.discount:
        list.sort((a, b) => b.discountPercent.compareTo(a.discountPercent));
      case SortBy.rating:
        list.sort((a, b) => b.rating.compareTo(a.rating));
    }
    return list;
  }

  int get _filterCount =>
      _brands.length + _subs.length + (_minDiscount > 0 ? 1 : 0) + (_price != null ? 1 : 0);

  void _openSort() {
    showModalBottomSheet(
      context: context,
      builder: (_) => SafeArea(
        child: Column(mainAxisSize: MainAxisSize.min, children: [
          const Padding(
            padding: EdgeInsets.all(16),
            child: Align(
                alignment: Alignment.centerLeft,
                child: Text('SORT BY', style: TextStyle(fontWeight: FontWeight.w700, color: AppColors.grey))),
          ),
          ...sortLabels.entries.map((e) => ListTile(
                title: Text(e.value,
                    style: TextStyle(
                        fontWeight: _sort == e.key ? FontWeight.w700 : FontWeight.normal,
                        color: _sort == e.key ? AppColors.primary : AppColors.dark)),
                trailing: _sort == e.key ? const Icon(Icons.check, color: AppColors.primary) : null,
                onTap: () {
                  setState(() => _sort = e.key);
                  Navigator.pop(context);
                },
              )),
        ]),
      ),
    );
  }

  Future<void> _openFilter() async {
    final base = _base;
    if (base.isEmpty) return;
    final brands = base.map((p) => p.brand).toSet().toList()..sort();
    final subs = base.map((p) => p.subCategory).toSet().toList()..sort();
    final minP = base.map((p) => p.price).reduce((a, b) => a < b ? a : b).toDouble();
    final maxP = base.map((p) => p.price).reduce((a, b) => a > b ? a : b).toDouble();

    final result = await Navigator.push<_FilterState>(
      context,
      MaterialPageRoute(
        fullscreenDialog: true,
        builder: (_) => _FilterScreen(
          brands: brands,
          subs: subs,
          minPrice: minP,
          maxPrice: maxP <= minP ? minP + 1 : maxP,
          initial: _FilterState({..._brands}, {..._subs}, _minDiscount, _price),
        ),
      ),
    );
    if (result != null) {
      setState(() {
        _brands
          ..clear()
          ..addAll(result.brands);
        _subs
          ..clear()
          ..addAll(result.subs);
        _minDiscount = result.minDiscount;
        _price = result.price;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final items = _visible;
    return Scaffold(
      appBar: AppBar(
        title: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Text(widget.title.toUpperCase(),
              style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w700)),
          Text('${items.length} Items', style: const TextStyle(fontSize: 12, color: AppColors.grey)),
        ]),
        actions: const [ShopActions()],
      ),
      body: items.isEmpty
          ? const Center(
              child: Padding(
                padding: EdgeInsets.all(32),
                child: Text('No products match. Try clearing some filters.',
                    textAlign: TextAlign.center, style: TextStyle(color: AppColors.grey)),
              ),
            )
          : ProductGrid(items),
      bottomNavigationBar: SafeArea(
        child: Container(
          height: 52,
          decoration: const BoxDecoration(
            border: Border(top: BorderSide(color: Color(0xFFEAEAEC))),
          ),
          child: Row(children: [
            Expanded(
              child: TextButton.icon(
                onPressed: _openSort,
                icon: const Icon(Icons.swap_vert, color: AppColors.dark),
                label: const Text('SORT', style: TextStyle(color: AppColors.dark, fontWeight: FontWeight.w700)),
              ),
            ),
            const VerticalDivider(width: 1, indent: 12, endIndent: 12),
            Expanded(
              child: TextButton.icon(
                onPressed: _openFilter,
                icon: Badge(
                  isLabelVisible: _filterCount > 0,
                  label: Text('$_filterCount'),
                  child: const Icon(Icons.tune, color: AppColors.dark),
                ),
                label: const Text('FILTER',
                    style: TextStyle(color: AppColors.dark, fontWeight: FontWeight.w700)),
              ),
            ),
          ]),
        ),
      ),
    );
  }
}

class _FilterState {
  final Set<String> brands;
  final Set<String> subs;
  final int minDiscount;
  final RangeValues? price;
  _FilterState(this.brands, this.subs, this.minDiscount, this.price);
}

class _FilterScreen extends StatefulWidget {
  final List<String> brands;
  final List<String> subs;
  final double minPrice;
  final double maxPrice;
  final _FilterState initial;

  const _FilterScreen({
    required this.brands,
    required this.subs,
    required this.minPrice,
    required this.maxPrice,
    required this.initial,
  });

  @override
  State<_FilterScreen> createState() => _FilterScreenState();
}

class _FilterScreenState extends State<_FilterScreen> {
  int _tab = 0;
  late Set<String> _brands = {...widget.initial.brands};
  late Set<String> _subs = {...widget.initial.subs};
  late int _disc = widget.initial.minDiscount;
  late RangeValues _price =
      widget.initial.price ?? RangeValues(widget.minPrice, widget.maxPrice);

  static const _tabs = ['Categories', 'Brand', 'Price', 'Discount'];

  Widget _checkList(List<String> options, Set<String> selected) => ListView(
        children: options
            .map((o) => CheckboxListTile(
                  value: selected.contains(o),
                  title: Text(o),
                  activeColor: AppColors.primary,
                  controlAffinity: ListTileControlAffinity.leading,
                  onChanged: (v) => setState(() => v! ? selected.add(o) : selected.remove(o)),
                ))
            .toList(),
      );

  Widget _panel() {
    switch (_tab) {
      case 0:
        return _checkList(widget.subs, _subs);
      case 1:
        return _checkList(widget.brands, _brands);
      case 2:
        return Padding(
          padding: const EdgeInsets.all(16),
          child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Text('${rupees(_price.start.round())} – ${rupees(_price.end.round())}',
                style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 16)),
            RangeSlider(
              values: _price,
              min: widget.minPrice,
              max: widget.maxPrice,
              activeColor: AppColors.primary,
              onChanged: (v) => setState(() => _price = v),
            ),
          ]),
        );
      default:
        return ListView(
          children: [0, 10, 20, 30, 40, 50, 60, 70]
              .map((d) => RadioListTile<int>(
                    value: d,
                    groupValue: _disc,
                    activeColor: AppColors.primary,
                    title: Text(d == 0 ? 'Any' : '$d% and above'),
                    onChanged: (v) => setState(() => _disc = v!),
                  ))
              .toList(),
        );
    }
  }

  @override
  Widget build(BuildContext context) {
    final priceChanged = _price.start > widget.minPrice || _price.end < widget.maxPrice;
    return Scaffold(
      appBar: AppBar(
        title: const Text('FILTERS', style: TextStyle(fontSize: 15, fontWeight: FontWeight.w700)),
        actions: [
          TextButton(
            onPressed: () => setState(() {
              _brands = {};
              _subs = {};
              _disc = 0;
              _price = RangeValues(widget.minPrice, widget.maxPrice);
            }),
            child: const Text('CLEAR ALL', style: TextStyle(color: AppColors.primary, fontWeight: FontWeight.w700)),
          ),
        ],
      ),
      body: Row(children: [
        Container(
          width: 120,
          color: AppColors.light,
          child: ListView(
            children: List.generate(_tabs.length, (i) {
              final selected = i == _tab;
              return InkWell(
                onTap: () => setState(() => _tab = i),
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 18),
                  decoration: BoxDecoration(
                    color: selected ? Colors.white : null,
                    border: Border(
                        left: BorderSide(color: selected ? AppColors.primary : Colors.transparent, width: 3)),
                  ),
                  child: Text(_tabs[i],
                      style: TextStyle(fontWeight: selected ? FontWeight.w700 : FontWeight.w500)),
                ),
              );
            }),
          ),
        ),
        Expanded(child: _panel()),
      ]),
      bottomNavigationBar: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: Row(children: [
            Expanded(
              child: OutlinedButton(onPressed: () => Navigator.pop(context), child: const Text('CLOSE')),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: ElevatedButton(
                onPressed: () =>
                    Navigator.pop(context, _FilterState(_brands, _subs, _disc, priceChanged ? _price : null)),
                child: const Text('APPLY'),
              ),
            ),
          ]),
        ),
      ),
    );
  }
}
