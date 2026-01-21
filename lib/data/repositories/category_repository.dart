import 'package:flutter/foundation.dart' show ValueListenable;
import 'package:hive/hive.dart';
import 'package:hive_flutter/hive_flutter.dart';

import '../models/category.dart';

class CategoryRepository {
  CategoryRepository(this._box);

  final Box<Category> _box;

  ValueListenable<Box<Category>> listenable() => _box.listenable();

  List<Category> getAll() =>
      _box.values.toList()
        ..sort((a, b) => a.name.toLowerCase().compareTo(b.name.toLowerCase()));

  Category? getById(String id) => _box.get(id);

  Future<void> upsert(Category category) => _box.put(category.id, category);

  Future<void> delete(String id) => _box.delete(id);
}
