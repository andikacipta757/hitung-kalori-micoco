import 'package:flutter/material.dart';
import '../../app/models/user_model.dart';

class WaterTrackerScreen extends StatefulWidget {
  final UserModel user;

  const WaterTrackerScreen({Key? key, required this.user}) : super(key: key);

  @override
  State<WaterTrackerScreen> createState() => _WaterTrackerScreenState();
}

class _WaterTrackerScreenState extends State<WaterTrackerScreen> {
  double _currentWaterMl = 1250.0; // Contoh progress harian
  bool _reminderEnabled = true;
  int _reminderIntervalHours = 2;

  void _addWater(double amountMl) {
    setState(() {
      _currentWaterMl += amountMl;
    });
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Berhasil menambah ${amountMl.toInt()} ml air minum 💧'),
        duration: const Duration(seconds: 1),
        backgroundColor: Colors.blue,
      ),
    );
  }

  void _resetWater() {
    setState(() {
      _currentWaterMl = 0.0;
    });
  }

  @override
  Widget build(BuildContext context) {
    double targetMl = widget.user.dailyWaterGoalMl;
    double progressRatio = (_currentWaterMl / targetMl).clamp(0.0, 1.0);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Water Tracker & Reminder'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          children: [
            // Progress Hydration Card
            Container(
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [Colors.blue.shade400, Colors.lightBlue.shade200],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.circular(20),
                boxShadow: [
                  BoxShadow(
                    color: Colors.blue.withOpacity(0.2),
                    blurRadius: 10,
                    offset: const Offset(0, 5),
                  )
                ],
              ),
              child: Column(
                children: [
                  const Icon(Icons.water_drop, size: 60, color: Colors.white),
                  const SizedBox(height: 12),
                  Text(
                    '${_currentWaterMl.toInt()} / ${targetMl.toInt()} ml',
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 28,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Target harian disesuaikan dengan profilmu',
                    style: TextStyle(color: Colors.white.withOpacity(0.9), fontSize: 12),
                  ),
                  const SizedBox(height: 16),
                  ClipRRect(
                    borderRadius: BorderRadius.circular(10),
                    child: LinearProgressIndicator(
                      value: progressRatio,
                      minHeight: 12,
                      backgroundColor: Colors.white.withOpacity(0.4),
                      color: Colors.white,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    '${(progressRatio * 100).toInt()}% Tercapai',
                    style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 24),

            // Tombol Cepat Tambah Air
            const Align(
              alignment: Alignment.centerLeft,
              child: Text(
                'Catat Asupan Air 🥛',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
              ),
            ),
            const SizedBox(height: 12),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                _buildAddWaterButton(200, 'Gelas Kecil\n(200 ml)', Icons.local_drink),
                _buildAddWaterButton(330, 'Gelas Sedang\n(330 ml)', Icons.local_cafe),
                _buildAddWaterButton(600, 'Botol Air\n(600 ml)', Icons.water),
              ],
            ),

            const SizedBox(height: 24),

            // Card Pengaturan Pengingat Minum (Reminder)
            Card(
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  children: [
                    SwitchListTile(
                      title: const Text(
                        'Pengingat Minum Air 🔔',
                        style: TextStyle(fontWeight: FontWeight.bold),
                      ),
                      subtitle: const Text('Dapatkan notifikasi agar tidak lupa hidrasi'),
                      value: _reminderEnabled,
                      activeColor: Colors.blue,
                      onChanged: (val) {
                        setState(() => _reminderEnabled = val);
                      },
                    ),
                    if (_reminderEnabled) ...[
                      const Divider(),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const Text('Ingatkan setiap:'),
                          DropdownButton<int>(
                            value: _reminderIntervalHours,
                            items: const [
                              DropdownMenuItem(value: 1, child: Text('1 Jam')),
                              DropdownMenuItem(value: 2, child: Text('2 Jam')),
                              DropdownMenuItem(value: 3, child: Text('3 Jam')),
                            ],
                            onChanged: (val) {
                              if (val != null) {
                                setState(() => _reminderIntervalHours = val);
                              }
                            },
                          ),
                        ],
                      ),
                    ]
                  ],
                ),
              ),
            ),

            const SizedBox(height: 16),
            TextButton.icon(
              onPressed: _resetWater,
              icon: const Icon(Icons.refresh, color: Colors.grey),
              label: const Text('Reset Catatan Air Hari Ini', style: TextStyle(color: Colors.grey)),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildAddWaterButton(double amount, String label, IconData icon) {
    return ElevatedButton(
      onPressed: () => _addWater(amount),
      style: ElevatedButton.styleFrom(
        backgroundColor: Colors.blue.shade50,
        foregroundColor: Colors.blue.shade800,
        elevation: 0,
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
          side: BorderSide(color: Colors.blue.shade200),
        ),
      ),
      child: Column(
        children: [
          Icon(icon, size: 28),
          const SizedBox(height: 6),
          Text(
            label,
            textAlign: TextAlign.center,
            style: const TextStyle(fontSize: 11, fontWeight: FontWeight.bold),
          ),
        ],
      ),
    );
  }
}
