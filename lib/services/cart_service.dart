import 'package:flutter/foundation.dart';
import '../models/gallery_detail_model.dart';
import '../models/cart_item_model.dart';

class CartService extends ChangeNotifier {
  static final CartService _instance = CartService._internal();
  factory CartService() => _instance;

  CartService._internal();

  final List<CartItem> _items = [];

  List<CartItem> get items => _items;

  void addToCart(GalleryImage image, ProductVariation variation) {
    // Check if item with same image ID and variation ID exists
    final exists = _items.any((item) => 
      item.image.id == image.id && item.variation.id == variation.id
    );

    if (!exists) {
      _items.add(CartItem(image: image, variation: variation));
      notifyListeners();
    }
  }

  void removeFromCart(CartItem item) {
    _items.remove(item);
    notifyListeners();
  }

  void clearCart() {
    _items.clear();
    notifyListeners();
  }

  double get total => _items.fold(0, (sum, item) => sum + item.price);
}
