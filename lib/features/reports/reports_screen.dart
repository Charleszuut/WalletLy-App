import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../data/models/category_total.dart';
import '../../data/models/monthly_totals.dart';
import '../../data/providers/finance_provider.dart';
import '../../utils/formatters.dart';

class ReportsScreen extends StatefulWidget {
  const ReportsScreen({super.key});

  @override
  State<ReportsScreen> createState() => _ReportsScreenState();
}

class _ReportsScreenState extends State<ReportsScreen> {
  DateTime? _selectedMonth;

  @override
  Widget build(BuildContext context) {
    final finance = context.watch<FinanceProvider>();
    final months = finance.monthsWithTransactions;
    final selectedMonth = _selectedMonth;
    final categoryTotals = finance
        .expenseCategoryTotals(month: selectedMonth)
        .take(8)
        .toList();
    final monthlyTotals = finance.monthlyIncomeVsExpenses(maxMonths: 6);

    final totalExpenses = categoryTotals.fold<double>(
      0,
      (sum, item) => sum + item.total,
    );

    final theme = Theme.of(context);
    return SafeArea(
      child: Scaffold(
        backgroundColor: theme.scaffoldBackgroundColor,
        appBar: AppBar(
          title: const Text('Reports & Insights'),
          backgroundColor: Colors.white,
          surfaceTintColor: Colors.white,
          elevation: 0,
        ),
        body: SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(20, 20, 20, 32),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _ReportsHeader(
                months: months,
                selectedMonth: selectedMonth,
                onMonthChanged: (value) =>
                    setState(() => _selectedMonth = value),
              ),
              const SizedBox(height: 24),
              _SectionTitle(
                title: 'Expenses by Category',
                subtitle: selectedMonth == null
                    ? 'All time overview'
                    : 'For ${Formatters.monthYear.format(selectedMonth)}',
              ),
              const SizedBox(height: 16),
              if (totalExpenses == 0)
                const _EmptyInsight(
                  icon: Icons.pie_chart_outline,
                  message: 'Add some expenses to see category distribution.',
                )
              else
                _ExpensePieChart(totals: categoryTotals, total: totalExpenses),
              const SizedBox(height: 28),
              const _SectionTitle(
                title: 'Monthly Income vs Expenses',
                subtitle: 'Past few months performance',
              ),
              const SizedBox(height: 16),
              if (monthlyTotals.isEmpty)
                const _EmptyInsight(
                  icon: Icons.bar_chart,
                  message: 'Add transactions to visualize monthly trends.',
                )
              else
                _MonthlyBarChart(totals: monthlyTotals),
              const SizedBox(height: 28),
              const _SectionTitle(
                title: 'Quick Insights',
                subtitle: 'Highlights based on your data',
              ),
              const SizedBox(height: 16),
              _InsightChips(
                totalExpenses: finance.totalExpenses,
                totalIncome: finance.totalIncome,
                balance: finance.currentBalance,
                topCategory: categoryTotals.isEmpty
                    ? null
                    : categoryTotals.first,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _ReportsHeader extends StatelessWidget {
  const _ReportsHeader({
    required this.months,
    required this.selectedMonth,
    required this.onMonthChanged,
  });

  final List<DateTime> months;
  final DateTime? selectedMonth;
  final ValueChanged<DateTime?> onMonthChanged;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return LayoutBuilder(
      builder: (context, constraints) {
        final isNarrow = constraints.maxWidth < 520;

        final header = Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Dive into your spending habits',
              style: theme.textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.w700,
                color: const Color(0xFF1F2937),
                fontSize: 16,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              'Understand where your money goes and how your savings evolve.',
              style: theme.textTheme.bodySmall?.copyWith(
                color: const Color(0xFF6B7280),
                height: 1.4,
              ),
            ),
          ],
        );

        final dropdown = ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 220),
          child: DecoratedBox(
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: const Color(0xFFE5E7EB)),
              boxShadow: const [
                BoxShadow(
                  color: Color(0x0F000000),
                  offset: Offset(0, 6),
                  blurRadius: 16,
                ),
              ],
            ),
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 12),
              child: DropdownButtonHideUnderline(
                child: DropdownButton<DateTime?>(
                  value: selectedMonth,
                  isExpanded: true,
                  borderRadius: BorderRadius.circular(16),
                  dropdownColor: Colors.white,
                  style: theme.textTheme.bodyMedium?.copyWith(
                    color: const Color(0xFF1F2937),
                    fontWeight: FontWeight.w500,
                  ),
                  icon: const Icon(Icons.keyboard_arrow_down_rounded),
                  onChanged: onMonthChanged,
                  items: [
                    const DropdownMenuItem<DateTime?>(
                      value: null,
                      child: Text('All time'),
                    ),
                    for (final month in months)
                      DropdownMenuItem<DateTime?>(
                        value: month,
                        child: Text(Formatters.monthYear.format(month)),
                      ),
                  ],
                ),
              ),
            ),
          ),
        );

        if (isNarrow) {
          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [header, const SizedBox(height: 16), dropdown],
          );
        }

        return Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(child: header),
            const SizedBox(width: 24),
            dropdown,
          ],
        );
      },
    );
  }
}

