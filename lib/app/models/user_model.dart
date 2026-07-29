enum SubscriptionType { free, premium }

class UserModel {
  final String uid;
  final String email;
  final String displayName;
  final String photoUrl;
  final double weightKg;
  final double heightCm;
  final int age;
  final String gender; // 'male' / 'female'
  final double dailyCalorieGoal;
  final double dailyWaterGoalMl;
  final SubscriptionType subscriptionType;
  final int freeScanCountToday; // Kuota scan barcode gratis (max 2/hari untuk Free)
  final String lastScanResetDate; // Penanda reset kuota harian (format: YYYY-MM-DD)

  UserModel({
    required this.uid,
    required this.email,
    required this.displayName,
    this.photoUrl = '',
    required this.weightKg,
    required this.heightCm,
    required this.age,
    required this.gender,
    required this.dailyCalorieGoal,
    required this.dailyWaterGoalMl,
    this.subscriptionType = SubscriptionType.free,
    this.freeScanCountToday = 0,
    required this.lastScanResetDate,
  });

  // Konversi ke Map JSON untuk disimpan di Firebase Firestore
  Map<String, dynamic> toMap() {
    return {
      'uid': uid,
      'email': email,
      'displayName': displayName,
      'photoUrl': photoUrl,
      'weightKg': weightKg,
      'heightCm': heightCm,
      'age': age,
      'gender': gender,
      'dailyCalorieGoal': dailyCalorieGoal,
      'dailyWaterGoalMl': dailyWaterGoalMl,
      'subscriptionType': subscriptionType.name,
      'freeScanCountToday': freeScanCountToday,
      'lastScanResetDate': lastScanResetDate,
    };
  }

  // Membaca data Map JSON dari Firebase Firestore
  factory UserModel.fromMap(Map<String, dynamic> map) {
    return UserModel(
      uid: map['uid'] ?? '',
      email: map['email'] ?? '',
      displayName: map['displayName'] ?? '',
      photoUrl: map['photoUrl'] ?? '',
      weightKg: (map['weightKg'] ?? 0.0).toDouble(),
      heightCm: (map['heightCm'] ?? 0.0).toDouble(),
      age: map['age'] ?? 0,
      gender: map['gender'] ?? 'male',
      dailyCalorieGoal: (map['dailyCalorieGoal'] ?? 0.0).toDouble(),
      dailyWaterGoalMl: (map['dailyWaterGoalMl'] ?? 0.0).toDouble(),
      subscriptionType: map['subscriptionType'] == 'premium'
          ? SubscriptionType.premium
          : SubscriptionType.free,
      freeScanCountToday: map['freeScanCountToday'] ?? 0,
      lastScanResetDate: map['lastScanResetDate'] ?? '',
    );
  }
}
