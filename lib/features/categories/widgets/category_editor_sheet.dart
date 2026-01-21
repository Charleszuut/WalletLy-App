import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../data/models/category.dart';
import '../../../data/models/transaction_type.dart';
import '../../../data/providers/finance_provider.dart';

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
      builder: (_) => Padding(
        padding: EdgeInsets.only(
          bottom: MediaQuery.of(context).viewInsets.bottom,
        ),
        child: CategoryEditorSheet(initial: initial),
      ),
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
    final isEditing = widget.initial != null;

    return Padding(
      padding: const EdgeInsets.fromLTRB(24, 28, 24, 32),
      child: Form(
        key: _formKey,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Text(
                  isEditing ? 'Edit Category' : 'New Category',
                  style: theme.textTheme.headlineSmall,
                ),
                const Spacer(),
                IconButton(
                  icon: const Icon(Icons.close),
                  onPressed: () => Navigator.of(context).pop(),
                ),
              ],
            ),
            const SizedBox(height: 20),
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
              controller: _nameController,
              decoration: const InputDecoration(labelText: 'Name'),
              validator: (value) {
                if (value == null || value.trim().isEmpty) {
                  return 'Enter a category name';
                }
                return null;
              },
            ),
            const SizedBox(height: 20),
            Text(
              'Color',
              style: theme.textTheme.titleSmall?.copyWith(
                color: Colors.white70,
              ),
            ),
            const SizedBox(height: 12),
            Wrap(
              spacing: 12,
              runSpacing: 12,
              children: [
                for (final color in _colors)
                  GestureDetector(
                    onTap: () => setState(() => _color = color),
                    child: AnimatedContainer(
                      duration: const Duration(milliseconds: 200),
                      padding: const EdgeInsets.all(4),
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        border: Border.all(
                          color: _color == color
                              ? Colors.white
                              : Colors.transparent,
                          width: 2,
                        ),
                      ),
                      child: CircleAvatar(radius: 18, backgroundColor: color),
                    ),
                  ),
              ],
            ),
            const SizedBox(height: 28),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () => _submit(context),
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 14),
                ),
                child: Text(isEditing ? 'Save Changes' : 'Create Category'),
              ),
            ),
          ],
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
