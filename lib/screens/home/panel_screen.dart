import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart'; 
import '../../app_state.dart';
import '../auth/login_screen.dart'; 
import 'package:firebase_auth/firebase_auth.dart'; 
import 'dart:convert';
import 'package:cloud_firestore/cloud_firestore.dart';

class PanelScreen extends StatefulWidget {
  const PanelScreen({super.key});

  @override
  State<PanelScreen> createState() => _PanelScreenState();
}

class _PanelScreenState extends State<PanelScreen> {
  String get _userFullName => AppState.userName;
  File? _profileImage; 

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    setState(() {});
  }

  // KAMERA VEYA GALERİDEN RESİM ÇEKME FONKSİYONU
  Future<void> _pickImage(ImageSource source) async {
    final picker = ImagePicker();
    try {
      final pickedFile = await picker.pickImage(
        source: source,
        maxWidth: 500, 
        maxHeight: 500,
        imageQuality: 80, 
      );

      if (pickedFile != null) {
        // 1. Resmi dosyadan oku ve Base64 metnine çevir
        final bytes = await File(pickedFile.path).readAsBytes();
        final base64String = base64Encode(bytes);

        setState(() {
          _profileImage = File(pickedFile.path);
          AppState.profilePicBase64 = base64String;
        });

        // 2. Buluta (Firestore'a) kullanıcının dokümanına kaydet
        final uid = FirebaseAuth.instance.currentUser?.uid;
        if (uid != null) {
          await FirebaseFirestore.instance.collection('users').doc(uid).update({
            'profilePicBase64': base64String,
          });
        }

        AppState.updateProfilePicture();
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Resim seçilirken bir hata oluştu: $e')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final double currentTokens = AppState.totalEcoToken;
    final double currentCarbon = AppState.totalCarbonSaved;
    final double currentMoney = AppState.totalMoneySaved;

    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor, 
      appBar: AppBar(
        title: const Text('Ana Panel', style: TextStyle(fontWeight: FontWeight.bold)),
        backgroundColor: Colors.green,
        foregroundColor: Colors.white,
        centerTitle: true,
        elevation: 0,
        actions: [
          ValueListenableBuilder<ThemeMode>(
            valueListenable: AppState.themeNotifier,
            builder: (context, mode, child) {
              bool isDark = mode == ThemeMode.dark;
              return IconButton(
                icon: Icon(isDark ? Icons.light_mode : Icons.dark_mode, color: isDark ? Colors.amber : Colors.indigo),
                tooltip: 'Karanlık Mod',
                onPressed: () {
                  // 1. Temayı Değiştir
                  AppState.themeNotifier.value = isDark ? ThemeMode.light : ThemeMode.dark;


                  var achIndex = AppState.achievements.indexWhere((a) => a['id'] == 'karanlik_mod');
                  if (achIndex != -1 && !AppState.achievements[achIndex]['isUnlocked'] && !isDark) {
                    AppState.achievements[achIndex]['isUnlocked'] = true;
                    AppState.totalEcoToken += 50.0;
                    AppState.syncToFirebase(); // Tokeni ve başarımı buluta mühürle
                    
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('🌙 Gece Kuşu Başarımı Açıldı! Enerji Tasarrufu için +50 EcoToken!'),
                        backgroundColor: Colors.indigo,
                      ),
                    );
                  }
                },
              );
            }
          ),
          
          // MEVCUT ÇIKIŞ YAP BUTONU 
          IconButton(
            icon: const Icon(Icons.logout_rounded),
            tooltip: 'Çıkış Yap',
            onPressed: () async {
              // Firebase'den çıkmadan önce RAM'i temiz yap
              AppState.resetSession(); 

              // 1. Firebase oturumunu kapat
              await FirebaseAuth.instance.signOut();
              
              // 2. Kullanıcıyı giriş ekranına gönder ve geri tuşunu iptal et
              if (context.mounted) {
                Navigator.pushAndRemoveUntil(
                  context,
                  MaterialPageRoute(builder: (context) => const LoginScreen()),
                  (route) => false,
                );
              }
            },
          ),
        ],
      ),    
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [

            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Theme.of(context).cardColor, // Temaya uyumlu
                borderRadius: BorderRadius.circular(16),
                boxShadow: [
                  BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 6, offset: const Offset(0, 3))
                ],
              ),
              child: Row(
                children: [
                  GestureDetector(
                    onTap: () => _showAvatarPicker(context),
                    child: Stack(
                      alignment: Alignment.bottomRight,
                      children: [
                        CircleAvatar(
                          radius: 44, 
                          backgroundColor: Colors.green.withOpacity(0.15),
                          backgroundImage: _profileImage != null 
                              ? FileImage(_profileImage!) 
                              : (AppState.profilePicBase64 != null 
                                  ? MemoryImage(base64Decode(AppState.profilePicBase64!)) 
                                  : null) as ImageProvider?,
                          child: (_profileImage == null && AppState.profilePicBase64 == null)
                              ? const Icon(Icons.person_rounded, size: 52, color: Colors.green)
                              : null,
                        ),
                        Container(
                          padding: const EdgeInsets.all(5),
                          decoration: const BoxDecoration(color: Colors.green, shape: BoxShape.circle),
                          child: const Icon(Icons.add_a_photo_rounded, size: 14, color: Colors.white),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 18),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(_userFullName, style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold)),
                        const SizedBox(height: 4),
                        const Text('Doğa Dostu Kahraman 🌲', style: TextStyle(fontSize: 14, color: Colors.grey, fontWeight: FontWeight.w600)),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 28),


            const Text('Güncel Cüzdan', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            const SizedBox(height: 12),
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [Colors.green, Colors.teal],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.circular(20),
                boxShadow: [
                  BoxShadow(color: Colors.green.withOpacity(0.3), blurRadius: 10, offset: const Offset(0, 5))
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(color: Colors.white.withOpacity(0.2), borderRadius: BorderRadius.circular(10)),
                        child: const Icon(Icons.spa_rounded, color: Colors.white, size: 24),
                      ),
                      const SizedBox(width: 12),
                      const Text('Toplam EcoToken', style: TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.w600)),
                    ],
                  ),
                  const SizedBox(height: 16),
                  Text(
                    currentTokens.toStringAsFixed(1),
                    style: const TextStyle(color: Colors.white, fontSize: 44, fontWeight: FontWeight.bold, letterSpacing: 1.0),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 28),


            const Text('Çevresel ve Ekonomik Etki', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            const SizedBox(height: 12),
            Row(
              children: [
                // TL Tasarruf Kartı
                Expanded(
                  child: Container(
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      color: Theme.of(context).cardColor,
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(color: Colors.grey.withOpacity(0.2)),
                      boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.03), blurRadius: 8, offset: const Offset(0, 3))],
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Container(
                          padding: const EdgeInsets.all(10),
                          decoration: BoxDecoration(color: Colors.blue.withOpacity(0.1), shape: BoxShape.circle),
                          child: const Icon(Icons.account_balance_wallet_rounded, color: Colors.blue, size: 28),
                        ),
                        const SizedBox(height: 16),
                        const Text('Cebinizde Kalan', style: TextStyle(color: Colors.grey, fontSize: 13, fontWeight: FontWeight.w600)),
                        const SizedBox(height: 4),
                        Text('${currentMoney.toStringAsFixed(1)} ₺', style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
                      ],
                    ),
                  ),
                ),
                const SizedBox(width: 16),
                // Karbon Tasarruf Kartı
                Expanded(
                  child: Container(
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      color: Theme.of(context).cardColor,
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(color: Colors.grey.withOpacity(0.2)),
                      boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.03), blurRadius: 8, offset: const Offset(0, 3))],
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Container(
                          padding: const EdgeInsets.all(10),
                          decoration: BoxDecoration(color: Colors.orange.withOpacity(0.1), shape: BoxShape.circle),
                          child: const Icon(Icons.co2_rounded, color: Colors.orange, size: 28),
                        ),
                        const SizedBox(height: 16),
                        const Text('Önlenen Karbon', style: TextStyle(color: Colors.grey, fontSize: 13, fontWeight: FontWeight.w600)),
                        const SizedBox(height: 4),
                        Text('${currentCarbon.toStringAsFixed(1)} kg', style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
                      ],
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 32),
          ],
        ),
      ),
    );
  }

  void _showAvatarPicker(BuildContext context) {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(20))),
      builder: (context) {
        return Padding(
          padding: const EdgeInsets.all(20.0),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text('Profil Resmi Belirle', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
              const SizedBox(height: 20),
              ListTile(
                leading: const Icon(Icons.photo_library_rounded, color: Colors.green),
                title: const Text('Galeriden Seç'),
                onTap: () {
                  Navigator.pop(context);
                  _pickImage(ImageSource.gallery); 
                },
              ),
              ListTile(
                leading: const Icon(Icons.camera_alt_rounded, color: Colors.green),
                title: const Text('Kamera ile Çek'),
                onTap: () {
                  Navigator.pop(context);
                  _pickImage(ImageSource.camera); 
                },
              ),
            ],
          ),
        );
      },
    );
  }
}