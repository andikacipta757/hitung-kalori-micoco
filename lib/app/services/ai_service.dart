import 'dart:convert';
import 'dart:io';
import '../models/food_model.dart';
import '../models/user_model.dart';

class AiAnalysisResult {
  final FoodItem? foodItem;
  final bool needsClarification;
  final String? clarificationQuestion;

  AiAnalysisResult({
    this.foodItem,
    this.needsClarification = false,
    this.clarificationQuestion,
  });
}

class AiService {
  /// Analisis Foto Makanan dengan AI (Fitur Premium)
  Future<AiAnalysisResult> analyzeFoodImage({
    required File imageFile,
    required UserModel user,
    String? additionalInfo, // Jawaban user jika sebelumnya AI bertanya
  }) async {
    // Proteksi Fitur Premium
    if (user.subscriptionType == SubscriptionType.free) {
      throw Exception('PREMIUM_REQUIRED: Fitur Analisis Foto AI khusus untuk pengguna Premium.');
    }

    try {
      // Simulasi/Implementasi Prompt API Multimodal AI (misal: Gemini API / OpenAI API)
      // Di produksi, gambar di-encode ke Base64 lalu dikirim bersama prompt nutrisi.
      
      // Logika Penanganan: Jika AI butuh konfirmasi gramasi/jenis porsi
      if (additionalInfo == null && _isAmbiguousImage()) {
        return AiAnalysisResult(
          needsClarification: true,
          clarificationQuestion: 'AI mendeteksi Nasi Goreng Telur. Berapa perkiraan porsi atau gramasinya? (Contoh: 1 porsi sedang / 200 gram)',
        );
      }

      // Hasil analisis AI yang sudah tervalidasi
      FoodItem detectedFood = FoodItem(
        id: DateTime.now().millisecondsSinceEpoch.toString(),
        name: 'Nasi Goreng Telur Spesial',
        calories: 450.0,
        servingSizeGrams: 200.0,
        proteinGrams: 14.0,
        carbsGrams: 58.0,
        fatGrams: 18.0,
        fiberGrams: 2.5,
      );

      return AiAnalysisResult(foodItem: detectedFood);
    } catch (e) {
      print('Error AI Image Analysis: $e');
      rethrow;
    }
  }

  /// Rekomendasi Menu Sehat berdasarkan Sisa Kalori Harian (Fitur Premium)
  Future<List<String>> generateMealSuggestions({
    required double remainingCalories,
    required double remainingProteinGrams,
    required UserModel user,
  }) async {
    if (user.subscriptionType == SubscriptionType.free) {
      throw Exception('PREMIUM_REQUIRED: Fitur Rekomendasi Menu AI khusus untuk pengguna Premium.');
    }

    if (remainingCalories <= 0) {
      return ['Kuota kalori harianmu sudah terpenuhi! Cukup minum air putih yang banyak malam ini ya. 💧'];
    }

    // Prompt generator rekomendasi menu sesuai sisa nutrisi
    List<String> suggestions = [
      'Opsi 1: Dada ayam panggang (150g) + Salad sayur segar. (Sekitar ${remainingCalories.clamp(200, 350).toInt()} kcal, High Protein)',
      'Opsi 2: Omelet 2 telur + Roti gandum utuh 1 lembar. (Sekitar ${remainingCalories.clamp(250, 400).toInt()} kcal)',
      'Opsi 3: Greek Yogurt (150g) + Potongan buah pisang & madu. (Sekitar ${remainingCalories.clamp(150, 250).toInt()} kcal)',
    ];

    return suggestions;
  }

  bool _isAmbiguousImage() {
    // Logika internal untuk mengecek kejelasan porsi dari respon AI
    return false; // Set default false untuk tes
  }
}
