class FoodItem {
  final String id;
  final String name;
  final double calories; // Kalori total
  final double servingSizeGrams; // Porsi dalam gram/ml
  final double proteinGrams; // Makronutrisi
  final double carbsGrams;
  final double fatGrams;
  final double fiberGrams; // Mikronutrisi/Tambahan (Fitur Premium)
  final String? barcode;
  final String? imageUrl;

  FoodItem({
    required this.id,
    required this.name,
    required this.calories,
    required this.servingSizeGrams,
    this.proteinGrams = 0.0,
    this.carbsGrams = 0.0,
    this.fatGrams = 0.0,
    this.fiberGrams = 0.0,
    this.barcode,
    this.imageUrl,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'calories': calories,
      'servingSizeGrams': servingSizeGrams,
      'proteinGrams': proteinGrams,
      'carbsGrams': carbsGrams,
      'fatGrams': fatGrams,
      'fiberGrams': fiberGrams,
      'barcode': barcode,
      'imageUrl': imageUrl,
    };
  }

  factory FoodItem.fromMap(Map<String, dynamic> map) {
    return FoodItem(
      id: map['id'] ?? '',
      name: map['name'] ?? '',
      calories: (map['calories'] ?? 0.0).toDouble(),
      servingSizeGrams: (map['servingSizeGrams'] ?? 100.0).toDouble(),
      proteinGrams: (map['proteinGrams'] ?? 0.0).toDouble(),
      carbsGrams: (map['carbsGrams'] ?? 0.0).toDouble(),
      fatGrams: (map['fatGrams'] ?? 0.0).toDouble(),
      fiberGrams: (map['fiberGrams'] ?? 0.0).toDouble(),
      barcode: map['barcode'],
      imageUrl: map['imageUrl'],
    );
  }
}
