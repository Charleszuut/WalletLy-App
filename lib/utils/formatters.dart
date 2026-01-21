import 'package:intl/intl.dart';

class Formatters {
  Formatters._();

  static final NumberFormat currency = NumberFormat.currency(
    symbol: '₱',
    decimalDigits: 2,
  );

  static final DateFormat fullDate = DateFormat.yMMMd();
  static final DateFormat monthYear = DateFormat.yMMM();
}
