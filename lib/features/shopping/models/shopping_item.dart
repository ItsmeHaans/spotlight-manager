class ShoppingItem {
  final String id;
  final String name;
  final String? category;
  final num quantity;
  final bool isChecked;
  final String urgency; // 'low', 'normal', 'high'

  ShoppingItem({
    required this.id,
    required this.name,
    this.category,
    required this.quantity,
    required this.isChecked,
    required this.urgency,
  });

  factory ShoppingItem.fromMap(Map<String, dynamic> map) {
    return ShoppingItem(
      id: map['id'],
      name: map['name'],
      category: map['category'],
      quantity: map['quantity'] ?? 1,
      isChecked: map['is_checked'] ?? false,
      urgency: map['urgency'] ?? 'normal',
    );
  }

  Map<String, dynamic> toMap() {
    // NEW pattern — the reverse direction: app object → database row
    return {
      'name': name,
      'category': category,
      'quantity': quantity,
      'is_checked': isChecked,
      'urgency': urgency,
    };
  }
}
