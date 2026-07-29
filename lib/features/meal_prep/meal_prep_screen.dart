import 'package:flutter/material.dart';
import '../../app/models/food_model.dart';
import '../../app/models/user_model.dart';

class FavoriteMealPackage {
  final String id;
  final String packageName; // Contoh: "Paket Sarapan Rutin"
  final List<FoodItem> items;

  FavoriteMealPackage({
    required this.id,
    required this.packageName,
    required this.items,
  });

  double get totalCalories => items.fold(0, (sum, item) => sum + item.calories);
}

class MealPrepScreen extends StatefulWidget {
  final UserModel user;

  const MealPrepScreen({Key? key, required this.user}) : super(key: key);

  @override
  State<MealPrepScreen> createState() => _MealPrepScreenState();
}

class _MealPrepScreenState extends State<MealPrepScreen> {
  // Contoh data menu favorit yang sudah disimpan user
  final List<FavoriteMealPackage> _savedPackages = [
    FavoriteMealPackage(
      id: '1',
      packageName: 'Paket Sarapan Sehat',
      items: [
        FoodItem(id: '1', name: 'Telur Rebus (2 butir)', calories: 155, servingSizeGrams: 100),
        FoodItem(id: '2', name: 'Roti Gandum (1 lembar)', calories: 80, servingSizeGrams: 40),
        FoodItem(id: '3', name: 'Kopi Hitam Tanpa Gula', calories: 2, servingSizeGrams: 200),
      ],
    ),
    FavoriteMealPackage(
      id: '2',
      packageName: 'Dada Ayam & Nasi Merah (Makan Siang)',
      items: [
        FoodItem(id: '4', name: 'Dada Ayam Panggang', calories: 248, servingSizeGrams: 150),
        FoodItem(id: '5', name: 'Nasi Merah', calories: 110, servingSizeGrams: 100),
      ],
    ),
  ];

  void _logPackageToDiary(FavoriteMealPackage package) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Berhasil menambahkan "${package.packageName}" (${package.totalCalories.toInt()} kcal) ke catatan!'),
        backgroundColor: Colors.green,
      ),
    );
    Navigator.pop(context, package.items);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Meal Prep & Menu Favorit'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Simpan & Catat Sekaligus ⚡',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 4),
            Text(
              'Catat kombinasi menu harianmu cukup dengan satu kali klik.',
              style: TextStyle(color: Colors.grey[600], fontSize: 13),
            ),
            const SizedBox(height: 16),

            Expanded(
              child: ListView.builder(
                itemCount: _savedPackages.length,
                itemBuilder: (context, index) {
                  final package = _savedPackages[index];
                  return Card(
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    margin: const EdgeInsets.only(bottom: 12),
                    elevation: 2,
                    child: Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                package.packageName,
                                style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                              ),
                              Text(
                                '${package.totalCalories.toInt()} kcal',
                                style: const TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.green,
                                ),
                              ),
                            ],
                          ),
                          const Divider(height: 20),

                          // List Item Bahan/Makanan di dalam Paket
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: package.items
                                .map((food) => Padding(
                                      padding: const EdgeInsets.symmetric(vertical: 2.0),
                                      child: Text(
                                        '• ${food.name} (${food.calories.toInt()} kcal)',
                                        style: TextStyle(fontSize: 13, color: Colors.grey[700]),
                                      ),
                                    ))
                                .toList(),
                          ),
                          const SizedBox(height: 12),

                          // Tombol Cepat Tambahkan
                          SizedBox(
                            width: double.infinity,
                            child: ElevatedButton.icon(
                              onPressed: () => _logPackageToDiary(package),
                              icon: const Icon(Icons.add_task),
                              label: const Text('Catat Sekaligus Hari Ini'),
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Colors.green,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(8),
                                ),
                              ),
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
        ),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () {
          // Dialog / Screen untuk membuat racikan menu favorit baru
        },
        icon: const Icon(Icons.bookmark_add),
        label: const Text('Buat Paket Baru'),
      ),
    );
  }
}
