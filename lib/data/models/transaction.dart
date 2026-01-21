import 'package:hive/hive.dart';

import 'transaction_type.dart';

part 'transaction.g.dart';

@HiveType(typeId: 2)
class TransactionEntry extends HiveObject {
  TransactionEntry({
    required this.id,
    required this.type,
    required this.amount,
    required this.categoryId,
    required this.date,
    this.notes,
  });

  @HiveField(0)
  String id;

  @HiveField(1)
  TransactionType type;

  @HiveField(2)
  double amount;

  @HiveField(3)
  String categoryId;

  @HiveField(4)
  DateTime date;

  @HiveField(5)
  String? notes;

  TransactionEntry copyWith({
    TransactionType? type,
    double? amount,
    String? categoryId,
    DateTime? date,
    String? notes,
  }) {
    return TransactionEntry(
      id: id,
      type: type ?? this.type,
      amount: amount ?? this.amount,
      categoryId: categoryId ?? this.categoryId,
      date: date ?? this.date,
      notes: notes ?? this.notes,
    );
  }
}
