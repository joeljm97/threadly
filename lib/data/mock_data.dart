import '../models/product.dart';

/// Dummy product photos from dummyjson.com's free test catalogue.
const _cdn = 'https://cdn.dummyjson.com/product-images';

/// Builds a URL-safe image link (some folder names contain & or ').
String _img(String folder, String slug, int n) =>
    '$_cdn/$folder/${slug.replaceAll('&', '%26').replaceAll("'", '%27')}/$n.webp';

class _Photo {
  final String slug;
  final String name;
  final int count;
  const _Photo(this.slug, this.name, this.count);
}

// folder -> photo sets
const _pools = <String, List<_Photo>>{
  'mens-shirts': [
    _Photo('blue-&-black-check-shirt', 'Blue & Black Check Shirt', 4),
    _Photo('gigabyte-aorus-men-tshirt', 'Graphic Print Crew T-Shirt', 4),
    _Photo('man-plaid-shirt', 'Plaid Casual Shirt', 4),
    _Photo('man-short-sleeve-shirt', 'Short Sleeve Shirt', 4),
    _Photo('men-check-shirt', 'Classic Check Shirt', 4),
  ],
  'womens-dresses': [
    _Photo("black-women's-gown", 'Black Evening Gown', 4),
    _Photo('corset-leather-with-skirt', 'Leather Corset Skirt Set', 4),
    _Photo('corset-with-black-skirt', 'Corset Top & Black Skirt', 4),
    _Photo('dress-pea', 'Pea Green Midi Dress', 4),
    _Photo('marni-red-&-black-suit', 'Red & Black Co-ord Set', 4),
  ],
  'tops': [
    _Photo('blue-frock', 'Blue Frock', 4),
    _Photo('girl-summer-dress', 'Summer Dress', 4),
    _Photo('gray-dress', 'Grey Shift Dress', 4),
    _Photo('short-frock', 'Short Frock', 4),
    _Photo('tartan-dress', 'Tartan Dress', 4),
  ],
  'mens-shoes': [
    _Photo('nike-air-jordan-1-red-and-black', 'Red & Black High-Top Sneakers', 4),
    _Photo('nike-baseball-cleats', 'Sports Cleats', 4),
    _Photo('puma-future-rider-trainers', 'Retro Runner Trainers', 4),
    _Photo('sports-sneakers-off-white-&-red', 'Off-White & Red Sneakers', 4),
    _Photo('sports-sneakers-off-white-red', 'Off-White Court Sneakers', 4),
  ],
  'womens-shoes': [
    _Photo('black-&-brown-slipper', 'Black & Brown Slippers', 4),
    _Photo('calvin-klein-heel-shoes', 'Pointed Block Heels', 4),
    _Photo('golden-shoes-woman', 'Golden Party Heels', 4),
    _Photo('pampi-shoes', 'Casual Flats', 4),
    _Photo('red-shoes', 'Red Heels', 4),
  ],
  'womens-bags': [
    _Photo("blue-women's-handbag", 'Blue Structured Handbag', 3),
    _Photo("heshe-women's-leather-bag", 'Leather Shoulder Bag', 3),
    _Photo('prada-women-bag', 'Classic Tote Bag', 3),
    _Photo('white-faux-leather-backpack', 'White Faux Leather Backpack', 3),
    _Photo('women-handbag-black', 'Black Handbag', 3),
  ],
  'mens-watches': [
    _Photo('brown-leather-belt-watch', 'Brown Leather Strap Watch', 3),
    _Photo('longines-master-collection', 'Master Collection Watch', 3),
    _Photo('rolex-cellini-date-black-dial', 'Black Dial Dress Watch', 3),
    _Photo('rolex-cellini-moonphase', 'Moonphase Watch', 3),
    _Photo('rolex-datejust', 'Two-Tone Steel Watch', 3),
    _Photo('rolex-submariner-watch', 'Diver Watch', 3),
  ],
  'womens-watches': [
    _Photo('iwc-ingenieur-automatic-steel', 'Automatic Steel Watch', 3),
    _Photo('rolex-cellini-moonphase', 'Moonphase Watch', 3),
    _Photo('rolex-datejust-women', "Women's Steel Watch", 3),
    _Photo('watch-gold-for-women', 'Gold Watch', 3),
    _Photo("women's-wrist-watch", 'Minimal Wrist Watch', 3),
  ],
  'sunglasses': [
    _Photo('black-sun-glasses', 'Black Sunglasses', 3),
    _Photo('classic-sun-glasses', 'Classic Sunglasses', 3),
    _Photo('green-and-black-glasses', 'Green & Black Sunglasses', 3),
    _Photo('party-glasses', 'Party Glasses', 3),
    _Photo('sunglasses', 'Everyday Sunglasses', 3),
  ],
  'womens-jewellery': [
    _Photo('green-crystal-earring', 'Green Crystal Earrings', 3),
    _Photo('green-oval-earring', 'Green Oval Earrings', 3),
    _Photo('tropical-earring', 'Tropical Earrings', 3),
  ],
};

