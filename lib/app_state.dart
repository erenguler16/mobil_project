import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class AppState {
  static final GlobalKey<ScaffoldMessengerState> scaffoldKey = GlobalKey<ScaffoldMessengerState>();


  static double totalEcoToken = 0.0;
  static double totalCarbonSaved = 0.0;
  static double totalMoneySaved = 0.0; 
  static String userName = "Kullanıcı"; 
  static String? profilePicBase64;
  static ValueNotifier<ThemeMode> themeNotifier = ValueNotifier(ThemeMode.light);
  static List<Map<String, dynamic>> history = [];
  

  static double sunTokens = 0.0;
  static double windTokens = 0.0;
  static double savingTokens = 0.0;   
  static double recycleTokens = 0.0;  
  static double totalSpentToken = 0.0; 
  static int totalActivities = 0;      


  static int totalPurchases = 0;       
  static double totalSpentTokens = 0.0;
  static bool hasProfilePicture = false; 


  static final List<Map<String, dynamic>> achievements = [
     {'id': 'ilk_kivilcim', 'title': 'İlk Kıvılcım', 'desc': 'Sisteme ilk verini girerek yeşil enerji dünyasına adım at.', 'icon': Icons.bolt_rounded, 'color': Colors.amber, 'isUnlocked': false},

    {'id': 'ruzgar_savascisi', 'title': 'Rüzgar Savaşçısı', 'desc': 'Rüzgar enerjisi eylemleriyle 100 EcoToken kazan.', 'icon': Icons.air_rounded, 'color': Colors.blue, 'isUnlocked': false},
    {'id': 'gunes_imparatoru', 'title': 'Güneş İmparatoru', 'desc': 'Güneş paneli girdileriyle 500 EcoToken kazan.', 'icon': Icons.wb_sunny_rounded, 'color': Colors.orange, 'isUnlocked': false},
    {'id': 'enerji_avcisi', 'title': 'Enerji Avcısı', 'desc': 'Elektrik tasarrufundan 500 EcoToken kazan.', 'icon': Icons.electric_bolt_rounded, 'color': Colors.orangeAccent, 'isUnlocked': false},
    {'id': 'ikinci_sans', 'title': 'İkinci Şans', 'desc': 'Geri dönüşümden 100 EcoToken kazan.', 'icon': Icons.recycling_rounded, 'color': Colors.tealAccent, 'isUnlocked': false},

    {'id': 'doga_dostu_ilk_10', 'title': 'Doğa Dostu İlk 10', 'desc': 'Liderlik tablosunda ilk 10 yarışmacı arasına girmeyi başar.', 'icon': Icons.looks_one_rounded, 'color': Colors.purple, 'isUnlocked': false},
    {'id': 'zirve_ortagi', 'title': 'Zirve Ortağı (İlk 5)', 'desc': 'Büyük lig! Liderlik tablosunda ilk 5 arasına adını yazdır.', 'icon': Icons.workspace_premium_rounded, 'color': Colors.teal, 'isUnlocked': false},
    {'id': 'sira_disi_kerata', 'title': 'Sıra Dışı Kerata (1.lik Tahtı)', 'desc': 'Tüm rakiplerini geride bırakarak Liderlik Tablosunda 1. sıraya yerleş!', 'icon': Icons.emoji_events_rounded, 'color': Colors.redAccent, 'isUnlocked': false},

    {'id': 'yesil_baslangic', 'title': 'Yeşil Başlangıç', 'desc': '1000 EcoToken\'e ulaş.', 'icon': Icons.spa_rounded, 'color': Colors.greenAccent, 'isUnlocked': false},
    {'id': 'doganin_dostu', 'title': 'Doğanın Dostu', 'desc': '5000 EcoToken\'e ulaş.', 'icon': Icons.eco_rounded, 'color': Colors.green, 'isUnlocked': false},
    {'id': 'ecotoken_ustasi', 'title': 'EcoToken Ustası', 'desc': '10000 EcoToken\'e ulaş.', 'icon': Icons.stars_rounded, 'color': Colors.amber, 'isUnlocked': false},

    {'id': 'kendini_goster', 'title': 'Kendini Göster', 'desc': 'Profil resmini belirle.', 'icon': Icons.account_circle_rounded, 'color': Colors.blueGrey, 'isUnlocked': false},
    {'id': 'karanlik_mod', 'title': 'Gece Kuşu', 'desc': 'Karanlık moda geçerek OLED ekranda enerji tasarrufu sağladın!', 'icon': Icons.nightlight_round, 'color': Colors.indigo, 'isUnlocked': false},

    {'id': 'ilk_takas', 'title': 'İlk Takas', 'desc': 'Marketten ilk alışverişini yap.', 'icon': Icons.shopping_bag_rounded, 'color': Colors.deepOrange, 'isUnlocked': false},
    {'id': 'yesil_musteri', 'title': 'Yeşil Müşteri', 'desc': 'Markette toplam 1000 EcoToken harca.', 'icon': Icons.add_shopping_cart_rounded, 'color': Colors.blue, 'isUnlocked': false},
    {'id': 'bilincli_tuketici', 'title': 'Bilinçli Tüketici', 'desc': 'Markette toplam 5000 EcoToken harca.', 'icon': Icons.local_mall_rounded, 'color': Colors.purple, 'isUnlocked': false},
    {'id': 'ekonomi_uzmani', 'title': 'Ekonomi Uzmanı', 'desc': 'Markette toplam 10000 EcoToken harca.', 'icon': Icons.paid_rounded, 'color': Colors.red, 'isUnlocked': false},

    {'id': 'birikim_filizi', 'title': 'Birikim Filizi', 'desc': 'En az 5000 TL tasarruf et.', 'icon': Icons.trending_up_rounded, 'color': Colors.lightGreen, 'isUnlocked': false},
    {'id': 'tasarruf_uzmani', 'title': 'Tasarruf Uzmanı', 'desc': 'En az 10000 TL tasarruf et.', 'icon': Icons.account_balance_wallet_rounded, 'color': Colors.green, 'isUnlocked': false},
    {'id': 'yesil_servet', 'title': 'Yeşil Servet', 'desc': 'En az 50000 TL tasarruf et.', 'icon': Icons.monetization_on_rounded, 'color': const Color(0xFFFFD700), 'isUnlocked': false}, // Parlak Altın Sarısı

    {'id': 'orman_muhafizi', 'title': 'Orman Muhafızı', 'desc': 'Kelebek Etkisi haritasında 200 kg CO2 tasarrufuna ulaşarak ormanı tamamen kurtar!', 'icon': Icons.park_rounded, 'color': Colors.green, 'isUnlocked': false},

    {'id': 'gezegenin_koruyucusu', 'title': 'Gezegenin Koruyucusu', 'desc': 'Tüm başarımların kilidini aç.', 'icon': Icons.star_rounded, 'color': Colors.cyan, 'isUnlocked': false},
  ];

  static Future<void> syncToFirebase() async {
    final uid = FirebaseAuth.instance.currentUser?.uid;
    if (uid != null) {
      await FirebaseFirestore.instance.collection('users').doc(uid).update({
        'token': totalEcoToken,
        'money': totalMoneySaved,
        'carbon': totalCarbonSaved,
        'totalSpentToken': totalSpentTokens,
        'totalActivities': totalActivities,
        'sonIslem': DateTime.now().toIso8601String(), 
      });
    }
  }

  static double calculateAndReward(String category, double amount) {
    double carbonSavedPerUnit = 0.0;
    double tokenPerUnit = 0.0;

    switch (category) {
      case 'Güneş Enerjisi': carbonSavedPerUnit = 0.4; tokenPerUnit = 4.0; break;
      case 'Rüzgar Enerjisi': carbonSavedPerUnit = 0.5; tokenPerUnit = 5.0; break;
      case 'Elektrik Tasarrufu': carbonSavedPerUnit = 0.6; tokenPerUnit = 6.0; break;
      case 'Geri Dönüşüm': carbonSavedPerUnit = 0.4 ; tokenPerUnit = 4.0; break;
    }

    double earnedToken = amount * tokenPerUnit;
    
    totalEcoToken += earnedToken;
    totalCarbonSaved += amount * carbonSavedPerUnit;
    totalActivities += 1;

    switch (category) {
      case 'Güneş Enerjisi': sunTokens += earnedToken; break;
      case 'Rüzgar Enerjisi': windTokens += earnedToken; break;
      case 'Elektrik Tasarrufu': savingTokens += earnedToken; break;
      case 'Geri Dönüşüm': recycleTokens += earnedToken; break;
    }

    checkAndUnlockAchievements();
    
    syncToFirebase();

    return earnedToken;
  }

  static void makePurchase(double price) {
    totalPurchases += 1;
    totalSpentTokens += price;
    totalEcoToken -= price; 

    checkAndUnlockAchievements();
    
    syncToFirebase();
  }

  static void updateProfilePicture() {
    hasProfilePicture = true;
    checkAndUnlockAchievements();
  }

  static void checkAndUnlockAchievements({bool silent = false}) {
    int totalTargetOtherAchievements = achievements.length - 1; 

    for (var ach in achievements) {
      if (ach['isUnlocked'] == false) {
        bool shouldUnlock = false;

        switch (ach['id']) {
          // ESKİ BAŞARIMLARIN KONTROLLERİ
          case 'ilk_kivilcim': if (totalEcoToken > 0) shouldUnlock = true; break;
          case 'ruzgar_savascisi': if (windTokens >= 100.0) shouldUnlock = true; break;
          case 'gunes_imparatoru': if (sunTokens >= 500.0) shouldUnlock = true; break;
          case 'doga_dostu_ilk_10': 
            if (totalEcoToken > 40.0 || totalMoneySaved > 80.0 || totalCarbonSaved > 4.0) shouldUnlock = true; 
            break;
          case 'zirve_ortagi': 
            if (totalEcoToken > 450.0 || totalMoneySaved > 950.0 || totalCarbonSaved > 45.0) shouldUnlock = true; 
            break;
          case 'sira_disi_kerata': 
            if (totalEcoToken > 1450.0 || totalMoneySaved > 3200.0 || totalCarbonSaved > 145.0) shouldUnlock = true; 
            break;
          // YENİ BAŞARIMLARIN KONTROLLERİ
          case 'yesil_baslangic': if (totalEcoToken >= 1000.0) shouldUnlock = true; break;
          case 'doganin_dostu': if (totalEcoToken >= 5000.0) shouldUnlock = true; break;
          case 'ecotoken_ustasi': if (totalEcoToken >= 10000.0) shouldUnlock = true; break;
          case 'enerji_avcisi': if (savingTokens >= 500.0) shouldUnlock = true; break;
          case 'ikinci_sans': if (recycleTokens >= 100.0) shouldUnlock = true; break;
          case 'ilk_takas': if (totalPurchases >= 1) shouldUnlock = true; break;
          case 'yesil_musteri': if (totalSpentTokens >= 1000.0) shouldUnlock = true; break;
          case 'bilincli_tuketici': if (totalSpentTokens >= 5000.0) shouldUnlock = true; break;
          case 'ekonomi_uzmani': if (totalSpentTokens >= 10000.0) shouldUnlock = true; break;
          case 'birikim_filizi': if (totalMoneySaved >= 5000.0) shouldUnlock = true; break;
          case 'tasarruf_uzmani': if (totalMoneySaved >= 10000.0) shouldUnlock = true; break;
          case 'yesil_servet': if (totalMoneySaved >= 50000.0) shouldUnlock = true; break;
          case 'kendini_goster': if (hasProfilePicture) shouldUnlock = true; break;
          case 'orman_muhafizi': if (totalCarbonSaved >= 200.0) shouldUnlock = true; break;
          
          case 'gezegenin_koruyucusu':
            int currentlyUnlockedCount = achievements.where((a) => a['isUnlocked'] == true && a['id'] != 'gezegenin_koruyucusu').length;
            if (currentlyUnlockedCount >= totalTargetOtherAchievements) {
              shouldUnlock = true;
            }
            break;
        }

        if (shouldUnlock) {
          ach['isUnlocked'] = true;

          if (ach['id'] == 'orman_muhafizi') {
            totalEcoToken += 1000.0;
            syncToFirebase();
          }

          if (!silent) {
            _showGlobalAchievementPopup(ach);
          }
        }
      }
    }
  }

  static void resetSession() {
    totalEcoToken = 0.0;
    totalCarbonSaved = 0.0;
    totalMoneySaved = 0.0;
    userName = "Kullanıcı";
    profilePicBase64 = null;
    history = [];
    sunTokens = 0.0;
    windTokens = 0.0;
    savingTokens = 0.0;
    recycleTokens = 0.0;
    totalSpentToken = 0.0;
    totalActivities = 0;
    totalPurchases = 0;
    totalSpentTokens = 0.0;
    hasProfilePicture = false;
    themeNotifier.value = ThemeMode.light;
    // Tüm başarımları tekrar kilitli duruma getir
    for (var ach in achievements) {
      ach['isUnlocked'] = false;
    }
  }

  static void _showGlobalAchievementPopup(Map<String, dynamic> ach) {
    final context = scaffoldKey.currentContext;
    if (context == null) return;
    final screenHeight = MediaQuery.of(context).size.height;

    scaffoldKey.currentState?.showSnackBar(
      SnackBar(
        elevation: 10,
        backgroundColor: Colors.white,
        behavior: SnackBarBehavior.floating,
        margin: EdgeInsets.only(bottom: screenHeight - 160, left: 16, right: 16),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
          side: BorderSide(color: Colors.green.withOpacity(0.5), width: 1.5),
        ),
        content: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(color: ach['color'].withOpacity(0.15), borderRadius: BorderRadius.circular(12)),
              child: Icon(ach['icon'], color: ach['color'], size: 32),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text('YENİ BAŞARIM KİLİDİ AÇILDI! 🏆', style: TextStyle(color: Colors.green, fontSize: 12, fontWeight: FontWeight.bold)),
                  Text(ach['title'], style: const TextStyle(color: Colors.black87, fontWeight: FontWeight.bold, fontSize: 16)),
                ],
              ),
            ),
          ],
        ),
        duration: const Duration(seconds: 4),
      ),
    );
  }
}