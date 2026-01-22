import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../data/models/category.dart';
import '../../../data/models/transaction_type.dart';
import '../../../data/providers/finance_provider.dart';
import '../../../theme/walletlly_palette.dart';

class CategoryEditorSheet extends StatefulWidget {
  const CategoryEditorSheet({super.key, this.initial});

  final Category? initial;

  static Future<void> show(BuildContext context, {Category? initial}) {
    return showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(32)),
      ),
      builder: (_) => CategoryEditorSheet(initial: initial),
    );
  }

  @override
  State<CategoryEditorSheet> createState() => _CategoryEditorSheetState();
}

class _CategoryEditorSheetState extends State<CategoryEditorSheet> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  late TransactionType _type;
  late Color _color;

  static const _colors = [
    Color(0xFF6C5CE7),
    Color(0xFF00B894),
    Color(0xFFFF7675),
    Color(0xFFFFA62B),
    Color(0xFF0984E3),
    Color(0xFF6D8299),
    Color(0xFFFDCB6E),
    Color(0xFF00CEC9),
    Color(0xFFA29BFE),
    Color(0xFFD63031),
  ];

  @override
  void initState() {
    super.initState();
    _type = widget.initial?.transactionType ?? TransactionType.expense;
    _color = widget.initial?.color ?? _colors.first;
    _nameController.text = widget.initial?.name ?? '';
  }

  @override
  void dispose() {
    _nameController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
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
            data: theme.copyWith(inputDecorationTheme: inputDecoration),
            child: Form(
              key: _formKey,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
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
                        isEditing ? 'Edit Category' : 'New Category',
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
                        icon: Icon(Icons.arrow_downward_rounded, size: 16),
                      ),
                      ButtonSegment(
                        value: TransactionType.expense,
                        label: Text('Expense'),
                        icon: Icon(Icons.arrow_upward_rounded, size: 16),
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
                    onSelectionChanged: (selection) =>
                        setState(() => _type = selection.first),
                  ),
                  const SizedBox(height: 24),
                  TextFormField(
                    controller: _nameController,
                    decoration: const InputDecoration(labelText: 'Name'),
                    validator: (value) {
                      if (value == null || value.trim().isEmpty) {
                        return 'Enter a category name';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 22),
                  Text(
                    'Color',
                    style: theme.textTheme.labelLarge?.copyWith(
                      fontWeight: FontWeight.w600,
                      color: palette.primaryDark.withOpacity(0.72),
                    ),
                  ),
                  const SizedBox(height: 12),
                  Wrap(
                    spacing: 12,
                    runSpacing: 12,
                    children: [
                      for (final color in _colors)
                        _ColorChip(
                          color: color,
                          selected: _color == color,
                          onTap: () => setState(() => _color = color),
                        ),
                    ],
                  ),
                  const SizedBox(height: 28),
                  FilledButton.icon(
                    onPressed: () => _submit(context),
                    icon: Icon(isEditing ? Icons.save_rounded : Icons.add),
                    label: Text(isEditing ? 'Save Changes' : 'Create Category'),
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

  Future<void> _submit(BuildContext context) async {
    if (!_formKey.currentState!.validate()) return;
    final provider = context.read<FinanceProvider>();
    final name = _nameController.text.trim();
    if (widget.initial != null) {
      final updated = widget.initial!.copyWith(
        name: name,
        transactionType: _type,
        color: _color,
      );
      await provider.updateCategory(updated);
    } else {
      await provider.addCategory(name: name, type: _type, color: _color);
    }
    if (mounted) Navigator.of(context).pop();
  }
}

class _ColorChip extends StatelessWidget {
  const _ColorChip({
    required this.color,
    required this.selected,
    required this.onTap,
  });

  final Color color;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final palette = WalletllyPalette.of(context);
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 220),
        padding: const EdgeInsets.all(3.5),
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          border: Border.all(
            color: selected ? palette.primaryBase : Colors.transparent,
            width: 3,
          ),
          boxShadow: selected
              ? [
                  BoxShadow(
                    color: palette.primaryBase.withOpacity(0.25),
                    blurRadius: 12,
                    spreadRadius: 1,
                  ),
                ]
              : null,
        ),
        child: CircleAvatar(radius: 18, backgroundColor: color),
      ),
    );
  }
}
