import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

import '../../data/models/transaction.dart';
import '../../data/models/transaction_type.dart';
import '../../data/providers/finance_provider.dart';
import '../../utils/formatters.dart';
import 'widgets/transaction_editor_sheet.dart';
import '../../theme/walletlly_palette.dart';
import '../../widgets/walletlly_brand_banner.dart';

class TransactionsScreen extends StatefulWidget {
  const TransactionsScreen({super.key});

  @override
  State<TransactionsScreen> createState() => _TransactionsScreenState();
}

class _TransactionsScreenState extends State<TransactionsScreen>
    with SingleTickerProviderStateMixin {
  TransactionType? _filterType;
  DateTime? _filterMonth;
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final finance = context.watch<FinanceProvider>();
    final transactions = _filteredTransactions(finance.transactions);

    final theme = Theme.of(context);
    final palette = WalletllyPalette.of(context);
    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      appBar: PreferredSize(
        preferredSize: const Size.fromHeight(200),
        child: SafeArea(
          bottom: false,
          child: Padding(
            padding: const EdgeInsets.fromLTRB(20, 18, 20, 14),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                WalletllyBrandBanner(
                  compact: true,
                  trailing: IconButton(
                    onPressed: () => _openFilterSheet(context, finance),
                    icon: const Icon(Icons.tune),
                    color: Colors.white,
                    tooltip: 'Filters',
                  ),
                ),
                const SizedBox(height: 16),
                Container(
                  decoration: BoxDecoration(
                    color: palette.primaryLight,
                    borderRadius: BorderRadius.circular(24),
                  ),
                  padding: const EdgeInsets.all(4),
                  child: TabBar(
                    controller: _tabController,
                    labelColor: palette.primaryBase,
                    unselectedLabelColor: palette.primaryDark.withOpacity(0.65),
                    labelStyle: theme.textTheme.bodyMedium?.copyWith(
                      fontWeight: FontWeight.w600,
                    ),
                    indicator: BoxDecoration(
                      color: theme.colorScheme.surface,
                      borderRadius: BorderRadius.circular(20),
                    ),
                    indicatorSize: TabBarIndicatorSize.tab,
                    indicatorPadding: EdgeInsets.zero,
                    tabs: const [
                      Tab(text: 'List View'),
                      Tab(text: 'Insights'),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
      body: SafeArea(
        top: false,
        child: TabBarView(
          controller: _tabController,
          children: [
            _TransactionsList(
              transactions: transactions,
              onEdit: (entry) =>
                  TransactionEditorSheet.show(context, initial: entry),
            ),
            _TransactionsSummary(
              totalIncome: finance.totalIncome,
              totalExpenses: finance.totalExpenses,
              balance: finance.currentBalance,
              month: _filterMonth,
            ),
          ],
        ),
      ),
    );
  }

  List<TransactionEntry> _filteredTransactions(
    List<TransactionEntry> transactions,
  ) {
    Iterable<TransactionEntry> filtered = transactions;

    if (_filterType != null) {
      filtered = filtered.where((t) => t.type == _filterType);
    }

    if (_filterMonth != null) {
      filtered = filtered.where(
        (t) =>
            t.date.year == _filterMonth!.year &&
            t.date.month == _filterMonth!.month,
      );
    }

    return filtered.toList();
  }

  void _openFilterSheet(BuildContext context, FinanceProvider finance) {
    showModalBottomSheet<void>(
      context: context,
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(32)),
      ),
      builder: (context) {
        final months = finance.monthsWithTransactions;
        return Padding(
          padding: EdgeInsets.fromLTRB(
            24,
            24,
            24,
            MediaQuery.of(context).viewInsets.bottom + 24,
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Text(
                    'Filters',
                    style: Theme.of(context).textTheme.titleLarge,
                  ),
                  const Spacer(),
                  IconButton(
                    onPressed: () => Navigator.of(context).pop(),
                    icon: const Icon(Icons.close),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              Text('Type', style: Theme.of(context).textTheme.titleSmall),
              const SizedBox(height: 12),
              Wrap(
                spacing: 12,
                children: [
                  FilterChip(
                    label: const Text('All'),
                    selected: _filterType == null,
                    onSelected: (_) => setState(() => _filterType = null),
                  ),
                  FilterChip(
                    label: const Text('Income'),
                    selected: _filterType == TransactionType.income,
                    onSelected: (_) =>
                        setState(() => _filterType = TransactionType.income),
                  ),
                  FilterChip(
                    label: const Text('Expense'),
                    selected: _filterType == TransactionType.expense,
                    onSelected: (_) =>
                        setState(() => _filterType = TransactionType.expense),
                  ),
                ],
              ),
              const SizedBox(height: 24),
              Text('Month', style: Theme.of(context).textTheme.titleSmall),
              const SizedBox(height: 12),
              if (months.isEmpty)
                const Text(
                  'No months available yet',
                  style: TextStyle(color: Colors.white54),
                )
              else
                Wrap(
                  spacing: 12,
                  children: [
                    FilterChip(
                      label: const Text('All'),
                      selected: _filterMonth == null,
                      onSelected: (_) => setState(() => _filterMonth = null),
                    ),
                    for (final month in months)
                      FilterChip(
                        label: Text(Formatters.monthYear.format(month)),
                        selected: _filterMonth == month,
                        onSelected: (_) => setState(() => _filterMonth = month),
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

enum _TransactionAction { edit, delete }

class _TransactionsList extends StatelessWidget {
  const _TransactionsList({required this.transactions, required this.onEdit});

  final List<TransactionEntry> transactions;
  final ValueChanged<TransactionEntry> onEdit;

  @override
  Widget build(BuildContext context) {
    if (transactions.isEmpty) {
      return const _EmptyState(
        icon: Icons.receipt_long,
        message: 'No transactions match the current filters.',
      );
    }

    final theme = Theme.of(context);
    return ListView.separated(
      padding: const EdgeInsets.fromLTRB(24, 24, 24, 120),
      itemBuilder: (context, index) {
        final entry = transactions[index];
        final category = context.read<FinanceProvider>().categoryById(
          entry.categoryId,
        );
        final palette = WalletllyPalette.of(context);
        final isIncome = entry.type == TransactionType.income;
        final sign = isIncome ? '+' : '-';
        return InkWell(
          borderRadius: BorderRadius.circular(20),
          onTap: () => onEdit(entry),
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 16),
            decoration: BoxDecoration(
              color: theme.colorScheme.surface,
              borderRadius: BorderRadius.circular(20),
              boxShadow: const [
                BoxShadow(
                  color: Color(0x11000000),
                  offset: Offset(0, 6),
                  blurRadius: 16,
                ),
              ],
            ),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                CircleAvatar(
                  radius: 20,
                  backgroundColor: category?.color ?? palette.primaryBase,
                  child: Icon(
                    isIncome ? Icons.arrow_downward : Icons.arrow_upward,
                    color: Colors.white,
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        category?.name ?? 'Uncategorized',
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: theme.textTheme.titleMedium?.copyWith(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                          color: const Color(0xFF1F2937),
                        ),
                      ),
                      const SizedBox(height: 6),
                      Text(
                        DateFormat.yMMMd().format(entry.date),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: theme.textTheme.bodySmall?.copyWith(
                          fontSize: 12,
                          color: const Color(0xFF6B7280),
                        ),
                      ),
                      if (entry.notes?.isNotEmpty ?? false) ...[
                        const SizedBox(height: 6),
                        Text(
                          entry.notes!,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: theme.textTheme.bodySmall?.copyWith(
                            fontSize: 12,
                            color: const Color(0xFF9CA3AF),
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
                const SizedBox(width: 16),
                Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    PopupMenuButton<_TransactionAction>(
                      tooltip: 'More actions',
                      icon: Icon(
                        Icons.more_vert,
                        color: palette.primaryDark.withOpacity(0.72),
                      ),
                      onSelected: (action) {
                        switch (action) {
                          case _TransactionAction.edit:
                            onEdit(entry);
                          case _TransactionAction.delete:
                            _confirmDelete(context, entry);
                        }
                      },
                      itemBuilder: (context) => const [
                        PopupMenuItem(
                          value: _TransactionAction.edit,
                          child: Row(
                            children: [
                              Icon(Icons.edit_outlined, size: 18),
                              SizedBox(width: 12),
                              Text('Edit'),
                            ],
                          ),
                        ),
                        PopupMenuItem(
                          value: _TransactionAction.delete,
                          child: Row(
                            children: [
                              Icon(Icons.delete_outline, size: 18),
                              SizedBox(width: 12),
                              Text('Delete'),
                            ],
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    Text(
                      '$sign${Formatters.currency.format(entry.amount.abs())}',
                      style: theme.textTheme.titleMedium?.copyWith(
                        fontSize: 18,
                        color: isIncome
                            ? palette.success
                            : theme.colorScheme.error,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        );
      },
      separatorBuilder: (_, __) => const SizedBox(height: 16),
      itemCount: transactions.length,
    );
  }
}

class _TransactionsSummary extends StatelessWidget {
  const _TransactionsSummary({
    required this.totalIncome,
    required this.totalExpenses,
    required this.balance,
    required this.month,
  });

  final double totalIncome;
  final double totalExpenses;
  final double balance;
  final DateTime? month;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final bottomInset = MediaQuery.of(context).padding.bottom;
    return SingleChildScrollView(
      padding: EdgeInsets.fromLTRB(24, 24, 24, 40 + bottomInset),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Text('Overview', style: theme.textTheme.titleLarge),
              const Spacer(),
              if (month != null)
                Chip(
                  label: Text(Formatters.monthYear.format(month!)),
                  backgroundColor: theme.colorScheme.primary.withValues(
                    alpha: 0.12,
                  ),
                ),
            ],
          ),
          const SizedBox(height: 24),
          _SummaryTile(
            label: 'Income',
            amount: totalIncome,
            color: WalletllyPalette.of(context).primaryBase,
          ),
          const SizedBox(height: 16),
          _SummaryTile(
            label: 'Expenses',
            amount: totalExpenses,
            color: theme.colorScheme.error,
          ),
          const SizedBox(height: 16),
          _SummaryTile(
            label: 'Balance',
            amount: balance,
            color: balance >= 0
                ? WalletllyPalette.of(context).accent
                : theme.colorScheme.error,
          ),
        ],
      ),
    );
  }
}

class _SummaryTile extends StatelessWidget {
  const _SummaryTile({
    required this.label,
    required this.amount,
    required this.color,
  });

  final String label;
  final double amount;
  final Color color;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(24),
        color: theme.colorScheme.surface,
        boxShadow: const [
          BoxShadow(
            color: Color(0x11000000),
            offset: Offset(0, 10),
            blurRadius: 22,
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(label, style: theme.textTheme.titleSmall),
          const SizedBox(height: 12),
          Text(
            Formatters.currency.format(amount),
            style: theme.textTheme.headlineSmall?.copyWith(
              color: color,
              fontSize: 22,
            ),
          ),
        ],
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
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 56, color: const Color(0xFF9CA3AF)),
          const SizedBox(height: 16),
          Text(
            message,
            style: theme.textTheme.bodyMedium?.copyWith(
              color: const Color(0xFF6B7280),
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 24),
          FilledButton.icon(
            onPressed: () => TransactionEditorSheet.show(context),
            icon: const Icon(Icons.add),
            label: const Text('Add Transaction'),
          ),
        ],
      ),
    );
  }
}

Future<void> _confirmDelete(
  BuildContext context,
  TransactionEntry entry,
) async {
  final provider = context.read<FinanceProvider>();
  final confirmed = await showDialog<bool>(
    context: context,
    builder: (dialogContext) {
      final theme = Theme.of(dialogContext);
      return AlertDialog(
        backgroundColor: Colors.white,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: const Text('Delete Transaction'),
        content: Text(
          'Are you sure you want to delete this transaction?',
          style: theme.textTheme.bodyMedium,
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(dialogContext).pop(false),
            child: const Text('Cancel'),
          ),
          FilledButton(
            onPressed: () => Navigator.of(dialogContext).pop(true),
            style: FilledButton.styleFrom(
              backgroundColor: theme.colorScheme.error,
              foregroundColor: Colors.white,
            ),
            child: const Text('Delete'),
          ),
        ],
      );
    },
  );

  if (confirmed == true) {
    await provider.deleteTransaction(entry);
  }
}
