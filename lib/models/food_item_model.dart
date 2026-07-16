class FoodItemModel {
  final String id;
  final String name;
  final String description;
  final double price;
  final String restaurantId; // Kis restaurant ne dish dali hai

  FoodItemModel({
    required this.id,
    required this.name,
    required this.description,
    required this.price,
    required this.restaurantId,
  });

  // Database mein data bhejne ke liye (Map format)
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'description': description,
      'price': price,
      'restaurantId': restaurantId,
    };
  }

  // Database se data nikalne ke liye
  factory FoodItemModel.fromMap(Map<String, dynamic> map) {
    return FoodItemModel(
      id: map['id'] ?? '',
      name: map['name'] ?? '',
      description: map['description'] ?? '',
      price: (map['price'] ?? 0.0).toDouble(),
      restaurantId: map['restaurantId'] ?? '',
    );
  }
}