class Product {
  final String id;
  final String brand;
  final String name;
  final String category; // Men, Women, Kids, Footwear, Accessories
  final String subCategory; // T-Shirts, Jeans, Dresses ...
  final int price; // selling price in ₹
  final int mrp; // original price in ₹
  final double rating;
  final int ratingCount;
  final List<String> images;
  final List<String> sizes;
  final String description;

  const Product({
    required this.id,
    required this.brand,
    required this.name,
    required this.category,
    required this.subCategory,
    required this.price,
    required this.mrp,
    required this.rating,
    required this.ratingCount,
    required this.images,
    required this.sizes,
    required this.description,
  });

  int get discountPercent => mrp <= price ? 0 : (((mrp - price) / mrp) * 100).round();
}

class CartItem {
  final Product product;
  final String size;
  int quantity;

  CartItem({required this.product, required this.size, this.quantity = 1});

  String get key => '${product.id}_$size';
  int get total => product.price * quantity;
  int get mrpTotal => product.mrp * quantity;
}

class Order {
  final String id;
  final List<CartItem> items;
  final int amount;
  final String address;
  final String payment;
  final DateTime placedAt;

  Order({
    required this.id,
    required this.items,
    required this.amount,
    required this.address,
    required this.payment,
    required this.placedAt,
  });
}
