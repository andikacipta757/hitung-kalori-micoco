import 'package:flutter/material.dart';
import 'app/models/user_model.dart';
import 'app/services/monetization_service.dart';
import 'features/dashboard/dashboard_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  // Inisialisasi Service Monetisasi (AdMob & RevenueCat)
  final monetizationService = MonetizationService();
  await monetizationService.initializeMonetization();

  runApp(const MicocoCalorieApp());
}

class MicocoCalorieApp extends StatelessWidget {
  const MicocoCalorieApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    // Dummy Data User untuk Inisialisasi Awal App
    final UserModel initialUser = UserModel(
      uid: 'micoco_user_01',
      email: 'user@micoco.com',
      displayName: 'Teman Micoco',
      photoUrl: '',
      weightKg: 65.0,
      heightCm: 170.0,
      age: 25,
      gender: 'male',
      dailyCalorieGoal: 2150.0,
      dailyWaterGoalMl: 2250.0,
      subscriptionType: SubscriptionType.free,
      freeScanCountToday: 0,
      lastScanResetDate: DateTime.now().toIso8601String().split('T')[0],
    );

    return MaterialApp(
      title: 'Hitung Kalori by Micoco',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        useMaterial3: true,
        colorScheme: ColorScheme.fromSeed(
          seedColor: Colors.green,
          primary: Colors.green.shade700,
          secondary: Colors.amber.shade700,
        ),
        scaffoldBackgroundColor: const Color(0xFFF8F9FA),
        appBarTheme: const AppBarTheme(
          backgroundColor: Colors.white,
          elevation: 0,
          iconTheme: IconThemeData(color: Colors.black87),
          titleTextStyle: TextStyle(
            color: Colors.black87,
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
      home: DashboardScreen(user: initialUser),
    );
  }
}
