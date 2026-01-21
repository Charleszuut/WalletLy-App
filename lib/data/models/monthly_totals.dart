class MonthlyTotals {
  const MonthlyTotals({
    required this.month,
    required this.income,
    required this.expenses,
  });

  final DateTime month;
  final double income;
  final double expenses;

  double get balance => income - expenses;
}
