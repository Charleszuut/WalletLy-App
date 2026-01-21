import 'package:flutter/material.dart';
import 'package:uuid/uuid.dart';

import '../models/category.dart';
import '../models/category_total.dart';
import '../models/monthly_totals.dart';
import '../models/transaction.dart';
import '../models/transaction_type.dart';
import '../repositories/finance_repository.dart';

class FinanceProvider extends ChangeNotifier {
  FinanceProvider(this._repository) {
    _repository.addListener(_onRepositoryChanged);
  }

  final FinanceRepository _repository;

  List<Category> get categories => _repository.categories;
  List<TransactionEntry> get transactions => _repository.transactions;

  double get totalIncome => transactions
      .where((t) => t.type.isIncome)
      .fold(0, (previousValue, element) => previousValue + element.amount);

  double get totalExpenses => transactions
      .where((t) => t.type.isExpense)
      .fold(0, (previousValue, element) => previousValue + element.amount);

  double get currentBalance => totalIncome - totalExpenses;

  List<TransactionEntry> recentTransactions([int limit = 5]) {
    if (transactions.length <= limit) {
      return List<TransactionEntry>.from(transactions);
    }
    return transactions.take(limit).toList();
  }

  List<Category> categoriesForType(TransactionType type) =>
      categories.where((c) => c.transactionType == type).toList();

  Category? categoryById(String id) {
    for (final category in categories) {
      if (category.id == id) return category;
    }
    return null;
  }

  List<TransactionEntry> transactionsForMonth(DateTime month) {
    final target = DateTime(month.year, month.month);
    return transactions
        .where((t) => DateTime(t.date.year, t.date.month) == target)
        .toList();
  }

  double incomeForMonth(DateTime month) => transactionsForMonth(
    month,
  ).where((t) => t.type.isIncome).fold(0, (sum, t) => sum + t.amount);

  double expensesForMonth(DateTime month) => transactionsForMonth(
    month,
  ).where((t) => t.type.isExpense).fold(0, (sum, t) => sum + t.amount);

  double balanceForMonth(DateTime month) =>
      incomeForMonth(month) - expensesForMonth(month);

  List<DateTime> get monthsWithTransactions {
    final set = <DateTime>{};
    for (final transaction in transactions) {
      set.add(DateTime(transaction.date.year, transaction.date.month));
    }
    if (set.isEmpty) {
      final now = DateTime.now();
      return [DateTime(now.year, now.month)];
    }
    final items = set.toList()..sort((a, b) => b.compareTo(a));
    return items;
  }

  List<CategoryTotal> expenseCategoryTotals({DateTime? month}) {
    final Iterable<TransactionEntry> filtered = month == null
        ? transactions.where((t) => t.type.isExpense)
        : transactionsForMonth(month).where((t) => t.type.isExpense);

    final totals = <String, double>{};
    for (final transaction in filtered) {
      totals.update(
        transaction.categoryId,
        (value) => value + transaction.amount,
        ifAbsent: () => transaction.amount,
      );
    }

    final results = <CategoryTotal>[];
    totals.forEach((categoryId, total) {
      results.add(
        CategoryTotal(category: categoryById(categoryId), total: total),
      );
    });

    results.sort((a, b) => b.total.compareTo(a.total));
    return results;
  }

  List<MonthlyTotals> monthlyIncomeVsExpenses({int maxMonths = 6}) {
    final months = monthsWithTransactions.take(maxMonths).toList();
    months.sort((a, b) => a.compareTo(b));
    return months
        .map(
          (month) => MonthlyTotals(
            month: month,
            income: incomeForMonth(month),
            expenses: expensesForMonth(month),
          ),
        )
        .toList();
  }

  void _onRepositoryChanged() => notifyListeners();

  Future<void> addCategory({
    required String name,
    required TransactionType type,
    required Color color,
  }) async {
    final category = Category(
      id: const Uuid().v4(),
      name: name,
      transactionType: type,
      color: color,
      isCustom: true,
    );
    await _repository.upsertCategory(category);
    notifyListeners();
  }

  Future<void> updateCategory(Category category) async {
    await _repository.upsertCategory(category);
    notifyListeners();
  }

  Future<void> deleteCategory(Category category) async {
    await _repository.deleteCategory(category.id);
    notifyListeners();
  }

  Future<void> addTransaction({
    required TransactionType type,
    required double amount,
    required String categoryId,
    required DateTime date,
    String? notes,
  }) async {
    final entry = TransactionEntry(
      id: const Uuid().v4(),
      type: type,
      amount: amount,
      categoryId: categoryId,
      date: date,
      notes: notes,
    );
    await _repository.upsertTransaction(entry);
    notifyListeners();
  }

  Future<void> updateTransaction(TransactionEntry entry) async {
    await _repository.upsertTransaction(entry);
    notifyListeners();
  }

  Future<void> deleteTransaction(TransactionEntry entry) async {
    await _repository.deleteTransaction(entry.id);
    notifyListeners();
  }

  @override
  void dispose() {
    _repository.removeListener(_onRepositoryChanged);
    super.dispose();
  }
}
