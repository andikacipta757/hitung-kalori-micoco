import 'package:flutter/material.dart';
import '../../app/models/user_model.dart';
import '../../app/services/monetization_service.dart';

class PaywallScreen extends StatefulWidget {
  final UserModel user;

  const PaywallScreen({Key? key, required this.user}) : super(key: key);

  @override
  State<PaywallScreen> createState() => _PaywallScreenState();
}

class _PaywallScreenState extends State<PaywallScreen> {
  final MonetizationService _monetizationService = MonetizationService();
  int _selectedPlanIndex = 1; // Default pilih Tahunan (Best Value)
  bool _isLoading = false;

  void _handleSubscribe() async {
    setState(() => _isLoading = true);

    final selectedPlan = MonetizationService.availablePlans[_selectedPlanIndex];
    bool success = await _monetizationService.purchaseSubscription(selectedPlan);

    setState(() => _isLoading = false);

    if (success) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Selamat! Akun kamu berhasil di-upgrade ke Premium 🎉'),
          backgroundColor: Colors.green,
        ),
      );
      Navigator.pop(context, true);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Micoco Premium'),
        elevation: 0,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            // Banner Header Premium
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [Colors.amber, Colors.orangeAccent],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.circular(16),
              ),
              child: Row(
                children: [
                  const Icon(Icons.workspace_premium, size: 48, color: Colors.white),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: const [
                        Text(
                          'Buka Semua Akses',
                          style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold),
                        ),
                        SizedBox(height: 4),
                        Text(
                          'Capai target nutrisi harianmu lebih cepat & tanpa iklan!',
                          style: TextStyle(color: Colors.white, fontSize: 12),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),

            // Feature List / Benefit Premium
            _buildBenefitTile(Icons.qr_code_scanner, 'Unlimited Scan Barcode Produk', 'Bebas scan tanpa batasan 2x/hari'),
            _buildBenefitTile(Icons.camera_alt, 'Analisis Foto Makanan AI', 'Foto makananmu, AI yang hitung kalorinya'),
            _buildBenefitTile(Icons.pie_chart, 'Rincian Makro & Mikronutrisi', 'Lacak Protein, Karbo, Lemak, & Vitamin'),
            _buildBenefitTile(Icons.restaurant_menu, 'Rekomendasi Menu AI & Meal Prep', 'Dapatkan saran menu sesuai sisa kalori'),
            _buildBenefitTile(Icons.block, '100% Bebas Iklan', 'Pengalaman mencatat makanan tanpa gangguan'),
            _buildBenefitTile(Icons.analytics, 'Grafik Tren Mingguan & Bulanan', 'Pantau progres jangka panjangmu'),

            const SizedBox(height: 24),
            const Align(
              alignment: Alignment.centerLeft,
              child: Text('Pilih Paket Langganan:', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
            ),
            const SizedBox(height: 12),

            // Card Pilihan Paket (Bulanan vs Tahunan)
            ListView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: MonetizationService.availablePlans.length,
              itemBuilder: (context, index) {
                final plan = MonetizationService.availablePlans[index];
                final isSelected = _selectedPlanIndex == index;

                return GestureDetector(
                  onTap: () => setState(() => _selectedPlanIndex = index),
                  child: Container(
                    margin: const EdgeInsets.only(bottom: 12),
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: isSelected ? Colors.green.shade50 : Colors.white,
                      border: Border.all(
                        color: isSelected ? Colors.green : Colors.grey.shade300,
                        width: isSelected ? 2 : 1,
                      ),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                Text(
                                  plan.title,
                                  style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                                ),
                                if (plan.discountTag != null) ...[
                                  const SizedBox(width: 8),
                                  Container(
                                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                                    decoration: BoxDecoration(
                                      color: Colors.redAccent,
                                      borderRadius: BorderRadius.circular(8),
                                    ),
                                    child: Text(
                                      plan.discountTag!,
                                      style: const TextStyle(color: Colors.white, fontSize: 10, fontWeight: FontWeight.bold),
                                    ),
                                  ),
                                ]
                              ],
                            ),
                            const SizedBox(height: 4),
                            Text(plan.priceString, style: TextStyle(color: Colors.grey[700])),
                          ],
                        ),
                        Radio<int>(
                          value: index,
                          groupValue: _selectedPlanIndex,
                          onChanged: (val) => setState(() => _selectedPlanIndex = val!),
                          activeColor: Colors.green,
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),

            const SizedBox(height: 16),

            // Tombol Langganan
            SizedBox(
              width: double.infinity,
              height: 50,
              child: ElevatedButton(
                onPressed: _isLoading ? null : _handleSubscribe,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.green,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                ),
                child: _isLoading
                    ? const CircularProgressIndicator(color: Colors.white)
                    : const Text(
                        'Langganan Sekarang',
                        style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.white),
                      ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildBenefitTile(IconData icon, String title, String subtitle) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6.0),
      child: Row(
        children: [
          Icon(icon, color: Colors.green, size: 22),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13)),
                Text(subtitle, style: TextStyle(fontSize: 11, color: Colors.grey[600])),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
