// features/shopping/models/shopping_category.dart
enum ShoppingCategory {
  groceries('Groceries'),
  household('Household'),
  personalCare('Personal Care'),
  healthPharmacy('Health & Pharmacy'),
  electronics('Electronics'),
  clothing('Clothing'),
  babyKids('Baby & Kids'),
  petSupplies('Pet Supplies'),
  stationery('Stationery'),
  others('Others');

  final String label;
  const ShoppingCategory(this.label);

  static ShoppingCategory? fromLabel(String? label) {
    if (label == null) return null;
    for (final c in ShoppingCategory.values) {
      if (c.label == label) return c;
    }
    return ShoppingCategory.others;
  }
}