class _Sub {
  final String name;
  final String folder;
  final int rotate; // start on a different photo so reused sets look fresh
  const _Sub(this.name, this.folder, [this.rotate = 0]);
}

const _catalog = <String, List<_Sub>>{
  'Men': [_Sub('Shirts', 'mens-shirts'), _Sub('Sneakers', 'mens-shoes'), _Sub('Watches', 'mens-watches')],
  'Women': [
    _Sub('Dresses', 'womens-dresses'),
    _Sub('Frocks', 'tops'),
    _Sub('Heels & Flats', 'womens-shoes'),
    _Sub('Handbags', 'womens-bags'),
    _Sub('Watches', 'womens-watches'),
    _Sub('Jewellery', 'womens-jewellery'),
  ],
  'Kids': [_Sub('Frocks', 'tops', 2), _Sub('Shirts', 'mens-shirts', 2)],
  'Footwear': [_Sub('Sneakers', 'mens-shoes', 1), _Sub('Heels & Flats', 'womens-shoes', 1)],
  'Accessories': [
    _Sub('Sunglasses', 'sunglasses'),
    _Sub('Handbags', 'womens-bags', 1),
    _Sub('Watches', 'mens-watches', 1),
  ],
};

const categories = ['Men', 'Women', 'Kids', 'Footwear', 'Accessories'];

final categoryImages = {
  'Men': _img('mens-shirts', 'man-plaid-shirt', 1),
  'Women': _img('womens-dresses', 'dress-pea', 1),
  'Kids': _img('tops', 'girl-summer-dress', 1),
  'Footwear': _img('mens-shoes', 'puma-future-rider-trainers', 1),
  'Accessories': _img('womens-bags', 'prada-women-bag', 1),
};

final banners = [
  {
    'title': 'BIG FASHION FESTIVAL',
    'subtitle': '50–80% OFF',
    'image': _img('womens-dresses', 'marni-red-&-black-suit', 1),
    'color': 0xFFE23E57,
  },
  {
    'title': 'SNEAKER SEASON',
    'subtitle': 'Fresh drops daily',
    'image': _img('mens-shoes', 'nike-air-jordan-1-red-and-black', 1),
    'color': 0xFF2D3A8C,
  },
  {
    'title': 'ACCESSORY EDIT',
    'subtitle': 'Min. 40% OFF',
    'image': _img('womens-bags', 'women-handbag-black', 1),
    'color': 0xFF0F7B6C,
  },
];

const _brands = ['Urban Loom', 'Saffron Lane', 'Kite & Co', 'Northwind', 'Rang Mahal', 'Denim Theory', 'Stride', 'Aurelia'];

List<String> _sizesFor(String category, String sub) {
  if (category == 'Kids') return ['2-3Y', '4-5Y', '6-7Y', '8-9Y'];
  if (sub == 'Sneakers' || sub == 'Heels & Flats') return ['6', '7', '8', '9', '10', '11'];
  if (sub == 'Watches' || sub == 'Handbags' || sub == 'Sunglasses' || sub == 'Jewellery') return ['Onesize'];
  return ['XS', 'S', 'M', 'L', 'XL', 'XXL'];
}

/// Deterministic mock catalogue (~75 products) with real-looking product photos.
final List<Product> allProducts = () {
  final list = <Product>[];
  var i = 0;
  _catalog.forEach((category, subs) {
    for (final sub in subs) {
      for (final photo in _pools[sub.folder]!) {
        i++;
        final brand = _brands[(i * 3) % _brands.length];
        final mrp = 799 + ((i * 137) % 3200);
        final discount = 20 + ((i * 7) % 55);
        final price = (mrp * (100 - discount) / 100).round();
        final order = List.generate(photo.count, (k) => (k + sub.rotate) % photo.count + 1);
        list.add(Product(
          id: 'p$i',
          brand: brand,
          name: category == 'Kids' ? 'Kids ${photo.name}' : photo.name,
          category: category,
          subCategory: sub.name,
          price: price,
          mrp: mrp,
          rating: 3.5 + ((i * 3) % 15) / 10,
          ratingCount: 120 + (i * 53) % 9000,
          images: order.map((n) => _img(sub.folder, photo.slug, n)).toList(),
          sizes: _sizesFor(category, sub.name),
          description: '${photo.name} from $brand. Carefully made with quality materials for everyday comfort '
              'and style. Easy 14-day returns.',
        ));
      }
    }
  });
  return list;
}();
