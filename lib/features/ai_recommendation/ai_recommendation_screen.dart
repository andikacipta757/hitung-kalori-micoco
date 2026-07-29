import 'package:flutter/material.dart';
import '../../app/models/user_model.dart';
import '../../app/services/ai_service.dart';
import '../premium/paywall_screen.dart';
import '../../app/utils/page_transitions.dart';

class AiRecommendationScreen extends StatefulWidget {
  final UserModel user;
  final double remainingCalories;
  final double remainingProteinGrams;

  const AiRecommendationScreen({
    Key? key,
    required this.user,
    required this.remainingCalories,
    required this.remainingProteinGrams,
  }) : super(key: key);

  @override
  State<AiRecommendationScreen> createState() => _AiRecommendationScreenState();
}

class _AiRecommendationScreenState extends State<AiRecommendationScreen> {
  final AiService _aiService = AiService();
  List<String> _suggestions = [];
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    if (widget.user.subscriptionType == SubscriptionType.premium) {
      _fetchSuggestions();
    }
  }

  void _fetchSuggestions() async {
    setState(() => _isLoading = true);
    try {
      final results = await _aiService.generateMealSuggestions(
        remainingCalories: widget.remainingCalories,
        remainingProteinGrams: widget.remainingProteinGrams,
        user: widget.user,
      );
      setState(() {
        _suggestions = results;
        _isLoading = false;
      });
    } catch (e) {
      setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    bool isPremium = widget.user.subscriptionType == SubscriptionType.premium;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Rekomendasi Menu AI 🤖'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header Info Sisa Nutrisi
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.green.shade50,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: Colors.green.shade200),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Sisa Kebutuhan Nutrisi Hari Ini:',
                    style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
                  ),
                  const SizedBox(height: 8),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        '🔥 ${widget.remainingCalories.toInt()} kcal',
                        style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.green),
                      ),
                      Text(
                        '🥩 ${widget.remainingProteinGrams.toStringAsFixed(1)}g Protein',
                        style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600, color: Colors.deepOrange),
                      ),
                    ],
                  ),
                ],
              ),
            ),

            const SizedBox(height: 20),

            // Tampilan Khusus User Free (Fitur Terkunci)
            if (!isPremium) ...[
              Expanded(
                child: Center(
                  child: Container(
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      color: Colors.amber.shade50,
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(color: Colors.amber),
                    ),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Icon(Icons.lock, size: 50, color: Colors.amber),
                        const SizedBox(height: 12),
                        const Text(
                          'Fitur Rekomendasi Menu AI Khusus Premium',
                          style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                          textAlign: TextAlign.center,
                        ),
                        const SizedBox(height: 8),
                        const Text(
                          'Bingung mau makan apa malam ini? AI akan menghitung dan menyarankan menu pas sesuai sisa kuota kalorimu!',
                          style: TextStyle(fontSize: 12, color: Colors.black87),
                          textAlign: TextAlign.center,
                        ),
                        const SizedBox(height: 16),
                        ElevatedButton.icon(
                          onPressed: () {
                            Navigator.push(
                              context,
                              SmoothPageRoute.scaleZoom(PaywallScreen(user: widget.user)),
                            );
                          },
                          icon: const Icon(Icons.star, color: Colors.white),
                          label: const Text('Upgrade Ke Premium (Rp29k/bln)'),
                          style: ElevatedButton.styleFrom(backgroundColor: Colors.amber.shade800),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ] else ...[
              // Tampilan User Premium (Daftar Saran Rekomendasi Menu AI)
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    'Saran Menu Sehat AI:',
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                  ),
                  IconButton(
                    icon: const Icon(Icons.refresh, color: Colors.green),
                    onPressed: _fetchSuggestions,
                  )
                ],
              ),
              const SizedBox(height: 8),

              if (_isLoading)
                const Expanded(child: Center(child: CircularProgressIndicator()))
              else
                Expanded(
                  child: ListView.builder(
                    itemCount: _suggestions.length,
                    itemBuilder: (context, index) {
                      return Card(
                        margin: const EdgeInsets.only(bottom: 12),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                        elevation: 2,
                        child: Padding(
                          padding: const EdgeInsets.all(16.0),
                          child: Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Icon(Icons.restaurant, color: Colors.green, size: 28),
                              const SizedBox(width: 12),
                              Expanded(
                                child: Text(
                                  _suggestions[index],
                                  style: const TextStyle(fontSize: 14, height: 1.4),
                                ),
                              ),
                            ],
                          ),
                        ),
                      );
                    },
                  ),
                ),
            ],
          ],
        ),
      ),
    );
  }
}