class _SectionTitle extends StatelessWidget {
  const _SectionTitle({required this.title, this.subtitle});

  final String title;
  final String? subtitle;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: theme.textTheme.titleMedium?.copyWith(
            fontWeight: FontWeight.w700,
            color: const Color(0xFF1F2937),
            fontSize: 18,
          ),
        ),
        if (subtitle != null)
          Padding(
            padding: const EdgeInsets.only(top: 4),
            child: Text(
              subtitle!,
              style: theme.textTheme.bodySmall?.copyWith(
                color: const Color(0xFF6B7280),
              ),
            ),
          ),
      ],
    );
  }
}

class _ExpensePieChart extends StatelessWidget {
  const _ExpensePieChart({required this.totals, required this.total});

  final List<CategoryTotal> totals;
  final double total;

  @override
  Widget build(BuildContext context) {
    final sections = totals
        .asMap()
        .entries
        .map(
          (entry) => PieChartSectionData(
            value: entry.value.total,
            color: entry.value.color,
            radius: 60,
            title: '${((entry.value.total / total) * 100).toStringAsFixed(1)}%',
            titleStyle: Theme.of(context).textTheme.labelMedium?.copyWith(
              color: Colors.white,
              fontWeight: FontWeight.bold,
            ),
          ),
        )
        .toList();

    return LayoutBuilder(
      builder: (context, constraints) {
        final size = constraints.maxWidth;
        final chartHeight = size < 360 ? 200.0 : 220.0;

        return Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(24),
            color: Colors.white,
            boxShadow: const [
              BoxShadow(
                color: Color(0x11000000),
                offset: Offset(0, 10),
                blurRadius: 24,
              ),
            ],
          ),
          child: Column(
            children: [
              SizedBox(
                height: chartHeight,
                child: PieChart(
                  PieChartData(
                    sections: sections,
                    centerSpaceRadius: chartHeight / 4,
                    sectionsSpace: 2,
                  ),
                ),
              ),
              const SizedBox(height: 20),
              Wrap(
                spacing: 12,
                runSpacing: 10,
                alignment: WrapAlignment.center,
                children: [
                  for (final item in totals)
                    _LegendChip(
                      color: item.color,
                      label: item.label,
                      value: Formatters.currency.format(item.total),
                    ),
                ],
              ),
            ],
          ),
        );
      },
    );
  }
}

class _MonthlyBarChart extends StatelessWidget {
  const _MonthlyBarChart({required this.totals});

  final List<MonthlyTotals> totals;

  @override
  Widget build(BuildContext context) {
    final barGroups = totals
        .asMap()
        .entries
        .map(
          (entry) => BarChartGroupData(
            x: entry.key,
            barsSpace: 6,
            barRods: [
              BarChartRodData(
                toY: entry.value.income,
                color: const Color(0xFF22C55E),
                width: 14,
                borderRadius: BorderRadius.circular(6),
              ),
              BarChartRodData(
                toY: entry.value.expenses,
                color: const Color(0xFFEF4444),
                width: 14,
                borderRadius: BorderRadius.circular(6),
              ),
            ],
          ),
        )
        .toList();

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(24),
        color: Colors.white,
        boxShadow: const [
          BoxShadow(
            color: Color(0x11000000),
            offset: Offset(0, 10),
            blurRadius: 24,
          ),
        ],
      ),
      child: Column(
        children: [
          SizedBox(
            height: 220,
            child: BarChart(
              BarChartData(
                alignment: BarChartAlignment.spaceAround,
                barGroups: barGroups,
                gridData: FlGridData(
                  show: true,
                  horizontalInterval: 1000,
                  getDrawingHorizontalLine: (value) =>
                      FlLine(color: const Color(0xFFE5E7EB), strokeWidth: 1),
                ),
                borderData: FlBorderData(show: false),
                titlesData: FlTitlesData(
                  leftTitles: AxisTitles(
                    sideTitles: SideTitles(
                      showTitles: true,
                      reservedSize: 54,
                      getTitlesWidget: (value, meta) => Padding(
                        padding: const EdgeInsets.only(right: 8),
                        child: Text(
                          Formatters.currency.format(value),
                          style: const TextStyle(
                            color: Color(0xFF6B7280),
                            fontSize: 11,
                          ),
                        ),
                      ),
                    ),
                  ),
                  rightTitles: AxisTitles(
                    sideTitles: SideTitles(showTitles: false),
                  ),
                  topTitles: AxisTitles(
                    sideTitles: SideTitles(showTitles: false),
                  ),
                  bottomTitles: AxisTitles(
                    sideTitles: SideTitles(
                      showTitles: true,
                      getTitlesWidget: (value, meta) {
                        final index = value.toInt();
                        if (index < 0 || index >= totals.length) {
                          return const SizedBox();
                        }
                        final label = Formatters.monthYear.format(
                          totals[index].month,
                        );
                        return Padding(
                          padding: const EdgeInsets.only(top: 8),
                          child: Text(
                            label,
                            style: const TextStyle(
                              color: Color(0xFF6B7280),
                              fontSize: 11,
                            ),
                          ),
                        );
                      },
                    ),
                  ),
                ),
              ),
            ),
          ),
          const SizedBox(height: 16),
          const Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              _LegendChip(color: Color(0xFF22C55E), label: 'Income'),
              SizedBox(width: 12),
              _LegendChip(color: Color(0xFFEF4444), label: 'Expenses'),
            ],
          ),
        ],
      ),
    );
  }
}

