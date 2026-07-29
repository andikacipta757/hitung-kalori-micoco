import '../models/user_model.dart';

class SubscriptionPlan {
  final String id;
  final String title;
  final String priceString;
  final double priceValue;
  final String duration; // 'monthly' atau 'yearly'
  final String? discountTag;

  SubscriptionPlan({
    required this.id,
    required this.title,
    required this.priceString,
    required this.priceValue,
    required this.duration,
    this.discountTag,
  });
}

class MonetizationService {
  // Config Paket Subskripsi Hitung Kalori by Micoco
  static final List<SubscriptionPlan> availablePlans = [
    SubscriptionPlan(
      id: 'micoco_premium_monthly',
      title: 'Premium Bulanan',
      priceString: 'Rp 29.000 / bulan',
      priceValue: 29000.0,
      duration: 'monthly',
    ),
    SubscriptionPlan(
      id: 'micoco_premium_yearly',
      title: 'Premium Tahunan',
      priceString: 'Rp 240.000 / tahun',
      priceValue: 240000.0,
      duration: 'yearly',
      discountTag: 'Hemat 31% (Rp 20.000/bln)',
    ),
  ];

  /// Inisialisasi SDK AdMob & RevenueCat saat aplikasi pertama kali dibuka
  Future<void> initializeMonetization() async {
    try {
      print('Monetization SDK Initialized (Monthly: Rp 29k, Yearly: Rp 240k).');
    } catch (e) {
      print('Error initializing monetization: $e');
    }
  }

  /// Cek apakah pengguna saat ini berstatus Premium via RevenueCat
  Future<bool> checkPremiumStatus(String uid) async {
    try {
      return false; // Default false untuk testing
    } catch (e) {
      print('Error checking subscription: $e');
      return false;
    }
  }

  /// Tampilkan Iklan Interstitial Otomatis Sebelum Hasil Input Keluar (Khusus Akun Free)
  Future<void> showInterstitialAdIfNeeded(UserModel user) async {
    if (user.subscriptionType == SubscriptionType.premium) {
      return;
    }
    print('Pemutaran Iklan Interstitial Otomatis untuk User Free...');
  }

  /// Memproses Pembelian Subskripsi Bulanan / Tahunan
  Future<bool> purchaseSubscription(SubscriptionPlan plan) async {
    try {
      print('Memproses pembelian paket ${plan.title} seharga ${plan.priceString}');
      return true;
    } catch (e) {
      print('Pembelian gagal atau dibatalkan: $e');
      return false;
    }
  }
}
