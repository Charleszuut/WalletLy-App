import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';

import '../models/category.dart';
import '../models/transaction.dart';
import '../models/transaction_type.dart';

class HiveService {
  HiveService._();

  static const categoriesBox = 'categories_box';
  static const transactionsBox = 'transactions_box';

  static Future<void> init() async {
    await Hive.initFlutter();
    _registerAdapters();

    await Future.wait([
      Hive.openBox<Category>(categoriesBox),
      Hive.openBox<TransactionEntry>(transactionsBox),
    ]);

    await _seedDefaultCategories();
  }

  static void _registerAdapters() {
    if (!Hive.isAdapterRegistered(0)) {
      Hive.registerAdapter(TransactionTypeAdapter());
    }
    if (!Hive.isAdapterRegistered(1)) {
      Hive.registerAdapter(CategoryAdapter());
    }
    if (!Hive.isAdapterRegistered(2)) {
      Hive.registerAdapter(TransactionEntryAdapter());
    }
  }

  static Future<void> _seedDefaultCategories() async {
    final box = Hive.box<Category>(categoriesBox);
    if (box.isNotEmpty) return;

    final defaults = <Category>[
      Category(
        id: 'food',
        name: 'Food',
        transactionType: TransactionType.expense,
        color: Colors.redAccent,
      ),
      Category(
        id: 'transport',
        name: 'Transport',
        transactionType: TransactionType.expense,
        color: Colors.blueAccent,
      ),
      Category(
        id: 'bills',
        name: 'Bills',
        transactionType: TransactionType.expense,
        color: Colors.orangeAccent,
      ),
      Category(
        id: 'entertainment',
        name: 'Entertainment',
        transactionType: TransactionType.expense,
        color: Colors.purpleAccent,
      ),
      Category(
        id: 'savings',
        name: 'Savings',
        transactionType: TransactionType.income,
        color: Colors.green,
      ),
      Category(
        id: 'general_income',
        name: 'General Income',
        transactionType: TransactionType.income,
        color: Colors.teal,
      ),
    ];

    for (final category in defaults) {
      await box.put(category.id, category);
    }
  }
}
