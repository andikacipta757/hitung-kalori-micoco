import 'package:flutter/material.dart';
import '../../app/models/food_model.dart';
import '../../app/models/user_model.dart';
import '../../app/services/food_api_service.dart';
import '../../app/services/monetization_service.dart';

class FoodSearchScreen extends StatefulWidget {
  final UserModel user;

  const FoodSearchScreen({Key? key, required this.user}) : super(key: key);

  @override
  State<FoodSearchScreen> createState() => _FoodSearchScreenState();
}

class _FoodSearchScreenState extends State<FoodSearchScreen> {
  final TextEditingController _searchController = TextEditingController();
  final FoodApiService _foodApiService = FoodApiService();
  final MonetizationService _monetizationService = MonetizationService();

  List<FoodItem> _searchResults = [];
  bool _isLoading = false;
  FoodItem? _selectedFood;
  double _inputPortionGrams = 100.0; // Default 100g/ml

  void _performSearch(String query) async {
    if (query.trim().isEmpty) return;
    setState(() => _isLoading = true);

    List<FoodItem> results = await _foodApiService.searchFoodByName(query);
    setState(() {
      _searchResults = results;
      _isLoading = false;
    });
  }

  void _logFoodToDiary(FoodItem food) async {
    bool isFreeUser = widget.user.subscriptionType == SubscriptionType.free;

    // Untuk user Free: Putar iklan interstitial otomatis sebelum menyimpan
    if (isFreeUser) {
      await _monetizationService.showInterstitialAdIfNeeded(widget.user);
    }

    // Kalkulasi nutrisi berdasarkan porsi input gramasi user
    FoodItem scaledFood = food.copyWithPortion(_inputPortionGrams);

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Berhasil mencatat ${scaledFood.name} (${scaledFood.calories.toInt()} kcal)!'),
        backgroundColor: Colors.green,
      ),
    );

    Navigator.pop(context, scaledFood);
  }

  @override
  Widget build(BuildContext context) {
    bool isPremium = widget.user.subscriptionType == SubscriptionType.premium;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Cari Makanan & Minuman'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            // Field Pencarian
            TextField(
              controller: _searchController,
              decoration: InputDecoration(
                hintText: 'Misal: Nasi Goreng, Susu Sapi, Ayam Bakar...',
                prefixIcon: const Icon(Icons.search),
                suffixIcon: IconButton(
                  icon: const Icon(Icons.clear),
                  onPressed: () {
                    _searchController.clear();
                    setState(() => _searchResults = []);
                  },
                ),
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
              ),
              onSubmitted: _performSearch,
            ),
            const SizedBox(height: 16),

            // Loading / List Hasil Pencarian
            if (_isLoading)
              const CircularProgressIndicator()
            else if (_searchResults.isEmpty)
              const Expanded(
                child: Center(
                  child: Text('Cari nama makanan atau minuman untuk melihat informasi nutrisinya.'),
                ),
              )
            else
              Expanded(
                child: ListView.builder(
                  itemCount: _searchResults.length,
                  itemBuilder: (context, index) {
                    final item = _searchResults[index];
                    return Card(
                      margin: const EdgeInsets.symmetric(vertical: 6),
                      child: ListTile(
                        leading: const Icon(Icons.fastfood, color: Colors.orange),
                        title: Text(item.name, style: const TextStyle(fontWeight: FontWeight.bold)),
                        subtitle: Text('${item.calories.toInt()} kcal per ${item.servingSizeGrams.toInt()}g'),
                        onTap: () {
                          setState(() {
                            _selectedFood = item;
                            _inputPortionGrams = item.servingSizeGrams;
                          });
                          _showPortionModal(context, isPremium);
                        },
                      ),
                    );
                  },
                ),
              ),
          ],
        ),
      ),
    );
  }

  /// Bottom Sheet untuk Input Porsi & Detail Nutrisi
  void _showPortionModal(BuildContext context, bool isPremium) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setModalState) {
            if (_selectedFood == null) return const SizedBox();
            FoodItem calculatedFood = _selectedFood!.copyWithPortion(_inputPortionGrams);

            return Padding(
              padding: EdgeInsets.only(
                left: 20,
                right: 20,
                top: 20,
                bottom: MediaQuery.of(context).viewInsets.bottom + 20,
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    _selectedFood!.name,
                    style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 16),

                  // Slider / Input Gramasi
                  Row(
                    children: [
                      const Text('Porsi (gram/ml): ', style: TextStyle(fontWeight: FontWeight.w600)),
                      Expanded(
                        child: Slider(
                          value: _inputPortionGrams.clamp(10.0, 1000.0),
                          min: 10.0,
                          max: 1000.0,
                          divisions: 99,
                          label: '${_inputPortionGrams.toInt()} g/ml',
                          onChanged: (value) {
                            setModalState(() => _inputPortionGrams = value);
                          },
                        ),
                      ),
                      Text('${_inputPortionGrams.toInt()} g/ml', style: const TextStyle(fontWeight: FontWeight.bold)),
                    ],
                  ),
                  const Divider(),

                  // Tampilan Ringkasan Kalori
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text('Total Kalori:', style: TextStyle(fontSize: 16)),
                      Text(
                        '${calculatedFood.calories.toInt()} kcal',
                        style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: Colors.green),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),

                  // Detail Makronutrisi (Fitur Premium) vs Kunci (Fitur Free)
                  if (isPremium)
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: Colors.grey.shade100,
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceAround,
                        children: [
                          Text('Protein: ${calculatedFood.proteinGrams.toStringAsFixed(1)}g'),
                          Text('Karbo: ${calculatedFood.carbsGrams.toStringAsFixed(1)}g'),
                          Text('Lemak: ${calculatedFood.fatGrams.toStringAsFixed(1)}g'),
                        ],
                      ),
                    )
                  else
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: Colors.amber.shade50,
                        borderRadius: BorderRadius.circular(10),
                        border: Border.all(color: Colors.amber.shade300),
                      ),
                      child: const Row(
                        children: [
                          Icon(Icons.lock, color: Colors.amber, size: 20),
                          SizedBox(width: 8),
                          Expanded(
                            child: Text(
                              'Detail Protein, Karbo, Lemak & Serat terkunci. Upgrade Premium untuk membuka!',
                              style: TextStyle(fontSize: 12),
                            ),
                          ),
                        ],
                      ),
                    ),

                  const SizedBox(height: 20),

                  // Tombol Simpan
                  SizedBox(
                    width: double.infinity,
                    height: 48,
                    child: ElevatedButton(
                      onPressed: () {
                        Navigator.pop(context);
                        _logFoodToDiary(_selectedFood!);
                      },
                      style: ElevatedButton.styleFrom(
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                      ),
                      child: const Text('Tambahkan ke Catatan Harian'),
                    ),
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }
}
