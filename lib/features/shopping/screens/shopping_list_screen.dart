import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../core/theme/theme.dart';
import '../../../core/theme/theme_provider.dart';
import '../../../shared/widgets/app_card.dart';
import '../../../shared/widgets/empty_state.dart';
import '../../../shared/widgets/confirm_dialog.dart';
import '../providers/shopping_provider.dart';
import '../screens/shopping_list_screen.dart';
import '../providers/shopping_filter_provider.dart';
import '../widgets/shopping_option_sheet.dart';
import 'package:flutter_svg/flutter_svg.dart';

class ShoppingListScreen extends ConsumerWidget {
  const ShoppingListScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final colors = AppThemes.of(ref.watch(themeProvider));
    final itemsAsync = ref.watch(filteredShoppingListProvider);

    return Scaffold(
      backgroundColor: colors.background,
      appBar: AppBar(
        title: const Text("Shopping List"),
        actions: [
          InkWell(
            borderRadius: BorderRadius.circular(20),
            onTap: () => openShoppingOptionsSheet(context, ref),
            child: Padding(
              padding: const EdgeInsets.all(AppSpacing.sm),
              child: SvgPicture.asset(
                colors.settingPath,
                width: 22,
                height: 22,
              ),
            ),
          ),
          IconButton(
            icon: const Icon(Icons.add),
            onPressed: () => context.go('/shopping/add'),
          ),
        ],
      ),
      body: itemsAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (err, stack) => Center(child: Text("Error: $err")),
        data: (items) {
          if (items.isEmpty) {
            return const EmptyState(
              message: "No items yet. Add your first one!",
              icon: Icons.shopping_cart,
            );
          }
          return ListView.builder(
            padding: const EdgeInsets.all(AppSpacing.md),
            itemCount: items.length,
            itemBuilder: (context, index) {
              final item = items[index];
              return Padding(
                padding: const EdgeInsets.only(bottom: AppSpacing.sm),
                child: AppCard(
                  onTap: () =>
                      context.go('/shopping/edit/${item.id}'), // tap = edit
                  child: Row(
                    children: [
                      Expanded(
                        child: Text(
                          item.name,
                          style: AppTypography.body.copyWith(
                            color: colors.textPrimary,
                          ),
                        ),
                      ),
                      IconButton(
                        icon: Icon(Icons.delete, color: colors.error),
                        onPressed: () => showDialog(
                          context: context,
                          builder: (context) => ConfirmDialog(
                            title: "Delete Item?",
                            message: "Remove '${item.name}' from your list?",
                            onConfirm: () async {
                              await ref
                                  .read(shoppingServiceProvider)
                                  .deleteItem(item.id);
                              ref.invalidate(
                                shoppingListProvider,
                              ); // native Riverpod — see explanation below
                            },
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }
}
