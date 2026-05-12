import 'package:flutter/material.dart';
import '../../../models/expense_model.dart';

class ExpenseProvider extends ChangeNotifier {
  final List<ExpenseModel> _expenses = [];

  List<ExpenseModel> get expenses => _expenses;

  void addExpense(ExpenseModel expense) {
    _expenses.add(expense);
    notifyListeners();
  }

  void removeExpense(String id) {
    _expenses.removeWhere((expense) => expense.id == id);
    notifyListeners();
  }

  void updateExpense(ExpenseModel expense) {
    final index = _expenses.indexWhere((e) => e.id == expense.id);
    if (index != -1) {
      _expenses[index] = expense;
      notifyListeners();
    }
  }

  double getTotalExpenses() {
    return _expenses.fold(0, (sum, expense) => sum + expense.amount);
  }

  double getCategoryTotal(String category) {
    return _expenses
        .where((expense) => expense.category == category)
        .fold(0, (sum, expense) => sum + expense.amount);
  }

  List<ExpenseModel> getExpensesByCategory(String category) {
    return _expenses.where((expense) => expense.category == category).toList();
  }
}
