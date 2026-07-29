import 'dart:convert';
import 'http_client_placeholder.dart'; // Abstraksi HTTP client
import '../models/food_model.dart';
import '../models/user_model.dart';

class FoodApiService {
  // Gunakan API Key / Endpoint API nutrisi pilihan (misal: Open Food Facts / FatSecret / Edamam)
  final String _baseUrl = 'https://world.openfoodfacts.org/api/v2';

  /// Pencarian Makanan Manual berdasarkan Kata Kunci (Free & Premium)
  Future<List<FoodItem>> searchFoodByName(String query) async {
    if (query.trim().isEmpty) return [];

    try {
      final response = await httpGet('$_baseUrl/search?search_terms=$query&json=true');
      
      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        final List products = data['products'] ?? [];

        return products.map((item) {
          final nutriments = item['nutriments'] ?? {};
          return FoodItem(
            id: item['_id'] ?? DateTime.now().millisecondsSinceEpoch.toString(),
            name: item['product_name'] ?? 'Makanan Tanpa Nama',
            calories: (nutriments['energy-kcal_100g'] ?? 0.0).toDouble(),
            servingSizeGrams: 100.0, // Default kalkulasi per 100g/ml
            proteinGrams: (nutriments['proteins_100g'] ?? 0.0).toDouble(),
            carbsGrams: (nutriments['carbohydrates_100g'] ?? 0.0).toDouble(),
            fatGrams: (nutriments['fat_100g'] ?? 0.0).toDouble(),
            fiberGrams: (nutriments['fiber_100g'] ?? 0.0).toDouble(),
            imageUrl: item['image_front_small_url'],
          );
        }).toList();
      }
      return [];
    } catch (e) {
      print('Error saat mencari makanan: $e');
      return [];
    }
  }

  /// Scan Barcode Produk (Fitur Premium / Free Jatah 2x)
  Future<FoodItem?> fetchFoodByBarcode({
    required String barcode,
    required UserModel user,
  }) async {
    // Validasi Hak Akses & Kuota Scan
    if (user.subscriptionType == SubscriptionType.free && user.freeScanCountToday >= 2) {
      throw Exception('QUOTA_EXCEEDED: Batas 2x scan barcode gratis hari ini telah habis. Yuk upgrade ke Premium!');
    }

    try {
      final response = await httpGet('$_baseUrl/product/$barcode.json');

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        if (data['status'] == 1) {
          final product = data['product'];
          final nutriments = product['nutriments'] ?? {};

          return FoodItem(
            id: product['_id'] ?? barcode,
            name: product['product_name'] ?? 'Produk Kemasan',
            calories: (nutriments['energy-kcal_100g'] ?? 0.0).toDouble(),
            servingSizeGrams: 100.0,
            proteinGrams: (nutriments['proteins_100g'] ?? 0.0).toDouble(),
            carbsGrams: (nutriments['carbohydrates_100g'] ?? 0.0).toDouble(),
            fatGrams: (nutriments['fat_100g'] ?? 0.0).toDouble(),
            fiberGrams: (nutriments['fiber_100g'] ?? 0.0).toDouble(),
            barcode: barcode,
            imageUrl: product['image_front_small_url'],
          );
        }
      }
      return null;
    } catch (e) {
      rethrow;
    }
  }
}
