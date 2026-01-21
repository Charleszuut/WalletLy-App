import 'package:flutter/material.dart';

import 'category.dart';

class CategoryTotal {
  const CategoryTotal({required this.category, required this.total});

  final Category? category;
  final double total;

  String get label => category?.name ?? 'Uncategorized';
  Color get color => category?.color ?? Colors.grey;
  bool get isCustom => category?.isCustom ?? false;
}
