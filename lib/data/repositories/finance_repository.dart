import 'package:flutter/foundation.dart' show ChangeNotifier, ValueListenable;
import 'package:hive/hive.dart';

import '../models/category.dart';
import '../models/transaction.dart';
import 'category_repository.dart';
import 'transaction_repository.dart';

class FinanceRepository extends ChangeNotifier {
  FinanceRepository(this._categoryRepository, this._transactionRepository)
    : _categoryListenable = _categoryRepository.listenable(),
      _transactionListenable = _transactionRepository.listenable() {
    _categoryListenable.addListener(_notifyFromSource);
    _transactionListenable.addListener(_notifyFromSource);
  }

  final CategoryRepository _categoryRepository;
  final TransactionRepository _transactionRepository;
  final ValueListenable<Box<Category>> _categoryListenable;
  final ValueListenable<Box<TransactionEntry>> _transactionListenable;

  void _notifyFromSource() => notifyListeners();

  List<Category> get categories => _categoryRepository.getAll();
  List<TransactionEntry> get transactions => _transactionRepository.getAll();

  Future<void> upsertCategory(Category category) async {
    await _categoryRepository.upsert(category);
  }

  Future<void> deleteCategory(String id) async {
    await _categoryRepository.delete(id);
  }

  Future<void> upsertTransaction(TransactionEntry entry) async {
    await _transactionRepository.upsert(entry);
  }

  Future<void> deleteTransaction(String id) async {
    await _transactionRepository.delete(id);
  }

  @override
  void dispose() {
    _categoryListenable.removeListener(_notifyFromSource);
    _transactionListenable.removeListener(_notifyFromSource);
    super.dispose();
  }
}
