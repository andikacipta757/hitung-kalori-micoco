import 'package:flutter/material.dart';
import '../../app/models/user_model.dart';
import '../../app/services/ai_service.dart';
import '../../app/services/food_api_service.dart';
import '../premium/paywall_screen.dart';
import '../../app/utils/page_transitions.dart';

class ScannerScreen extends StatefulWidget {
  final UserModel user;
  final bool isBarcodeMode; // true = Barcode, false = AI Photo

  const ScannerScreen({
    Key? key,
    required this.user,
    this.isBarcodeMode = true,
  }) : super(key: key);

  @override
  State<ScannerScreen> createState() => _ScannerScreenState();
}

class _ScannerScreenState extends State<ScannerScreen> {
  final FoodApiService _foodApiService = FoodApiService();
  final AiService _aiService = AiService();
  bool _isAnalyzing = false;

  void _processScan() async {
    // Cek Kuota Scan untuk User Free
    if (widget.user.subscriptionType == SubscriptionType.free &&
        widget.user.freeScanCountToday >= 2) {
      _showLimitReachedDialog();
      return;
    }

    setState(() => _isAnalyzing = true);

    if (widget.isBarcodeMode) {
      // Simulasi Scan Barcode (Contoh Barcode: "8992753123456")
      final food = await _foodApiService.fetchFoodByBarcode("8992753123456");
      setState(() => _isAnalyzing = false);

      if (food != null && mounted) {
        _showScanResultBottomSheet(food.name, food.calories, "Scan Barcode Berhasil!");
      }
    } else {
      // Simulasi AI Photo Analysis
      final result = await _aiService.analyzeFoodPhoto("dummy_image_path");
      setState(() => _isAnalyzing = false);

      if (mounted) {
        _showAiConfirmationDialog(result['detectedFood'], result['estimatedCalories']);
      }
    }
  }

  void _showLimitReachedDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Jatah Scan Gratis Habis 🔒'),
        content: const Text(
          'Kamu sudah memakai 2x jatah scan gratis hari ini. Upgrade ke Premium untuk scan barcode & foto AI tanpa batas!',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Nanti'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              Navigator.push(
                context,
                SmoothPageRoute.scaleZoom(PaywallScreen(user: widget.user)),
              );
            },
            style: ElevatedButton.styleFrom(backgroundColor: Colors.amber.shade800),
            child: const Text('Upgrade (Rp29k/bln)'),
          ),
        ],
      ),
    );
  }

  void _showAiConfirmationDialog(String foodName, double calories) {
    TextEditingController gramsController = TextEditingController(text: "100");

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('AI Mendeteksi: $foodName 🤖'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text('Perkiraan Awal: ${calories.toInt()} kcal / 100g'),
            const SizedBox(height: 12),
            const Text('Bila ragu, sesuaikan berat makananmu (gram/ml):'),
            TextField(
              controller: gramsController,
              keyboardType: TextInputType.number,
              decoration: const InputDecoration(labelText: 'Jumlah Gram/ML'),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Batal'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              double inputGrams = double.tryParse(gramsController.text) ?? 100.0;
              double finalCalories = (calories / 100) * inputGrams;
              _showScanResultBottomSheet(foodName, finalCalories, "Berhasil Dicatat via AI!");
            },
            style: ElevatedButton.styleFrom(backgroundColor: Colors.green),
            child: const Text('Simpan ke Log'),
          ),
        ],
      ),
    );
  }

  void _showScanResultBottomSheet(String name, double calories, String message) {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => Container(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.check_circle, color: Colors.green, size: 50),
            const SizedBox(height: 12),
            Text(message, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
            const SizedBox(height: 8),
            Text('$name - ${calories.toInt()} kcal', style: const TextStyle(fontSize: 18)),
            const SizedBox(height: 20),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () {
                  Navigator.pop(context);
                  Navigator.pop(context); // Kembali ke dashboard
                },
                style: ElevatedButton.styleFrom(backgroundColor: Colors.green),
                child: const Text('Selesai'),
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    int remainingScans = 2 - widget.user.freeScanCountToday;
    bool isPremium = widget.user.subscriptionType == SubscriptionType.premium;

    return Scaffold(
      appBar: AppBar(
        title: Text(widget.isBarcodeMode ? 'Scan Barcode Produk' : 'Foto Makanan AI'),
      ),
      body: Column(
        children: [
          // Banner Status Jatah Scan
          Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 16),
            color: isPremium ? Colors.green.shade100 : Colors.amber.shade100,
            child: Text(
              isPremium
                  ? '✨ Status Premium: Unlimited Scan'
                  : '🏷️ Akun Free: Sisa Jatah Scan Hari Ini: ${remainingScans < 0 ? 0 : remainingScans}/2',
              textAlign: TextAlign.center,
              style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13),
            ),
          ),

          Expanded(
            child: Container(
              margin: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: Colors.black87,
                borderRadius: BorderRadius.circular(20),
              ),
              child: Stack(
                alignment: Alignment.center,
                children: [
                  Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        widget.isBarcodeMode ? Icons.qr_code_scanner : Icons.camera_alt,
                        size: 80,
                        color: Colors.white54,
                      ),
                      const SizedBox(height: 16),
                      Text(
                        widget.isBarcodeMode
                            ? 'Arahkan kamera ke Barcode Makanan'
                            : 'Posisikan Makanan di Dalam Area Kamera',
                        style: const TextStyle(color: Colors.white, fontSize: 14),
                      ),
                    ],
                  ),
                  if (_isAnalyzing)
                    Container(
                      color: Colors.black54,
                      child: const Center(
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            CircularProgressIndicator(color: Colors.green),
                            SizedBox(height: 12),
                            Text('Menganalisis...', style: TextStyle(color: Colors.white)),
                          ],
                        ),
                      ),
                    ),
                ],
              ),
            ),
          ),

          // Tombol Trigger Simulasi Scan
          Padding(
            padding: const EdgeInsets.all(20.0),
            child: SizedBox(
              width: double.infinity,
              height: 50,
              child: ElevatedButton.icon(
                onPressed: _isAnalyzing ? null : _processScan,
                icon: Icon(widget.isBarcodeMode ? Icons.flash_on : Icons.camera),
                label: Text(widget.isBarcodeMode ? 'Pindai Barcode Sekarang' : 'Ambil Foto Makanan'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.green,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
