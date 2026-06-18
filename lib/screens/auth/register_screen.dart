import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:ecotoken_app/app_state.dart'; 
import 'package:flutter/services.dart'; 

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key});

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _isLoading = false;

  // FİREBASE KAYIT OLMA  
  Future<void> _register() async {
    if (_emailController.text.isEmpty || _passwordController.text.isEmpty || _nameController.text.isEmpty) return;

    setState(() => _isLoading = true);
    try {
      // 1. Firebase Auth'a e-posta ve şifre ile kayıt yap
      UserCredential userCredential = await FirebaseAuth.instance.createUserWithEmailAndPassword(
        email: _emailController.text.trim(),
        password: _passwordController.text.trim(),
      );
      
      // 2. Firestore'da kullanıcıya özel UID ile bir cüzdan aç
      await FirebaseFirestore.instance.collection('users').doc(userCredential.user!.uid).set({
        'name': _nameController.text.trim(),
        'token': 0.0,
        'money': 0.0,
        'carbon': 0.0,
        'totalSpentToken': 0.0,
        'totalActivities': 0,  
        'sonIslem': DateTime.now().toIso8601String(),
      });

      // 3. Eski veriler kalmasın diye AppState'i sıfırla
      AppState.totalEcoToken = 0.0;
      AppState.totalMoneySaved = 0.0;
      AppState.totalCarbonSaved = 0.0;
      AppState.totalSpentToken = 0.0;
      AppState.totalActivities = 0;

      // 4. FİREBASE OTOMATİK GİRİŞ YAPTIĞI İÇİN GİZLİCE ÇIKIŞ YAP 
      await FirebaseAuth.instance.signOut();

      // 5. Kullanıcıyı Giriş ekranına geri gönderir
      if (mounted) {
        // Başarılı bildirim mesajı
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Kayıt Başarılı! Şimdi oluşturduğunuz hesapla giriş yapabilirsiniz. 🎉'), 
            backgroundColor: Colors.green
          )
        );
        
  
        Navigator.pop(context); 
      }
    } on FirebaseAuthException catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(e.message ?? 'Kayıt hatası'), backgroundColor: Colors.red));
    }
    setState(() => _isLoading = false);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white, 
        elevation: 0, 
        iconTheme: const IconThemeData(color: Colors.green)
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 24.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const Icon(Icons.person_add_alt_1_rounded, size: 80, color: Colors.green),
              const SizedBox(height: 16),
              const Text(
                'Yeni Hesap Oluştur', 
                textAlign: TextAlign.center, 
                style: TextStyle(fontSize: 32, fontWeight: FontWeight.bold, color: Colors.green)
              ),
              const SizedBox(height: 48),
              
              // Ad Soyad
              TextField(
                controller: _nameController,
                onChanged: (value) => setState(() {}),
                inputFormatters: [
                  FilteringTextInputFormatter.allow(RegExp(r'[a-zA-ZğüşıöçĞÜŞİÖÇ\s]')),
                ],
                decoration: InputDecoration(
                  labelText: 'Ad Soyad', 
                  prefixIcon: const Icon(Icons.person_outline, color: Colors.green), 
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                  focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: const BorderSide(color: Colors.green, width: 2)),
                ),
              ),
              const SizedBox(height: 16),

              // E-posta
              TextField(
                controller: _emailController,
                onChanged: (value) => setState(() {}),
                keyboardType: TextInputType.emailAddress,
                decoration: InputDecoration(
                  labelText: 'E-posta Adresi', 
                  prefixIcon: const Icon(Icons.email_outlined, color: Colors.green), 
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                  focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: const BorderSide(color: Colors.green, width: 2)),
                ),
              ),
              const SizedBox(height: 16),
              
              // Şifre
              TextField(
                controller: _passwordController,
                onChanged: (value) => setState(() {}),
                obscureText: true,
                decoration: InputDecoration(
                  labelText: 'Şifre (En az 6 hane)', 
                  prefixIcon: const Icon(Icons.lock_outline, color: Colors.green), 
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                  focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: const BorderSide(color: Colors.green, width: 2)),
                ),
              ),
              const SizedBox(height: 32),

              // Kayıt Butonu
              if (_isLoading)
                const Center(child: CircularProgressIndicator(color: Colors.green))
              else
                ElevatedButton(
                    onPressed: (_nameController.text.trim().isNotEmpty && 
                    _emailController.text.trim().isNotEmpty && 
                    _passwordController.text.trim().isNotEmpty) 
                    ? _register 
                    : null,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.green, 
                    padding: const EdgeInsets.symmetric(vertical: 16), 
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12))
                  ),
                  child: const Text('Kayıt Ol ve Başla', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.white)),
                ),
            ],
          ),
        ),
      ),
    );
  }
}