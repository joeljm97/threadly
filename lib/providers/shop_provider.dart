import 'package:flutter/foundation.dart';
import '../models/product.dart';

class ShopProvider extends ChangeNotifier {
  final Map<String, CartItem> _cart = {};
  final Set<String> _wishlist = {};
  final List<Order> _orders = [];
  final List<Product> _recentlyViewed = [];

  // ---------- Cart ----------
  List<CartItem> get cartItems => _cart.values.toList();
  int get cartCount => _cart.values.fold(0, (s, e) => s + e.quantity);
  int get cartTotal => _cart.values.fold(0, (s, e) => s + e.total);
  int get cartMrp => _cart.values.fold(0, (s, e) => s + e.mrpTotal);
  int get cartDiscount => cartMrp - cartTotal;
  int get deliveryFee => cartTotal >= 799 || cartTotal == 0 ? 0 : 79;
  int get platformFee => cartTotal == 0 ? 0 : 20;
  int get payable => cartTotal + deliveryFee + platformFee;

  void addToCart(Product p, String size) {
    final key = '${p.id}_$size';
    if (_cart.containsKey(key)) {
      _cart[key]!.quantity++;
    } else {
      _cart[key] = CartItem(product: p, size: size);
    }
    notifyListeners();
  }

  bool inCart(Product p) => _cart.values.any((e) => e.product.id == p.id);

  void setQuantity(CartItem item, int qty) {
    if (qty <= 0) {
      _cart.remove(item.key);
    } else {
      item.quantity = qty;
    }
    notifyListeners();
  }

  void removeFromCart(CartItem item) {
    _cart.remove(item.key);
    notifyListeners();
  }

  void moveToWishlist(CartItem item) {
    _cart.remove(item.key);
    _wishlist.add(item.product.id);
    notifyListeners();
  }

  // ---------- Wishlist ----------
  Set<String> get wishlistIds => _wishlist;
  bool isWishlisted(Product p) => _wishlist.contains(p.id);

  void toggleWishlist(Product p) {
    _wishlist.contains(p.id) ? _wishlist.remove(p.id) : _wishlist.add(p.id);
    notifyListeners();
  }

  // ---------- Recently viewed ----------
  List<Product> get recentlyViewed => List.unmodifiable(_recentlyViewed);

  void markViewed(Product p) {
    _recentlyViewed.removeWhere((e) => e.id == p.id);
    _recentlyViewed.insert(0, p);
    if (_recentlyViewed.length > 10) _recentlyViewed.removeLast();
    notifyListeners();
  }

  // ---------- Orders ----------
  List<Order> get orders => List.unmodifiable(_orders);

  Order placeOrder({required String address, required String payment}) {
    final order = Order(
      id: 'TH${DateTime.now().millisecondsSinceEpoch % 100000000}',
      items: cartItems
          .map((e) => CartItem(product: e.product, size: e.size, quantity: e.quantity))
          .toList(),
      amount: payable,
      address: address,
      payment: payment,
      placedAt: DateTime.now(),
    );
    _orders.insert(0, order);
    _cart.clear();
    notifyListeners();
    return order;
  }
}
