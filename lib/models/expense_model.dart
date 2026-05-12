import 'package:flutter/material.dart';

class ExpenseModel {
  final String id;
  final String title;
  final double amount;
  final DateTime date;
  final String category;
  final IconData icon;

  ExpenseModel({
    required this.id,
    required this.title,
    required this.amount,
    required this.date,
    required this.category,
    required this.icon,
  });

  ExpenseModel copyWith({
    String? id,
    String? title,
    double? amount,
    DateTime? date,
    String? category,
    IconData? icon,
  }) {
    return ExpenseModel(
      id: id ?? this.id,
      title: title ?? this.title,
      amount: amount ?? this.amount,
      date: date ?? this.date,
      category: category ?? this.category,
      icon: icon ?? this.icon,
    );
  }
}
