import 'package:flutter/material.dart';

// Routes
class AppRoutes {
  static const home = '/';
  static const productDetail = '/product-detail';
  static const cart = '/cart';
  static const checkout = '/checkout';
  static const orderSuccess = '/order-success';
  static const orders = '/orders';
  static const profile = '/profile';
  static const login = '/login';
  static const signup = '/signup';
  static const otp = '/otp';
}

// Colors
const Color kPrimaryColor = Color(0xFF1B4965);
const Color kCanvasColor = Color(0xFFF4F7FB);
const Color kCardColor = Colors.white;
const Color kTitleTextColor = Color(0xFF0F172A);
const Color kMutedTextColor = Color(0xFF64748B);

// Category Icons
const Map<String, IconData> kCategoryIcons = {
  'Food': Icons.restaurant,
  'Transport': Icons.directions_car,
  'Entertainment': Icons.movie,
  'Shopping': Icons.shopping_bag,
  'Bills': Icons.receipt,
  'Other': Icons.category,
};

// Currency Formatter
String formatCurrency(double value) => '৳${value.toStringAsFixed(2)}';
