import '../models/product.dart';

const categories = ['Men', 'Women', 'Kids', 'Footwear', 'Accessories'];

const categoryImages = {
  'Men': 'https://picsum.photos/seed/men-fashion/300/300',
  'Women': 'https://picsum.photos/seed/women-fashion/300/300',
  'Kids': 'https://picsum.photos/seed/kids-fashion/300/300',
  'Footwear': 'https://picsum.photos/seed/shoes-fashion/300/300',
  'Accessories': 'https://picsum.photos/seed/bags-fashion/300/300',
};

const banners = [
  {'title': 'BIG FASHION FESTIVAL', 'subtitle': '50–80% OFF', 'image': 'https://picsum.photos/seed/banner1/800/400'},
  {'title': 'NEW SEASON DROPS', 'subtitle': 'Fresh styles daily', 'image': 'https://picsum.photos/seed/banner2/800/400'},
  {'title': 'ETHNIC EDIT', 'subtitle': 'Min. 40% OFF', 'image': 'https://picsum.photos/seed/banner3/800/400'},
];

const _brands = ['Urban Loom', 'Saffron Lane', 'Kite & Co', 'Northwind', 'Rang Mahal', 'Denim Theory', 'Stride', 'Aurelia'];

const _catalog = {
  'Men': ['T-Shirts', 'Shirts', 'Jeans', 'Kurtas', 'Jackets'],
  'Women': ['Dresses', 'Kurtis', 'Tops', 'Sarees', 'Jeans'],
  'Kids': ['T-Shirts', 'Dresses', 'Shorts', 'Sets'],
  'Footwear': ['Sneakers', 'Sandals', 'Heels', 'Loafers'],
  'Accessories': ['Watches', 'Handbags', 'Sunglasses', 'Wallets'],
};

const _adjectives = ['Printed', 'Solid', 'Slim Fit', 'Relaxed', 'Embroidered', 'Striped', 'Oversized', 'Classic'];

List<String> _sizesFor(String category, String sub) {
  if (category == 'Footwear') return ['6', '7', '8', '9', '10', '11'];
  if (category == 'Accessories') return ['Onesize'];
  if (category == 'Kids') return ['2-3Y', '4-5Y', '6-7Y', '8-9Y'];
  if (sub == 'Sarees') return ['Free'];
  if (sub == 'Jeans') return ['28', '30', '32', '34', '36'];
  return ['XS', 'S', 'M', 'L', 'XL', 'XXL'];
}

/// Deterministic mock catalogue (~70 products) so the UI looks full.
final List<Product> allProducts = () {
  final list = <Product>[];
  var i = 0;
  _catalog.forEach((category, subs) {
    for (final sub in subs) {
      for (var n = 0; n < 4; n++) {
        i++;
        final brand = _brands[(i * 3 + n) % _brands.length];
        final adj = _adjectives[(i + n) % _adjectives.length];
        final mrp = 799 + ((i * 137) % 3200);
        final discount = 20 + ((i * 7) % 55);
        final price = (mrp * (100 - discount) / 100).round();
        list.add(Product(
          id: 'p$i',
          brand: brand,
          name: '$category $adj $sub',
          category: category,
          subCategory: sub,
          price: price,
          mrp: mrp,
          rating: 3.5 + ((i * 3) % 15) / 10,
          ratingCount: 120 + (i * 53) % 9000,
          images: List.generate(4, (k) => 'https://picsum.photos/seed/threadly$i-$k/600/800'),
          sizes: _sizesFor(category, sub),
          description:
              'A $adj ${sub.toLowerCase()} from $brand. Soft, breathable fabric designed for everyday comfort. '
              'Machine wash cold. Model is wearing size M.',
        ));
      }
    }
  });
  return list;
}();
