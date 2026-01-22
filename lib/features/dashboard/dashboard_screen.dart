import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../data/models/transaction_type.dart';
import '../../data/providers/finance_provider.dart';
import '../../utils/formatters.dart';
import '../../widgets/walletlly_brand_banner.dart';
import '../transactions/transactions_screen.dart';
import '../transactions/widgets/transaction_editor_sheet.dart';
import 'widgets/balance_card.dart';
import 'widgets/summary_tiles.dart';
import '../../theme/walletlly_palette.dart';

class DashboardScreen extends StatelessWidget {
  const DashboardScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final finance = context.watch<FinanceProvider>();
    final recent = finance.recentTransactions();
    final months = finance.monthsWithTransactions;

    final theme = Theme.of(context);
    return SafeArea(
      top: true,
      bottom: false,
      minimum: const EdgeInsets.only(top: 12),
      child: CustomScrollView(
        slivers: [
          SliverPadding(
            padding: const EdgeInsets.fromLTRB(20, 16, 20, 0),
            sliver: SliverList(
              delegate: SliverChildListDelegate([
                const WalletllyBrandBanner(),
                const SizedBox(height: 16),
                const _DashboardHeader(),
                const SizedBox(height: 8),
                BalanceCard(
                  balance: finance.currentBalance,
                  income: finance.totalIncome,
                  expenses: finance.totalExpenses,
                  onAdd: () => TransactionEditorSheet.show(context),
                ),
                const SizedBox(height: 6),
                SummaryTiles(
                  totalIncome: finance.totalIncome,
                  totalExpenses: finance.totalExpenses,
                ),
                const SizedBox(height: 24),
                if (months.isNotEmpty) ...[
                  _SectionHeader(
                    title: 'Monthly Snapshot',
                    trailing: Text(
                      'Updated ${Formatters.monthYear.format(months.first)}',
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: const Color(0xFF6B7280),
                      ),
                    ),
                  ),
                  const SizedBox(height: 12),
                  _MonthHighlights(month: months.first),
                  const SizedBox(height: 24),
                ],
                _SectionHeader(
                  title: 'Recent Transactions',
                  trailing: TextButton(
                    onPressed: () {
                      Navigator.of(context).push(
                        MaterialPageRoute(
                          builder: (_) =>
                              const TransactionsScreen(showBackButton: true),
                        ),
                      );
                    },
                    child: const Text('View All'),
                  ),
                ),
                const SizedBox(height: 12),
                if (recent.isEmpty)
                  _EmptyState(
                    icon: Icons.receipt_long,
                    message:
                        'No transactions yet. Use the Quick Add button below to create your first entry.',
                  )
                else
                  ListView.separated(
                    physics: const NeverScrollableScrollPhysics(),
                    shrinkWrap: true,
                    itemCount: recent.length,
                    separatorBuilder: (_, __) => const SizedBox(height: 12),
                    itemBuilder: (context, index) {
                      final transaction = recent[index];
                      final category = finance.categoryById(
                        transaction.categoryId,
                      );
                      final isIncome = transaction.type.isIncome;
                      return _TransactionTile(
                        title: category?.name ?? 'Unknown',
                        subtitle: Formatters.fullDate.format(transaction.date),
                        amount: transaction.amount,
                        isIncome: isIncome,
                        color: category?.color ?? theme.colorScheme.primary,
                        onTap: () {
                          TransactionEditorSheet.show(
                            context,
                            initial: transaction,
                          );
                        },
                      );
                    },
                  ),
                const SizedBox(height: 40),
              ]),
            ),
          ),
        ],
      ),
    );
  }
}

class _DashboardHeader extends StatelessWidget {
  const _DashboardHeader();

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Row(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Text(
          'Overview',
          style: theme.textTheme.titleLarge?.copyWith(
            fontWeight: FontWeight.w700,
            color: const Color(0xFF1F2937),
          ),
        ),
      ],
    );
  }
}

class _SectionHeader extends StatelessWidget {
  const _SectionHeader({required this.title, this.trailing});

  final String title;
  final Widget? trailing;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(18),
        color: const Color(0xFFF3F4F6),
      ),
      child: Row(
        children: [
          Text(
            title,
            style: theme.textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.w600,
              fontSize: 18,
            ),
          ),
          const Spacer(),
          if (trailing != null) trailing!,
        ],
      ),
    );
  }
}

class _TransactionTile extends StatelessWidget {
  const _TransactionTile({
    required this.title,
    required this.subtitle,
    required this.amount,
    required this.isIncome,
    required this.color,
    required this.onTap,
  });

