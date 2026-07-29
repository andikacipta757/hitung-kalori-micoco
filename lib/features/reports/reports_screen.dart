import 'package:flutter/material.dart';
import '../../app/models/user_model.dart';
import '../premium/paywall_screen.dart';
import '../../app/utils/page_transitions.dart';

class ReportsScreen extends StatelessWidget {
  final UserModel user;

  const ReportsScreen({Key? key, required this.user}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    bool isPremium = user.subscriptionType == SubscriptionType.premium;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Laporan & Analisis Nutrisi'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Section Laporan Harian (Bisa diakses Free & Premium)
            const Text(
              'Ringkasan Hari Ini 📅',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 12),
            Card(
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: [
                    _buildDailyStat('Target', '${user.dailyCalorieGoal.toInt()} kcal', Colors.grey),
                    _buildDailyStat('Tercapai', '1.450 kcal', Colors.green),
                    _buildDailyStat('Sisa', '${(user.dailyCalorieGoal - 1450).toInt()} kcal', Colors.blue),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 24),

            // Section Analisis Tren Mingguan & Bulanan (Fitur Premium)
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  'Grafik Tren Mingguan & Bulanan 📊',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
                if (!isPremium)
                  const Icon(Icons.lock, color: Colors.amber, size: 20),
              ],
            ),
            const SizedBox(height: 12),

            if (isPremium) ...[
              // Grafik Tren untuk User Premium
              Container(
                height: 220,
                width: double.infinity,
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(16),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.grey.shade200,
                      blurRadius: 8,
                      spreadRadius: 2,
                    )
                  ],
                ),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: const [
                    Icon(Icons.show_chart, size: 60, color: Colors.green),
                    SizedBox(height: 12),
                    Text(
                      'Visualisasi Grafik FlChart (Mingguan/Bulanan)',
                      style: TextStyle(fontWeight: FontWeight.bold),
                    ),
                    SizedBox(height: 4),
                    Text(
                      'Rata-rata kalori minggu ini: 1.820 kcal/hari',
                      style: TextStyle(color: Colors.grey, fontSize: 12),
                    ),
                  ],
                ),
              ),
            ] else ...[
              // Preview Teaser Kunci untuk User Free
              GestureDetector(
                onTap: () {
                  Navigator.push(
                    context,
                    SmoothPageRoute.scaleZoom(PaywallScreen(user: user)),
                  );
                },
                child: Container(
                  height: 200,
                  width: double.infinity,
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    color: Colors.amber.shade50,
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: Colors.amber.shade300),
                  ),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Icon(Icons.analytics, size: 48, color: Colors.amber),
                      const SizedBox(height: 12),
                      const Text(
                        'Grafik Tren Mingguan & Bulanan Terkunci',
                        style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                      ),
                      const SizedBox(height: 8),
                      const Text(
                        'Pantau riwayat progres konsumsi kalori jangka panjangmu dengan langganan Premium.',
                        style: TextStyle(fontSize: 12, color: Colors.black87),
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 12),
                      ElevatedButton(
                        onPressed: () {
                          Navigator.push(
                            context,
                            SmoothPageRoute.scaleZoom(PaywallScreen(user: user)),
                          );
                        },
                        style: ElevatedButton.styleFrom(backgroundColor: Colors.amber.shade800),
                        child: const Text('Buka Grafik Tren (Rp29k/bln)'),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildDailyStat(String title, String value, Color color) {
    return Column(
      children: [
        Text(title, style: const TextStyle(fontSize: 12, color: Colors.grey)),
        const SizedBox(height: 4),
        Text(
          value,
          style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: color),
        ),
      ],
    );
  }
}
