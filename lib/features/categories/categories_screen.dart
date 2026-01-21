import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../data/models/category.dart';
import '../../data/models/transaction_type.dart';
import '../../data/providers/finance_provider.dart';
import 'widgets/category_editor_sheet.dart';

class CategoriesScreen extends StatefulWidget {
  const CategoriesScreen({super.key});

  @override
  State<CategoriesScreen> createState() => _CategoriesScreenState();
}

class _CategoriesScreenState extends State<CategoriesScreen>
    with SingleTickerProviderStateMixin {
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
    final theme = Theme.of(context);
    final finance = context.watch<FinanceProvider>();
    final incomeCategories = finance.categoriesForType(TransactionType.income);
    final expenseCategories = finance.categoriesForType(
      TransactionType.expense,
    );

    return SafeArea(
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Categories'),
          bottom: TabBar(
            controller: _tabController,
            indicatorColor: theme.colorScheme.secondary,
            tabs: const [
              Tab(text: 'Income'),
              Tab(text: 'Expenses'),
            ],
          ),
          actions: [
            IconButton(
              icon: const Icon(Icons.add),
              tooltip: 'Add Category',
              onPressed: () => CategoryEditorSheet.show(context),
            ),
          ],
        ),
        body: TabBarView(
          controller: _tabController,
          children: [
            _CategoryList(
              categories: incomeCategories,
              emptyMessage:
                  'No income categories yet. Tap the + button to add one.',
            ),
            _CategoryList(
              categories: expenseCategories,
              emptyMessage:
                  'No expense categories yet. Tap the + button to add one.',
            ),
          ],
        ),
      ),
    );
  }
}

class _CategoryList extends StatelessWidget {
  const _CategoryList({required this.categories, required this.emptyMessage});

  final List<Category> categories;
  final String emptyMessage;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    if (categories.isEmpty) {
      return _EmptyState(message: emptyMessage);
    }

    return ListView.separated(
      padding: const EdgeInsets.fromLTRB(24, 24, 24, 36),
      itemCount: categories.length,
      separatorBuilder: (_, __) => const SizedBox(height: 16),
      itemBuilder: (context, index) {
        final category = categories[index];
        return Container(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(20),
            color: Colors.white.withValues(alpha: 0.05),
            border: Border.all(color: Colors.white10),
          ),
          child: Row(
            children: [
              CircleAvatar(backgroundColor: category.color, radius: 18),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(category.name, style: theme.textTheme.titleMedium),
                    const SizedBox(height: 4),
                    Text(
                      category.transactionType.label,
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: Colors.white60,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 12),
              IconButton(
                icon: const Icon(Icons.edit_outlined),
                tooltip: 'Edit',
                onPressed: () =>
                    CategoryEditorSheet.show(context, initial: category),
              ),
              if (category.isCustom)
                IconButton(
                  icon: const Icon(Icons.delete_outline),
                  tooltip: 'Delete',
                  onPressed: () => _confirmDelete(context, category),
                ),
            ],
          ),
        );
      },
    );
  }

  Future<void> _confirmDelete(BuildContext context, Category category) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) {
        return AlertDialog(
          backgroundColor: Theme.of(context).scaffoldBackgroundColor,
          title: const Text('Delete Category'),
          content: Text(
            'Are you sure you want to delete "${category.name}"? This will not delete existing transactions.',
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(false),
              child: const Text('Cancel'),
            ),
            FilledButton(
              onPressed: () => Navigator.of(context).pop(true),
              child: const Text('Delete'),
            ),
          ],
        );
      },
    );

    if (confirmed == true && context.mounted) {
      await context.read<FinanceProvider>().deleteCategory(category);
    }
  }
}

class _EmptyState extends StatelessWidget {
  const _EmptyState({required this.message});

  final String message;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(
              Icons.category_outlined,
              size: 48,
              color: Colors.white30,
            ),
            const SizedBox(height: 16),
            Text(
              message,
              style: theme.textTheme.bodyMedium?.copyWith(
                color: Colors.white70,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}
