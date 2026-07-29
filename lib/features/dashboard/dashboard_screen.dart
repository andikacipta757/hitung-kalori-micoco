import 'package:flutter/material.dart';
import '../../app/models/user_model.dart';
import '../../app/models/food_model.dart';
import '../../app/utils/page_transitions.dart';

class DashboardScreen extends StatefulWidget {
  final UserModel user;

  const DashboardScreen({Key? key, required this.user}) : super(key: key);

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  double _consumedCalories = 0.0;
  double _consumedWaterMl = 0.0;

  void _addWater(double amountMl) {
    setState(() {
      _consumedWaterMl += amountMl;
    });
  }

  // fungsi helper dummy untuk navigasi dengan animasi
  void _openPageWithAnimation(Widget targetPage, {bool isZoom = false}) {
    Navigator.push(
      context,
      isZoom 
          ? SmoothPageRoute.scaleZoom(targetPage) 
          : SmoothPageRoute.slideUp(targetPage),
    );
  }

  @override
  Widget build(BuildContext context) {
    double remainingCalories = widget.user.dailyCalorieGoal - _consumedCalories;
    bool isFreeUser = widget.user.subscriptionType == SubscriptionType.free;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Hitung Kalori by Micoco'),
        actions: [
          IconButton(
            icon: const Icon(Icons.account_circle),
            onPressed: () {
              // Contoh penggunaan transisi Slide Up ke Profil
              // _openPageWithAnimation(const ProfileScreen());
            },
          )
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Banner Subskripsi untuk User Free
            if (isFreeUser)
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(12),
                margin: const EdgeInsets.only(bottom: 16),
                decoration: BoxDecoration(
                  color: Colors.amber.shade100,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: Colors.amber),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Expanded(
                      child: Text(
                        'Nikmati Scan Barcode Unlimited & AI Photo! Hanya Rp29.000/bln',
                        style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold),
                      ),
                    ),
                    ElevatedButton(
                      onPressed: () {
                        // Membuka Paywall dengan animasi Zoom Bounce yang menarik
                        // _openPageWithAnimation(const PaywallScreen(), isZoom: true);
                      },
                      child: const Text('Upgrade'),
                    )
                  ],
                ),
              ),

            // Card Ringkasan Kalori Harian
            Card(
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
              elevation: 4,
              child: Padding(
                padding: const EdgeInsets.all(20.0),
                child: Column(
                  children: [
                    Text('Target Kalori Harian', style: TextStyle(fontSize: 16, color: Colors.grey[700])),
                    const SizedBox(height: 8),
                    Text(
                      '${_consumedCalories.toInt()} / ${widget.user.dailyCalorieGoal.toInt()} kcal',
                      style: const TextStyle(fontSize: 28, fontWeight: FontWeight.bold, color: Colors.green),
                    ),
                    const SizedBox(height: 8),
                    LinearProgressIndicator(
                      value: (_consumedCalories / widget.user.dailyCalorieGoal).clamp(0.0, 1.0),
                      minHeight: 10,
                      borderRadius: BorderRadius.circular(5),
                    ),
                    const SizedBox(height: 12),
                    Text(
                      remainingCalories >= 0
                          ? 'Sisa Kuota: ${remainingCalories.toInt()} kcal'
                          : 'Kelebihan: ${(remainingCalories.abs()).toInt()} kcal',
                      style: TextStyle(
                        color: remainingCalories >= 0 ? Colors.blue : Colors.red,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 20),

            // Section Water Tracker
            Card(
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text('Water Tracker 💧', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                        const SizedBox(height: 4),
                        Text('${_consumedWaterMl.toInt()} / ${widget.user.dailyWaterGoalMl.toInt()} ml'),
                      ],
                    ),
                    Row(
                      children: [
                        IconButton(
                          icon: const Icon(Icons.local_drink, color: Colors.blue),
                          onPressed: () => _addWater(250), // Tambah 1 gelas (250ml)
                        ),
                        const Text('+250ml'),
                      ],
                    )
                  ],
                ),
              ),
            ),

            const SizedBox(height: 20),

            // Menu Tambah Makanan (Pencarian Manual, Barcode, AI Photo)
            const Text('Catat Makanan Hari Ini', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: () {
                      // Nanti saat layar pencarian dibuat, kita panggil animasi Slide Up:
                      // _openPageWithAnimation(const FoodSearchScreen());
                    },
                    icon: const Icon(Icons.search),
                    label: const Text('Ketik'),
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: () {
                      // Navigasi ke Scanner
                    },
                    icon: const Icon(Icons.qr_code_scanner),
                    label: Text('Scan (${widget.user.freeScanCountToday}/2)'),
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: () {
                      // Navigasi ke AI Photo dengan animasi Zoom
                    },
                    icon: const Icon(Icons.camera_alt),
                    label: const Text('AI Photo'),
                  ),
                ),
              ],
            ),

            const SizedBox(height: 20),

            // AdMob Banner Placeholder (Khusus Akun Free)
            if (isFreeUser)
              Container(
                height: 60,
                width: double.infinity,
                color: Colors.grey[300],
                child: const Center(child: Text('Google AdMob Banner Area (Free Version)')),
              ),
          ],
        ),
      ),
    );
  }
}
