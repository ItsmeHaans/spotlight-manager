import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/shopping_item.dart';
import '../services/shopping_service.dart';

final shoppingServiceProvider = Provider(
  (ref) => ShoppingService(),
); // native Riverpod — simplest provider type, just exposes an object

final shoppingListProvider = FutureProvider<List<ShoppingItem>>((ref) {
  return ref.watch(shoppingServiceProvider).fetchItems();
});
