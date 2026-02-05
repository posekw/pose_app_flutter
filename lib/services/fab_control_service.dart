import 'package:flutter/material.dart';

class FabControlService extends ChangeNotifier {
  static final FabControlService _instance = FabControlService._internal();
  factory FabControlService() => _instance;
  FabControlService._internal();

  bool _showAddToCart = false;
  VoidCallback? _onAddToCartPressed;
  String _priceText = '';

  bool get showAddToCart => _showAddToCart;
  VoidCallback? get onAddToCartPressed => _onAddToCartPressed;
  String get priceText => _priceText;

  void setAddToCartMode({required VoidCallback onPressed, String price = ''}) {
    _showAddToCart = true;
    _onAddToCartPressed = onPressed;
    _priceText = price;
    notifyListeners();
  }

  void resetToDefault() {
    _showAddToCart = false;
    _onAddToCartPressed = null;
    _priceText = '';
    notifyListeners();
  }
}
