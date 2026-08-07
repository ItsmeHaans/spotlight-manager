import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../core/theme/theme.dart';
import '../../../core/theme/theme_provider.dart';
import '../../../shared/widgets/app_text_field.dart';
import '../../../shared/widgets/app_button.dart';
import '../models/shopping_category.dart';
import '../models/shopping_item.dart';
import '../providers/shopping_provider.dart';

class AddEditShoppingScreen extends ConsumerStatefulWidget {
  final ShoppingItem? existingItem;
  const AddEditShoppingScreen({super.key, this.existingItem});

  @override
  ConsumerState<AddEditShoppingScreen> createState() =>
      _AddEditShoppingScreenState();
}

class _AddEditShoppingScreenState extends ConsumerState<AddEditShoppingScreen> {
  late final TextEditingController _nameController;
  late final TextEditingController _quantityController;
  ShoppingCategory? _selectedCategory;
  String _urgency = 'normal'; // 'low', 'normal', 'high'
  bool _isSaving = false;

  @override
  void initState() {
    super.initState();
    final existing = widget.existingItem;
    _nameController = TextEditingController(text: existing?.name ?? '');
    _quantityController = TextEditingController(
      text: (existing?.quantity ?? 1).toString(),
    );
    _selectedCategory = ShoppingCategory.fromLabel(existing?.category);
    _urgency = existing?.urgency ?? 'normal';
  }

  @override
  void dispose() {
    _nameController.dispose();
    _quantityController.dispose();
    super.dispose();
  }

  Future<void> _handleSave() async {
    if (_nameController.text.trim().isEmpty) return;

    setState(() => _isSaving = true);

    final item = ShoppingItem(
      id: widget.existingItem?.id ?? '',
      name: _nameController.text.trim(),
      category: _selectedCategory?.label,
      quantity: num.tryParse(_quantityController.text) ?? 1,
      isChecked: widget.existingItem?.isChecked ?? false,
      urgency: _urgency,
    );

    final service = ref.read(shoppingServiceProvider);
    if (widget.existingItem == null) {
      await service.addItem(item);
    } else {
      await service.updateItem(widget.existingItem!.id, item);
    }

    ref.invalidate(shoppingListProvider);
    if (mounted) context.go('/shopping');
  }

  @override
  Widget build(BuildContext context) {
    final colors = AppThemes.of(ref.watch(themeProvider));
    final isEditing = widget.existingItem != null;

    return Scaffold(
      backgroundColor: colors.background,
      appBar: AppBar(title: Text(isEditing ? "Edit Item" : "Add Item")),
      body: Padding(
        padding: const EdgeInsets.all(AppSpacing.md),
        child: ListView(
          children: [
            AppTextField(label: "Item Name", controller: _nameController),
            const SizedBox(height: AppSpacing.md),
            AppTextField(
              label: "Quantity",
              controller: _quantityController,
              keyboardType: TextInputType.number,
            ),
            const SizedBox(height: AppSpacing.md),

            // ---- Category dropdown ----
            Text(
              "Category",
              style: AppTypography.caption.copyWith(
                color: colors.textSecondary,
              ),
            ),
            const SizedBox(height: AppSpacing.xs),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: AppSpacing.md),
              decoration: BoxDecoration(
                color: colors.primary,
                borderRadius: BorderRadius.circular(12),
              ),
              child: DropdownButtonHideUnderline(
                child: DropdownButton<ShoppingCategory>(
                  value: _selectedCategory,
                  isExpanded: true,
                  dropdownColor: colors.background,
                  hint: Text(
                    "Select category",
                    style: TextStyle(color: colors.textSecondary),
                  ),
                  style: AppTypography.body.copyWith(
                    color: colors.textSecondary,
                  ),
                  items: ShoppingCategory.values
                      .map(
                        (c) => DropdownMenuItem(value: c, child: Text(c.label)),
                      )
                      .toList(),
                  onChanged: (value) =>
                      setState(() => _selectedCategory = value),
                ),
              ),
            ),
            const SizedBox(height: AppSpacing.md),

            // ---- Urgency segmented ----
            Text(
              "Urgency",
              style: AppTypography.caption.copyWith(
                color: colors.textSecondary,
              ),
            ),
            const SizedBox(height: AppSpacing.xs),
            Row(
              children: ['low', 'normal', 'high'].map((level) {
                final selected = _urgency == level;
                return Expanded(
                  child: Padding(
                    padding: const EdgeInsets.only(right: AppSpacing.xs),
                    child: ChoiceChip(
                      label: Text(level[0].toUpperCase() + level.substring(1)),
                      selected: selected,
                      selectedColor: colors.primary,
                      onSelected: (_) => setState(() => _urgency = level),
                    ),
                  ),
                );
              }).toList(),
            ),

            const SizedBox(height: AppSpacing.lg),
            AppButton(
              label: "Save",
              isLoading: _isSaving,
              onPressed: _handleSave,
            ),

            // ---- Delete (only when editing) ----
            if (isEditing) ...[
              const SizedBox(height: AppSpacing.md),
              TextButton.icon(
                icon: Icon(Icons.delete, color: colors.error),
                label: Text(
                  "Delete Item",
                  style: TextStyle(color: colors.error),
                ),
                onPressed: () async {
                  await ref
                      .read(shoppingServiceProvider)
                      .deleteItem(widget.existingItem!.id);
                  ref.invalidate(shoppingListProvider);
                  if (mounted) context.go('/shopping');
                },
              ),
            ],
          ],
        ),
      ),
    );
  }
}
