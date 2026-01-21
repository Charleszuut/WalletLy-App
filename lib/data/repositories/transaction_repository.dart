import 'package:flutter/foundation.dart' show ValueListenable;
import 'package:hive_flutter/hive_flutter.dart';

import '../models/transaction.dart';

class TransactionRepository {
  TransactionRepository(this._box);

  final Box<TransactionEntry> _box;

  ValueListenable<Box<TransactionEntry>> listenable() => _box.listenable();

  List<TransactionEntry> getAll() =>
      _box.values.toList()..sort((a, b) => b.date.compareTo(a.date));

  TransactionEntry? getById(String id) => _box.get(id);

  Future<void> upsert(TransactionEntry entry) => _box.put(entry.id, entry);

  Future<void> delete(String id) => _box.delete(id);
}
