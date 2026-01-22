import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

import '../../../data/models/transaction.dart';
import '../../../data/models/transaction_type.dart';
import '../../../data/providers/finance_provider.dart';
import '../../../theme/walletlly_palette.dart';

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
      builder: (_) => TransactionEditorSheet(initial: initial),
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
    final palette = WalletllyPalette.of(context);
    final isEditing = widget.initial != null;
    final bottomInset = MediaQuery.of(context).viewInsets.bottom;
    final inputDecoration = theme.inputDecorationTheme.copyWith(
      filled: true,
      fillColor: theme.colorScheme.surface,
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(18),
        borderSide: BorderSide(color: palette.primaryLight.withOpacity(0.4)),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(18),
        borderSide: BorderSide(color: palette.primaryLight.withOpacity(0.4)),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(18),
        borderSide: BorderSide(color: palette.primaryBase),
      ),
      contentPadding: const EdgeInsets.symmetric(horizontal: 18, vertical: 16),
      labelStyle: theme.textTheme.labelLarge?.copyWith(
        color: palette.primaryDark.withOpacity(0.72),
      ),
    );

    return AnimatedPadding(
      duration: const Duration(milliseconds: 220),
      curve: Curves.easeOut,
      padding: EdgeInsets.only(bottom: bottomInset),
      child: SafeArea(
        top: false,
        child: SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(24, 24, 24, 32),
          child: Theme(
            data: theme.copyWith(
              inputDecorationTheme: inputDecoration,
              dropdownMenuTheme: theme.dropdownMenuTheme.copyWith(
                menuStyle: MenuStyle(
                  backgroundColor: MaterialStatePropertyAll(
                    theme.colorScheme.surface,
                  ),
                  shape: MaterialStatePropertyAll(
                    RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(18),
                    ),
                  ),
                ),
              ),
            ),
            child: Form(
              key: _formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Center(
                    child: Container(
                      width: 44,
                      height: 4,
                      margin: const EdgeInsets.only(bottom: 20),
                      decoration: BoxDecoration(
                        color: palette.primaryLight.withOpacity(0.9),
                        borderRadius: BorderRadius.circular(3),
                      ),
                    ),
                  ),
                  Row(
                    children: [
                      Text(
                        isEditing ? 'Edit Transaction' : 'Add Transaction',
                        style: theme.textTheme.titleLarge?.copyWith(
                          fontWeight: FontWeight.w700,
                          color: palette.primaryDark,
                        ),
                      ),
                      const Spacer(),
                      IconButton(
                        icon: const Icon(Icons.close),
                        tooltip: 'Close',
                        onPressed: () => Navigator.of(context).pop(),
                      ),
                    ],
                  ),
                  const SizedBox(height: 20),
                  SegmentedButton<TransactionType>(
                    segments: const [
                      ButtonSegment(
                        value: TransactionType.income,
                        label: Text('Income'),
                        icon: Icon(Icons.south_west_rounded, size: 16),
                      ),
                      ButtonSegment(
                        value: TransactionType.expense,
                        label: Text('Expense'),
                        icon: Icon(Icons.north_east_rounded, size: 16),
                      ),
                    ],
                    selected: {_type},
                    showSelectedIcon: false,
                    style: ButtonStyle(
                      shape: MaterialStateProperty.all(
                        RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(20),
                        ),
                      ),
                      side: MaterialStateProperty.resolveWith(
                        (states) => BorderSide(
                          color: states.contains(MaterialState.selected)
                              ? palette.primaryBase
                              : palette.primaryLight.withOpacity(0.7),
                        ),
                      ),
                      backgroundColor: MaterialStateProperty.resolveWith(
                        (states) => states.contains(MaterialState.selected)
                            ? palette.primaryBase
                            : palette.primaryLight,
                      ),
                      foregroundColor: MaterialStateProperty.resolveWith(
                        (states) => states.contains(MaterialState.selected)
                            ? Colors.white
                            : palette.primaryDark,
                      ),
                      padding: MaterialStateProperty.all(
                        const EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 12,
                        ),
                      ),
                    ),
                    onSelectionChanged: (selection) {
                      final nextType = selection.first;
                      setState(() {
                        _type = nextType;
                        final typeCategories = provider
                            .categoriesForType(_type)
                            .map((c) => c.id)
                            .toSet();
                        if (!typeCategories.contains(_categoryId)) {
                          _categoryId = null;
                        }
                      });
                    },
                  ),
                  const SizedBox(height: 24),
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
                  const SizedBox(height: 18),
                  DropdownButtonFormField<String>(
                    initialValue: _categoryId,
                    isExpanded: true,
                    items: categories
                        .map(
                          (category) => DropdownMenuItem(
                            value: category.id,
                            child: Row(
                              children: [
                                CircleAvatar(
                                  radius: 9,
                                  backgroundColor: category.color,
                                ),
                                const SizedBox(width: 12),
                                Expanded(
                                  child: Text(
                                    category.name,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                ),
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
                  const SizedBox(height: 18),
                  _DateField(
                    selectedDate: _selectedDate,
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
                  ),
                  const SizedBox(height: 18),
                  TextFormField(
                    controller: _notesController,
                    decoration: const InputDecoration(
                      labelText: 'Notes (optional)',
                    ),
                    maxLines: 3,
                  ),
                  const SizedBox(height: 28),
                  FilledButton.icon(
                    onPressed: () => _submit(provider),
                    icon: Icon(
                      isEditing ? Icons.save_alt_rounded : Icons.add_circle,
                    ),
                    label: Text(isEditing ? 'Save Changes' : 'Add Transaction'),
                    style: FilledButton.styleFrom(
                      minimumSize: const Size.fromHeight(52),
                      textStyle: theme.textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
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

class _DateField extends StatelessWidget {
  const _DateField({required this.selectedDate, required this.onTap});

  final DateTime selectedDate;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final palette = WalletllyPalette.of(context);
    final formatted = DateFormat.yMMMMd().format(selectedDate);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Date',
          style: theme.textTheme.labelLarge?.copyWith(
            color: palette.primaryDark.withOpacity(0.72),
            fontWeight: FontWeight.w600,
          ),
        ),
        const SizedBox(height: 10),
        InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(18),
          child: Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 16),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(18),
              color: theme.colorScheme.surface,
              border: Border.all(color: palette.primaryLight.withOpacity(0.4)),
            ),
            child: Row(
              children: [
                Icon(Icons.event_note, color: palette.primaryBase),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    formatted,
                    style: theme.textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.w600,
                      color: palette.primaryDark,
                    ),
                  ),
                ),
                const Icon(Icons.chevron_right),
              ],
            ),
          ),
        ),
      ],
    );
  }
}
