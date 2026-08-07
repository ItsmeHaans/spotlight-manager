// features/shopping/providers/shopping_filter_provider.dart
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/shopping_category.dart';
import '../models/shopping_item.dart';
import 'shopping_provider.dart';

class ShoppingCategoryFilterNotifier extends Notifier<ShoppingCategory?> {
  @override
  ShoppingCategory? build() => null; // null = "All"

  void select(ShoppingCategory? category) => state = category;
}

final shoppingCategoryFilterProvider =
    NotifierProvider<ShoppingCategoryFilterNotifier, ShoppingCategory?>(
      ShoppingCategoryFilterNotifier.new,
    );

final filteredShoppingListProvider = Provider<AsyncValue<List<ShoppingItem>>>((
  ref,
) {
  final itemsAsync = ref.watch(shoppingListProvider);
  final selected = ref.watch(shoppingCategoryFilterProvider);

  return itemsAsync.whenData((items) {
    if (selected == null) return items;
    return items.where((item) => item.category == selected.label).toList();
  });
});
