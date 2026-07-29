import 'package:flutter/material.dart';
import '../../app/models/user_model.dart';
import '../../app/services/auth_service.dart';
import '../premium/paywall_screen.dart';
import '../../app/utils/page_transitions.dart';

class ProfileScreen extends StatefulWidget {
  final UserModel user;

  const ProfileScreen({Key? key, required this.user}) : super(key: key);

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  final AuthService _authService = AuthService();
  late UserModel _currentUser;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _currentUser = widget.user;
  }

  void _handleGoogleSignIn() async {
    setState(() => _isLoading = true);
    final user = await _authService.signInWithGoogle();
    setState(() {
      _isLoading = false;
      if (user != null) {
        _currentUser = user;
      }
    });

    if (mounted && user != null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Selamat datang, ${_currentUser.displayName}! 🎉')),
      );
    }
  }

  void _handleSignOut() async {
    await _authService.signOut();
    setState(() {
      _currentUser = UserModel(
        uid: 'guest',
        email: '',
        displayName: 'Tamu Micoco',
        photoUrl: '',
        weightKg: 65,
        heightCm: 170,
        age: 25,
        gender: 'male',
        dailyCalorieGoal: 2000,
        dailyWaterGoalMl: 2000,
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    bool isPremium = _currentUser.subscriptionType == SubscriptionType.premium;
    bool isLoggedIn = _currentUser.uid != 'guest';

    return Scaffold(
      appBar: AppBar(
        title: const Text('Profil Saya'),
        actions: [
          if (isLoggedIn)
            IconButton(
              icon: const Icon(Icons.logout, color: Colors.redAccent),
              onPressed: _handleSignOut,
            )
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          children: [
            // Header Kartu Profil User
            Center(
              child: Column(
                children: [
                  CircleAvatar(
                    radius: 45,
                    backgroundColor: Colors.green.shade100,
                    backgroundImage: _currentUser.photoUrl.isNotEmpty
                        ? NetworkImage(_currentUser.photoUrl)
                        : null,
                    child: _currentUser.photoUrl.isEmpty
                        ? const Icon(Icons.person, size: 50, color: Colors.green)
                        : null,
                  ),
                  const SizedBox(height: 12),
                  Text(
                    _currentUser.displayName,
                    style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                  ),
                  Text(
                    isLoggedIn ? _currentUser.email : 'Akun belum terhubung',
                    style: TextStyle(color: Colors.grey[600], fontSize: 13),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 24),

            // Tombol Login Google jika belum terhubung
            if (!isLoggedIn)
              SizedBox(
                width: double.infinity,
                height: 48,
                child: OutlinedButton.icon(
                  onPressed: _isLoading ? null : _handleGoogleSignIn,
                  icon: const Icon(Icons.account_circle, color: Colors.redAccent),
                  label: _isLoading
                      ? const CircularProgressIndicator()
                      : const Text('Hubungkan Akun Google', style: TextStyle(fontWeight: FontWeight.bold)),
                  style: OutlinedButton.styleFrom(
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  ),
                ),
              ),

            const SizedBox(height: 20),

            // Card Status Langganan
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: isPremium ? Colors.amber.shade50 : Colors.grey.shade100,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(
                  color: isPremium ? Colors.amber : Colors.grey.shade300,
                ),
              ),
              child: Row(
                children: [
                  Icon(
                    isPremium ? Icons.workspace_premium : Icons.stars,
                    color: isPremium ? Colors.amber.shade800 : Colors.grey,
                    size: 36,
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          isPremium ? 'Status: Premium Member 👑' : 'Status: Akun Gratis',
                          style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15),
                        ),
                        Text(
                          isPremium
                              ? 'Akses penuh tanpa iklan & unlimited scan'
                              : 'Upgrade untuk fitur scan AI & bebas iklan',
                          style: TextStyle(fontSize: 11, color: Colors.grey[700]),
                        ),
                      ],
                    ),
                  ),
                  if (!isPremium)
                    ElevatedButton(
                      onPressed: () {
                        Navigator.push(
                          context,
                          SmoothPageRoute.scaleZoom(PaywallScreen(user: _currentUser)),
                        );
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.amber.shade800,
                        padding: const EdgeInsets.symmetric(horizontal: 12),
                      ),
                      child: const Text('Upgrade'),
                    ),
                ],
              ),
            ),

            const SizedBox(height: 24),

            // Ringkasan Parameter Tubuh (TDEE / BMR)
            const Align(
              alignment: Alignment.centerLeft,
              child: Text(
                'Data Fisik & Target Harian 🎯',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
              ),
            ),
            const SizedBox(height: 12),

            Card(
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              child: Column(
                children: [
                  ListTile(
                    leading: const Icon(Icons.monitor_weight, color: Colors.green),
                    title: const Text('Berat / Tinggi Badan'),
                    trailing: Text('${_currentUser.weightKg} kg / ${_currentUser.heightCm} cm'),
                  ),
                  const Divider(height: 1),
                  ListTile(
                    leading: const Icon(Icons.local_fire_department, color: Colors.orange),
                    title: const Text('Target Kalori Harian'),
                    trailing: Text('${_currentUser.dailyCalorieGoal.toInt()} kcal', style: const TextStyle(fontWeight: FontWeight.bold)),
                  ),
                  const Divider(height: 1),
                  ListTile(
                    leading: const Icon(Icons.water_drop, color: Colors.blue),
                    title: const Text('Target Air Minum'),
                    trailing: Text('${_currentUser.dailyWaterGoalMl.toInt()} ml', style: const TextStyle(fontWeight: FontWeight.bold)),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
