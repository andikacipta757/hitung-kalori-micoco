import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:google_sign_in/google_sign_in.dart';
import '../models/user_model.dart';

class AuthService {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final GoogleSignIn _googleSignIn = GoogleSignIn();

  // Ambil data user yang sedang login
  User? get currentUser => _auth.currentUser;

  /// Sign In menggunakan Akun Google
  Future<UserCredential?> signInWithGoogle() async {
    try {
      final GoogleSignInAccount? googleUser = await _googleSignIn.signIn();
      if (googleUser == null) return null; // User membatalkan login

      final GoogleSignInAuthentication googleAuth = await googleUser.authentication;
      final OAuthCredential credential = GoogleAuthProvider.credential(
        accessToken: googleAuth.accessToken,
        idToken: googleAuth.idToken,
      );

      UserCredential userCredential = await _auth.signInWithCredential(credential);
      
      // Cek apakah user baru atau lama di Firestore
      await _syncUserData(userCredential.user);

      return userCredential;
    } catch (e) {
      print('Error Google Sign-In: $e');
      return null;
    }
  }

  /// Sinkronisasi Data Profil & Reset Kuota Scan Harian (2x Free)
  Future<void> _syncUserData(User? user) async {
    if (user == null) return;

    DocumentReference userDoc = _firestore.collection('users').doc(user.uid);
    DocumentSnapshot snapshot = await userDoc.get();

    String todayDate = DateTime.now().toIso8601String().split('T')[0]; // Format YYYY-MM-DD

    if (!snapshot.exists) {
      // User Baru: Buat dokumen baru di Firestore
      UserModel newUser = UserModel(
        uid: user.uid,
        email: user.email ?? '',
        displayName: user.displayName ?? 'Pengguna Micoco',
        photoUrl: user.photoURL ?? '',
        weightKg: 60.0, // Default nilai awal sebelum onboarding
        heightCm: 165.0,
        age: 25,
        gender: 'male',
        dailyCalorieGoal: 2000.0,
        dailyWaterGoalMl: 2100.0,
        subscriptionType: SubscriptionType.free,
        freeScanCountToday: 0,
        lastScanResetDate: todayDate,
      );
      await userDoc.set(newUser.toMap());
    } else {
      // User Lama: Cek apakah perlu reset kuota scan barcode harian
      Map<String, dynamic> data = snapshot.data() as Map<String, dynamic>;
      String lastReset = data['lastScanResetDate'] ?? '';

      if (lastReset != todayDate) {
        // Reset kuota jika sudah beda hari
        await userDoc.update({
          'freeScanCountToday': 0,
          'lastScanResetDate': todayDate,
        });
      }
    }
  }

  /// Mengambil Data Profil Lengkap dari Firestore
  Future<UserModel?> getUserProfile() async {
    if (currentUser == null) return null;
    DocumentSnapshot doc = await _firestore.collection('users').doc(currentUser!.uid).get();
    if (doc.exists) {
      return UserModel.fromMap(doc.data() as Map<String, dynamic>);
    }
    return null;
  }

  /// Sign Out
  Future<void> signOut() async {
    await _googleSignIn.signOut();
    await _auth.signOut();
  }
}