class _InsightChips extends StatelessWidget {
  const _InsightChips({
    required this.totalIncome,
    required this.totalExpenses,
    required this.balance,
    required this.topCategory,
  });

  final double totalIncome;
  final double totalExpenses;
  final double balance;
  final CategoryTotal? topCategory;

  @override
  Widget build(BuildContext context) {
    final chips = <Widget>[
      _InsightChip(
        icon: Icons.savings_outlined,
        label: 'Current balance',
        value: Formatters.currency.format(balance),
      ),
      _InsightChip(
        icon: Icons.arrow_downward,
        label: 'Total income',
        value: Formatters.currency.format(totalIncome),
      ),
      _InsightChip(
        icon: Icons.arrow_upward,
        label: 'Total expenses',
        value: Formatters.currency.format(totalExpenses),
      ),
    ];

    if (topCategory != null) {
      chips.add(
        _InsightChip(
          icon: Icons.local_fire_department_outlined,
          label: 'Top spending category',
          value:
              '${topCategory!.label} · ${Formatters.currency.format(topCategory!.total)}',
        ),
      );
    }

    return Wrap(spacing: 12, runSpacing: 12, children: chips);
  }
}

class _InsightChip extends StatelessWidget {
  const _InsightChip({
    required this.icon,
    required this.label,
    required this.value,
  });

  final IconData icon;
  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(18),
        color: Colors.white,
        boxShadow: const [
          BoxShadow(
            color: Color(0x0F000000),
            offset: Offset(0, 8),
            blurRadius: 18,
          ),
        ],
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          CircleAvatar(
            radius: 16,
            backgroundColor: const Color(0xFFEFF6FF),
            child: Icon(icon, size: 18, color: const Color(0xFF2563EB)),
          ),
          const SizedBox(width: 12),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: const TextStyle(
                  color: Color(0xFF6B7280),
                  fontSize: 12,
                  fontWeight: FontWeight.w500,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                value,
                style: const TextStyle(
                  color: Color(0xFF1F2937),
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _LegendChip extends StatelessWidget {
  const _LegendChip({required this.color, required this.label, this.value});

  final Color color;
  final String label;
  final String? value;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16),
        color: Colors.white,
        border: Border.all(color: const Color(0xFFE5E7EB)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          CircleAvatar(radius: 6, backgroundColor: color),
          const SizedBox(width: 8),
          Text(
            label,
            style: const TextStyle(
              color: Color(0xFF4B5563),
              fontWeight: FontWeight.w500,
            ),
          ),
          if (value != null) ...[
            const SizedBox(width: 6),
            Text(
              value!,
              style: const TextStyle(
                color: Color(0xFF1F2937),
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ],
      ),
    );
  }
}

class _EmptyInsight extends StatelessWidget {
  const _EmptyInsight({required this.icon, required this.message});

  final IconData icon;
  final String message;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(28),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(24),
        color: Colors.white,
        boxShadow: const [
          BoxShadow(
            color: Color(0x11000000),
            offset: Offset(0, 12),
            blurRadius: 24,
          ),
        ],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 44, color: const Color(0xFF9CA3AF)),
          const SizedBox(height: 16),
          Text(
            message,
            textAlign: TextAlign.center,
            style: const TextStyle(color: Color(0xFF6B7280)),
          ),
        ],
      ),
    );
  }
}
