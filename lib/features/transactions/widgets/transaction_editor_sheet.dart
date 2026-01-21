import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

import '../../../data/models/transaction.dart';
import '../../../data/models/transaction_type.dart';
import '../../../data/providers/finance_provider.dart';

class TransactionEditorSheet extends StatefulWidget {
  const TransactionEditorSheet({super.key, this.initial});

  final TransactionEntry? initial;

  static Future<void> show(BuildContext context, {TransactionEntry? initial}) {
    return showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(32)),
      ),
      builder: (_) => Padding(
        padding: EdgeInsets.only(
          bottom: MediaQuery.of(context).viewInsets.bottom + 24,
        ),
        child: TransactionEditorSheet(initial: initial),
      ),
    );
  }

  @override
  State<TransactionEditorSheet> createState() => _TransactionEditorSheetState();
}

class _TransactionEditorSheetState extends State<TransactionEditorSheet> {
  late TransactionType _type;
  late DateTime _selectedDate;
  String? _categoryId;
  final _formKey = GlobalKey<FormState>();
  final _amountController = TextEditingController();
  final _notesController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _type = widget.initial?.type ?? TransactionType.expense;
    _selectedDate = widget.initial?.date ?? DateTime.now();
    _categoryId = widget.initial?.categoryId;
    if (widget.initial != null) {
      _amountController.text = widget.initial!.amount.toStringAsFixed(2);
      _notesController.text = widget.initial!.notes ?? '';
    }
  }

  @override
  void dispose() {
    _amountController.dispose();
    _notesController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<FinanceProvider>();
    final categories = provider.categoriesForType(_type);
    final theme = Theme.of(context);
    final isEditing = widget.initial != null;

    return Form(
      key: _formKey,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 24),
            Row(
              children: [
                Text(
                  isEditing ? 'Edit Transaction' : 'Add Transaction',
                  style: theme.textTheme.headlineSmall,
                ),
                const Spacer(),
                IconButton(
                  icon: const Icon(Icons.close),
                  onPressed: () => Navigator.of(context).pop(),
                ),
              ],
            ),
            const SizedBox(height: 16),
            ToggleButtons(
              isSelected: [
                _type == TransactionType.income,
                _type == TransactionType.expense,
              ],
              borderRadius: BorderRadius.circular(16),
              constraints: const BoxConstraints(minHeight: 42, minWidth: 120),
              onPressed: (index) {
                setState(() {
                  _type = index == 0
                      ? TransactionType.income
                      : TransactionType.expense;
                  final typeCategories = provider
                      .categoriesForType(_type)
                      .map((c) => c.id);
                  if (!typeCategories.contains(_categoryId)) {
                    _categoryId = null;
                  }
                });
              },
              children: const [
                Padding(
                  padding: EdgeInsets.symmetric(horizontal: 12),
                  child: Text('Income'),
                ),
                Padding(
                  padding: EdgeInsets.symmetric(horizontal: 12),
                  child: Text('Expense'),
                ),
              ],
            ),
            const SizedBox(height: 20),
            TextFormField(
              controller: _amountController,
              keyboardType: const TextInputType.numberWithOptions(
                decimal: true,
              ),
              decoration: const InputDecoration(
                labelText: 'Amount',
                prefixText: '₱ ',
              ),
              validator: (value) {
                if (value == null || value.trim().isEmpty) {
                  return 'Enter an amount';
                }
                final parsed = double.tryParse(value.replaceAll(',', ''));
                if (parsed == null || parsed <= 0) {
                  return 'Enter a valid positive amount';
                }
                return null;
              },
            ),
            const SizedBox(height: 16),
            DropdownButtonFormField<String>(
              initialValue: _categoryId,
              items: categories
                  .map(
                    (category) => DropdownMenuItem(
                      value: category.id,
                      child: Row(
                        children: [
                          CircleAvatar(
                            radius: 8,
                            backgroundColor: category.color,
                          ),
                          const SizedBox(width: 12),
                          Text(category.name),
                        ],
                      ),
                    ),
                  )
                  .toList(),
              decoration: const InputDecoration(labelText: 'Category'),
              onChanged: (value) => setState(() => _categoryId = value),
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Select a category';
                }
                return null;
              },
            ),
            const SizedBox(height: 16),
            InkWell(
              borderRadius: BorderRadius.circular(16),
              onTap: () async {
                final picked = await showDatePicker(
                  context: context,
                  initialDate: _selectedDate,
                  firstDate: DateTime(2010),
                  lastDate: DateTime(2100),
                );
                if (picked != null) {
                  setState(() => _selectedDate = picked);
                }
              },
              child: Container(
                width: double.infinity,
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 18,
                ),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(16),
                  color: theme.inputDecorationTheme.fillColor,
                ),
                child: Row(
                  children: [
                    const Icon(Icons.event),
                    const SizedBox(width: 12),
                    Text(DateFormat.yMMMMd().format(_selectedDate)),
                    const Spacer(),
                    const Icon(Icons.chevron_right),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: _notesController,
              decoration: const InputDecoration(labelText: 'Notes (optional)'),
              maxLines: 3,
            ),
            const SizedBox(height: 24),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () => _submit(provider),
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 16),
                ),
                child: Text(isEditing ? 'Save Changes' : 'Add Transaction'),
              ),
            ),
            const SizedBox(height: 24),
          ],
        ),
      ),
    );
  }

  Future<void> _submit(FinanceProvider provider) async {
    if (!_formKey.currentState!.validate()) return;
    final amount = double.parse(_amountController.text.replaceAll(',', ''));
    final categoryId = _categoryId!;
    final isEditing = widget.initial != null;

    if (isEditing) {
      final updated = widget.initial!.copyWith(
        type: _type,
        amount: amount,
        categoryId: categoryId,
        date: _selectedDate,
        notes: _notesController.text.trim().isEmpty
            ? null
            : _notesController.text.trim(),
      );
      await provider.updateTransaction(updated);
    } else {
      await provider.addTransaction(
        type: _type,
        amount: amount,
        categoryId: categoryId,
        date: _selectedDate,
        notes: _notesController.text.trim().isEmpty
            ? null
            : _notesController.text.trim(),
      );
    }

    if (mounted) Navigator.of(context).pop();
  }
}
