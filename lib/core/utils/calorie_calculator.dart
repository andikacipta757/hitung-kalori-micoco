enum Gender { male, female }

enum ActivityLevel {
  sedentary, // Jarang olahraga (x 1.2)
  lightlyActive, // Olahraga ringan 1-3 hari/minggu (x 1.375)
  moderatelyActive, // Olahraga sedang 3-5 hari/minggu (x 1.55)
  veryActive, // Olahraga berat 6-7 hari/minggu (x 1.725)
  extraActive // Olahraga sangat berat / fisik keras (x 1.9)
}

class CalorieCalculator {
  /// Menghitung BMR (Basal Metabolic Rate)
  static double calculateBMR({
    required double weightKg,
    required double heightCm,
    required int age,
    required Gender gender,
  }) {
    if (gender == Gender.male) {
      return (10 * weightKg) + (6.25 * heightCm) - (5 * age) + 5;
    } else {
      return (10 * weightKg) + (6.25 * heightCm) - (5 * age) - 161;
    }
  }

  /// Menghitung TDEE (Total Kebutuhan Kalori Harian)
  static double calculateTDEE({
    required double bmr,
    required ActivityLevel activityLevel,
  }) {
    switch (activityLevel) {
      case ActivityLevel.sedentary:
        return bmr * 1.2;
      case ActivityLevel.lightlyActive:
        return bmr * 1.375;
      case ActivityLevel.moderatelyActive:
        return bmr * 1.55;
      case ActivityLevel.veryActive:
        return bmr * 1.725;
      case ActivityLevel.extraActive:
        return bmr * 1.9;
    }
  }

  /// Menghitung Target Air Putih Harian dalam mililiter (mL)
  static double calculateWaterGoal(double weightKg) {
    return weightKg * 35.0; // Standar 35 ml per kg BB
  }

  /// Menghitung Breakdown Makronutrisi Dasar (Fitur Premium)
  /// Karbohidrat 50%, Protein 20%, Lemak 30%
  static Map<String, double> calculateMacros(double totalCalories) {
    return {
      'carbsGrams': (totalCalories * 0.50) / 4, // 1g karbo = 4 kalori
      'proteinGrams': (totalCalories * 0.20) / 4, // 1g protein = 4 kalori
      'fatGrams': (totalCalories * 0.30) / 9, // 1g lemak = 9 kalori
    };
  }
}
