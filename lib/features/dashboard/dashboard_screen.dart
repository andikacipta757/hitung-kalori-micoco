import 'package:flutter/material.dart';
import '../../app/models/user_model.dart';
import '../../app/models/food_model.dart';

class DashboardScreen extends StatefulWidget {
  final UserModel user;

  const DashboardScreen({Key? key, required this.user}) : super(key: key);

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  double _consumedCalories = 0.0;
  double _consumedWaterMl = 0.0;
  List<FoodItem> _todayLoggedFoods = [];

  void _addWater(double amountMl) {
    setState(() {
      _consumedWaterMl += amountMl;
    });
    // Simpan ke Firestore di tahap integrasi UI selanjutnya
  }

  @override
  Widget build(BuildContext context) {
    double remainingCalories = widget.user.dailyCalorieGoal - _consumedCalories;
    bool isFreeUser = widget.user.subscriptionType == SubscriptionType.free;

    return Scaffold(
      appBar: AppBar(
        title: Text('Hitung Kalori by Micoco'),
        actions: [
          IconButton(
            icon: Icon(Icons.account_circle),
            onPressed: () {
              // Navigasi ke Profil / Status Subscription
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
                padding: EdgeInsets.all(12),
                margin: EdgeInsets.only(bottom: 16),
                decoration: BoxDecoration(
                  color: Colors.amber.shade100,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: Colors.amber),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Expanded(
                      child: Text(
                        'Nikmati Scan Barcode Unlimted & AI Photo! Hanya Rp29.000/bln',
                        style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold),
                      ),
                    ),
                    ElevatedButton(
                      onPressed: () {
                        // Buka Paywall Screen (Rp29k/bln & Rp240k/thn)
                      },
                      child: Text('Upgrade'),
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
                    SizedBox(height: 8),
                    Text(
                      '${_consumedCalories.toInt()} / ${widget.user.dailyCalorieGoal.toInt()} kcal',
                      style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold, color: Colors.green),
                    ),
                    SizedBox(height: 8),
                    LinearProgressIndicator(
                      value: (_consumedCalories / widget.user.dailyCalorieGoal).clamp(0.0, 1.0),
                      minHeight: 10,
                      borderRadius: BorderRadius.circular(5),
                    ),
                    SizedBox(height: 12),
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

            SizedBox(height: 20),

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
                        Text('Water Tracker 💧', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                        SizedBox(height: 4),
                        Text('${_consumedWaterMl.toInt()} / ${widget.user.dailyWaterGoalMl.toInt()} ml'),
                      ],
                    ),
                    Row(
                      children: [
                        IconButton(
                          icon: Icon(Icons.local_drink, color: Colors.blue),
                          onPressed: () => _addWater(250), // Tambah 1 gelas (250ml)
                        ),
                        Text('+250ml'),
                      ],
                    )
                  ],
                ),
              ),
            ),

            SizedBox(height: 20),

            // Menu Tambah Makanan (Pencarian Manual, Barcode, AI Photo)
            Text('Catat Makanan Hari Ini', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: () {},
                    icon: Icon(Icons.search),
                    label: Text('Ketik'),
                  ),
                ),
                SizedBox(width: 8),
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: () {},
                    icon: Icon(Icons.qr_code_scanner),
                    label: Text('Scan (${widget.user.freeScanCountToday}/2)'),
                  ),
                ),
                SizedBox(width: 8),
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: () {},
                    icon: Icon(Icons.camera_alt),
                    label: Text('AI Photo'),
                  ),
                ),
              ],
            ),

            SizedBox(height: 20),

            // AdMob Banner Placeholder (Khusus Akun Free)
            if (isFreeUser)
              Container(
                height: 60,
                width: double.infinity,
                color: Colors.grey[300],
                child: Center(child: Text('Google AdMob Banner Area (Free Version)')),
              ),
          ],
        ),
      ),
    );
  }
}
