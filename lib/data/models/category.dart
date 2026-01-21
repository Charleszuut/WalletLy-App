import 'package:flutter/material.dart';
import 'package:hive/hive.dart';

import 'transaction_type.dart';

part 'category.g.dart';

@HiveType(typeId: 1)
class Category extends HiveObject {
  Category({
    required this.id,
    required this.name,
    required this.transactionType,
    Color? color,
    int? colorValueOverride,
    this.isCustom = false,
  }) : colorValue = colorValueOverride ?? color?.value ?? Colors.blueGrey.value;

  @HiveField(0)
  String id;

  @HiveField(1)
  String name;

  @HiveField(2)
  TransactionType transactionType;

  @HiveField(3)
  int colorValue;

  @HiveField(4)
  bool isCustom;

  Color get color => Color(colorValue);

  set color(Color value) => colorValue = value.value;

  Category copyWith({
    String? name,
    TransactionType? transactionType,
    Color? color,
    bool? isCustom,
  }) {
    return Category(
      id: id,
      name: name ?? this.name,
      transactionType: transactionType ?? this.transactionType,
      color: color ?? this.color,
      isCustom: isCustom ?? this.isCustom,
    );
  }
}
