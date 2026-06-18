import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../main_navigation.dart';
import 'package:ecotoken_app/app_state.dart'; 
import 'register_screen.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _isLoading = false; // Yükleniyor animasyonu için eklendi

  // FİREBASE GİRİŞ YAPMA MOTORU 
  Future<void> _login() async {
    if (_emailController.text.isEmpty || _passwordController.text.isEmpty) return;
    
    setState(() => _isLoading = true);
    try {
      // 1. Firebase ile giriş yap
      UserCredential userCredential = await FirebaseAuth.instance.signInWithEmailAndPassword(
        email: _emailController.text.trim(),
        password: _passwordController.text.trim(),
      );

      // 2. Başarılı olursa kullanıcının puanlarını buluttan çek
      DocumentSnapshot doc = await FirebaseFirestore.instance
          .collection('users')
          .doc(userCredential.user!.uid)
          .get();

      // 3. Puanları hafızaya yaz (Başarımlar sıfırlanmasın diye)
      if (doc.exists && doc.data() != null) {
        AppState.resetSession(); // Önceki kullanıcının RAM'deki izlerini temizle

        final data = doc.data() as Map<String, dynamic>;
        AppState.totalEcoToken = (data['token'] ?? 0.0).toDouble();
        AppState.totalMoneySaved = (data['money'] ?? 0.0).toDouble();
        AppState.totalCarbonSaved = (data['carbon'] ?? 0.0).toDouble();
        AppState.totalSpentToken = (data['totalSpentToken'] ?? 0.0).toDouble();
        AppState.totalActivities = (data['totalActivities'] ?? 0) as int;
        AppState.userName = data['name'] ?? 'EcoToken Üyesi';
        AppState.profilePicBase64 = data['profilePicBase64'];
        AppState.hasProfilePicture = AppState.profilePicBase64 != null;
        
        AppState.checkAndUnlockAchievements(silent: true);
      }

      // 4. Ana sayfaya uçur
      if (mounted) {
        Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) => const MainNavigation()));
      }
    } on FirebaseAuthException catch (e) {
      // Hata olursa kullanıcıya göster
      String errorMsg = 'Giriş başarısız.';
      if (e.code == 'user-not-found' || e.code == 'invalid-credential') errorMsg = 'Böyle bir hesap bulunamadı.';
      if (e.code == 'wrong-password') errorMsg = 'Hatalı şifre girdiniz.';
      
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(errorMsg), backgroundColor: Colors.red));
    }
    setState(() => _isLoading = false);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 24.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const SizedBox(height: 60),
              // Logo veya İkon Alanı
              const Icon(
                Icons.eco_rounded,
                size: 80,
                color: Colors.green,
              ),
              const SizedBox(height: 16),
              // Başlıklar
              const Text(
                'EcoToken',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 32,
                  fontWeight: FontWeight.bold,
                  color: Colors.green,
                ),
              ),
              const Text(
                'Yeşil Enerji Dünyasına Giriş Yapın',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 16,
                  color: Colors.grey,
                ),
              ),
              const SizedBox(height: 48),
              // E-posta Giriş Alanı
              TextField(
                controller: _emailController,
                keyboardType: TextInputType.emailAddress,
                onChanged: (value) => setState(() {}),
                decoration: InputDecoration(
                  labelText: 'E-posta Adresi',
                  prefixIcon: const Icon(Icons.email_outlined, color: Colors.green),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: const BorderSide(color: Colors.green, width: 2),
                  ),
                ),
              ),
              const SizedBox(height: 16),
              // Şifre Giriş Alanı
              TextField(
                controller: _passwordController,
                obscureText: true, // Şifreyi gizler
                onChanged: (value) => setState(() {}),
                decoration: InputDecoration(
                  labelText: 'Şifre',
                  prefixIcon: const Icon(Icons.lock_outline, color: Colors.green),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: const BorderSide(color: Colors.green, width: 2),
                  ),
                ),
              ),
              const SizedBox(height: 24),
              // Giriş Yap Butonu (Loading eklendi)
              if (_isLoading)
                const Center(child: CircularProgressIndicator(color: Colors.green))
              else
                ElevatedButton(
                 onPressed: (_emailController.text.trim().isNotEmpty && _passwordController.text.trim().isNotEmpty) 
                      ? _login 
                      : null, // 🔥 Artık doğrudan Firebase fonksiyonunu tetikliyor
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.green,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: const Text(
                    'Giriş Yap',
                    style: TextStyle(fontSize: 18, color: Colors.white, fontWeight: FontWeight.bold),
                  ),
                ),
              const SizedBox(height: 16),
              // Kayıt Ol Yönlendirmesi
                TextButton(
                  onPressed: () {
                    Navigator.push(context, MaterialPageRoute(builder: (context) => const RegisterScreen()));
                  },
                  child: const Text(
                    'Hesabınız yok mu? Şimdi Kayıt Olun',
                    style: TextStyle(color: Colors.green, fontWeight: FontWeight.bold),
                 ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}