  final String title;
  final String subtitle;
  final double amount;
  final bool isIncome;
  final Color color;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final amountColor = isIncome
        ? WalletllyPalette.of(context).primaryBase
        : Theme.of(context).colorScheme.error;
    final sign = isIncome ? '+' : '-';
    return InkWell(
      borderRadius: BorderRadius.circular(20),
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(20),
          boxShadow: const [
            BoxShadow(
              color: Color(0x1A1F2937),
              offset: Offset(0, 6),
              blurRadius: 16,
            ),
          ],
        ),
        child: Row(
          children: [
            CircleAvatar(
              radius: 18,
              backgroundColor: color,
              child: Icon(
                isIncome ? Icons.arrow_downward : Icons.arrow_upward,
                color: Colors.white,
                size: 18,
              ),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: theme.textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.w600,
                      color: const Color(0xFF1F2937),
                      fontSize: 16,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    subtitle,
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: const Color(0xFF6B7280),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(width: 14),
            Text(
              '$sign${Formatters.currency.format(amount.abs())}',
              style: theme.textTheme.titleMedium?.copyWith(
                color: amountColor,
                fontWeight: FontWeight.w700,
                fontSize: 17,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _EmptyState extends StatelessWidget {
  const _EmptyState({required this.icon, required this.message});

  final IconData icon;
  final String message;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 32),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(24),
        color: Colors.white,
        boxShadow: const [
          BoxShadow(
            color: Color(0x111F2937),
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
            style: theme.textTheme.bodyMedium?.copyWith(
              color: const Color(0xFF6B7280),
            ),
          ),
        ],
      ),
    );
  }
}

class _MonthHighlights extends StatelessWidget {
  const _MonthHighlights({required this.month});

  final DateTime month;

  @override
  Widget build(BuildContext context) {
    final finance = context.watch<FinanceProvider>();
    final theme = Theme.of(context);
    final palette = WalletllyPalette.of(context);
    final income = finance.incomeForMonth(month);
    final expenses = finance.expensesForMonth(month);
    final balance = income - expenses;

    final balancePositive = balance >= 0;

    return Container(
      padding: const EdgeInsets.fromLTRB(16, 18, 16, 18),
      decoration: BoxDecoration(
        color: theme.colorScheme.surface,
        borderRadius: BorderRadius.circular(22),
        boxShadow: const [
          BoxShadow(
            color: Color(0x141F2937),
            offset: Offset(0, 10),
            blurRadius: 20,
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    Formatters.monthYear.format(month),
                    style: theme.textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'Income and expenses',
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: const Color(0xFF6B7280),
                    ),
                  ),
                ],
              ),
              const Spacer(),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 14,
                  vertical: 6,
                ),
                decoration: BoxDecoration(
                  color: balancePositive
                      ? palette.primaryLight
                      : theme.colorScheme.error.withOpacity(0.12),
                  borderRadius: BorderRadius.circular(18),
                ),
                child: Text(
                  balancePositive ? 'Surplus' : 'Deficit',
                  style: theme.textTheme.labelLarge?.copyWith(
                    color: balancePositive
                        ? palette.primaryBase
                        : theme.colorScheme.error,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 18),
          Container(
            width: double.infinity,
            padding: const EdgeInsets.fromLTRB(18, 20, 18, 20),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [palette.primaryBase, palette.primaryDark],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.circular(20),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Balance',
                  style: theme.textTheme.labelLarge?.copyWith(
                    color: Colors.white.withOpacity(0.8),
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  Formatters.currency.format(balance),
                  style: theme.textTheme.headlineSmall?.copyWith(
                    color: Colors.white,
                    fontSize: 26,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  balancePositive
                      ? 'Great! You saved this month.'
                      : 'Spending exceeded income.',
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: Colors.white.withOpacity(0.82),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 14),
          Row(
            children: [
              Expanded(
                child: _SnapshotStatCard(
                  label: 'Income',
                  amount: income,
                  color: palette.primaryBase,
                  icon: Icons.south_west,
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: _SnapshotStatCard(
                  label: 'Expenses',
                  amount: expenses,
                  color: theme.colorScheme.error,
                  icon: Icons.north_east,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _SnapshotStatCard extends StatelessWidget {
  const _SnapshotStatCard({
    required this.label,
    required this.amount,
    required this.color,
    required this.icon,
  });

  final String label;
  final double amount;
  final Color color;
  final IconData icon;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      decoration: BoxDecoration(
        color: const Color(0xFFF7F8FB),
        borderRadius: BorderRadius.circular(18),
      ),
      child: Row(
        children: [
          Container(
            height: 32,
            width: 32,
            decoration: BoxDecoration(
              color: color.withOpacity(0.12),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(icon, color: color, size: 18),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: theme.textTheme.labelMedium?.copyWith(
                    color: const Color(0xFF6B7280),
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  Formatters.currency.format(amount),
                  style: theme.textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w700,
                    color: color,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
