import 'package:supabase_flutter/supabase_flutter.dart';
import '../models/shopping_item.dart';

class ShoppingService {
  final _client = Supabase.instance.client;

  Future<List<ShoppingItem>> fetchItems() async {
    final userId = _client.auth.currentUser!.id;
    final response = await _client
        .from('shopping_items')
        .select()
        .eq('user_id', userId)
        .order('created_at');
    return (response as List).map((row) => ShoppingItem.fromMap(row)).toList();
  }

  Future<void> addItem(ShoppingItem item) async {
    final userId = _client.auth.currentUser!.id;
    await _client.from('shopping_items').insert({
      ...item
          .toMap(), // native Dart — spread operator, unpacks the map's key-values here
      'user_id': userId,
    });
  }

  Future<void> updateItem(String id, ShoppingItem item) async {
    await _client.from('shopping_items').update(item.toMap()).eq('id', id);
  }

  Future<void> deleteItem(String id) async {
    await _client.from('shopping_items').delete().eq('id', id);
  }
}
