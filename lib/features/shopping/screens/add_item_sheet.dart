import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../core/theme/theme.dart';
import '../../../core/theme/theme_provider.dart';
import '../../../shared/widgets/app_text_field.dart';
import '../../../shared/widgets/app_button.dart';
import '../models/shopping_item.dart';
import '../providers/shopping_provider.dart';

class AddEditShoppingScreen extends ConsumerStatefulWidget {
  final ShoppingItem? existingItem; // null = adding new, non-null = editing
  const AddEditShoppingScreen({super.key, this.existingItem});

  @override
  ConsumerState<AddEditShoppingScreen> createState() =>
      _AddEditShoppingScreenState();
}

class _AddEditShoppingScreenState extends ConsumerState<AddEditShoppingScreen> {
  late final TextEditingController
  _nameController; // native Dart `late` — initialized in initState, not here directly
  bool _isSaving = false;

  @override
  void initState() {
    // native Flutter — runs once, when this screen is first created
    super.initState();
    _nameController = TextEditingController(
      text: widget.existingItem?.name ?? '',
    );
  }

  Future<void> _handleSave() async {
    setState(() => _isSaving = true);

    final item = ShoppingItem(
      id: widget.existingItem?.id ?? '', // ignored on insert, used on update
      name: _nameController.text.trim(),
      quantity: 1,
      isChecked: false,
      urgency: 'normal',
    );

    final service = ref.read(shoppingServiceProvider);
    if (widget.existingItem == null) {
      await service.addItem(item);
    } else {
      await service.updateItem(widget.existingItem!.id, item);
    }

    ref.invalidate(shoppingListProvider); // refresh the list screen's data
    if (mounted)
      context.go(
        '/shopping',
      ); // native Flutter — `mounted` check before navigating after an async gap
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
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            AppTextField(label: "Item Name", controller: _nameController),
            const SizedBox(height: AppSpacing.lg),
            AppButton(
              label: "Save",
              isLoading: _isSaving,
              onPressed: _handleSave,
            ),
          ],
        ),
      ),
    );
  }
}
