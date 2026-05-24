import 'package:flutter/material.dart';

import '../../../../models/product_model.dart';
import '../../../../services/cart_service.dart';
import '../models/cart_item.dart';

class CartProvider extends ChangeNotifier {
  CartProvider({CartService? cartService})
      : _cartService = cartService ?? CartService();

  final CartService _cartService;
  final Map<String, CartItem> _items = {};
  bool _isLoading = false;
  String? _loadedUserId;

  Map<String, CartItem> get items => _items;
  bool get isLoading => _isLoading;
  int get itemCount => _items.length;

  double get totalAmount {
    return _items.values.fold(
      0.0,
      (sum, item) => sum + item.product.price * item.quantity,
    );
  }

  Future<void> loadCartFromFirestore({bool force = false}) async {
    final uid = _cartService.currentUserId;
    if (uid == null) {
      clearLocalCart();
      return;
    }

    if (!force && (_loadedUserId == uid || _isLoading)) return;

    _setLoading(true);
    try {
      final cartItems = await _cartService.fetchUserCart();
      _replaceItems(cartItems, uid);
    } finally {
      _setLoading(false);
    }
  }

  Future<void> addItem(Product product) async {
    await _cartService.addToCart(product, 1);
    await _refreshFromFirestore();
  }

  Future<void> updateQuantity(String productId, int quantity) async {
    await _cartService.updateCartQuantity(productId, quantity);
    await _refreshFromFirestore();
  }

  Future<void> increaseQuantity(String productId) async {
    final item = _items[productId];
    if (item == null) return;
    await updateQuantity(productId, item.quantity + 1);
  }

  Future<void> decreaseQuantity(String productId) async {
    final item = _items[productId];
    if (item == null) return;
    await updateQuantity(productId, item.quantity - 1);
  }

  Future<void> removeItem(String productId) async {
    await _cartService.removeFromCart(productId);
    _items.remove(productId);
    notifyListeners();
  }

  Future<void> clearCart() async {
    await _cartService.clearUserCart();
    clearLocalCart();
  }

  void clearLocalCart() {
    _loadedUserId = null;
    if (_items.isEmpty) return;
    _items.clear();
    notifyListeners();
  }

  Future<void> _refreshFromFirestore() async {
    final uid = _cartService.currentUserId;
    if (uid == null) return;

    final cartItems = await _cartService.fetchUserCart();
    _replaceItems(cartItems, uid);
  }

  void _replaceItems(List<CartItem> cartItems, String uid) {
    _items.clear();
    for (final item in cartItems) {
      _items[item.product.id] = item;
    }
    _loadedUserId = uid;
    notifyListeners();
  }

  void _setLoading(bool value) {
    if (_isLoading == value) return;
    _isLoading = value;
    notifyListeners();
  }
}
