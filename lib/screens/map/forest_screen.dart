import 'package:flutter/material.dart';
import '../../app_state.dart'; 

class ForestSimulationScreen extends StatefulWidget {
  const ForestSimulationScreen({super.key});

  @override
  State<ForestSimulationScreen> createState() => _ForestSimulationScreenState();
}

class _ForestSimulationScreenState extends State<ForestSimulationScreen> {
  @override
  Widget build(BuildContext context) {
    // 1. Kullanıcının güncel karbon tasarrufunu alıyoruz
    double carbon = AppState.totalCarbonSaved;
    

    double displayCarbon = carbon > 200.0 ? 200.0 : carbon;

    // 2. Aşamaları belirleyen dinamik değişkenler
    int stage = 1;
    String message = 'Dünya boğuluyor, harekete geç!';
    String imagePath = 'assets/orman_kotu.jpeg'; // 1. Aşama Resmi
    Color accentColor = Colors.grey;


    if (carbon >= 200) {
      stage = 3;
      message = 'Gezegeni kurtardın!\nŞimdi bu güzelliği koruma zamanı. 🌍';
      imagePath = 'assets/orman_iyi.jpeg'; // 3. Aşama Resmi
      accentColor = Colors.greenAccent; 
    } else if (carbon >= 50) {
      stage = 2;
      message = 'Bulutlar dağılıyor, doğa uyanıyor...\nBöyle devam et! 🌱';
      imagePath = 'assets/orman_orta.jpeg'; // 2. Aşama Resmi
      accentColor = Colors.cyanAccent;
    }

    // İlerleme çubuğu yüzdesi (Maksimum 200'de dolar)
    double progress = (carbon / 200.0).clamp(0.0, 1.0);

    return Scaffold(
      extendBodyBehindAppBar: true, 
      appBar: AppBar(
        // AŞAMA BİLGİSİ
        title: Container(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
          decoration: BoxDecoration(
            color: Colors.black.withOpacity(0.5), 
            borderRadius: BorderRadius.circular(30),
            border: Border.all(color: Colors.white.withOpacity(0.2)),
          ),
          child: Text(
            'Aşama $stage / 3',
            style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.white, fontSize: 16),
          ),
        ),
        backgroundColor: Colors.transparent, // Şeffaf üst bar
        elevation: 0,
        centerTitle: true,
        iconTheme: const IconThemeData(color: Colors.white), // Geri tuşu bembeyaz olsun
      ),
      
      body: Container(
        width: double.infinity,
        height: double.infinity,
        decoration: BoxDecoration(
          color: Colors.black, // Yedek renk
          image: DecorationImage(
            image: AssetImage(imagePath),
            fit: BoxFit.cover,
            colorFilter: ColorFilter.mode(Colors.black.withOpacity(0.35), BlendMode.darken),
          ),
        ),
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.all(24.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.end, 
              children: [
                // HİKAYE METNİ
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.black.withOpacity(0.4),
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Text(
                    message,
                    textAlign: TextAlign.center,
                    style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: Colors.white, height: 1.4),
                  ),
                ),
                const SizedBox(height: 24),

                //  CO2 SAYAÇ VE PROGRESS BAR
                Container(
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    color: Colors.black.withOpacity(0.6), 
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(color: accentColor.withOpacity(0.5), width: 1.5), // Etrafında puanına göre parlayan bir çizgi
                    boxShadow: [
                      BoxShadow(color: Colors.black.withOpacity(0.5), blurRadius: 20, offset: const Offset(0, 10))
                    ],
                  ),
                  child: Column(
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const Text('Kurtarılan Karbon', style: TextStyle(fontWeight: FontWeight.bold, color: Colors.white, fontSize: 15)),
                          
                          Text('${displayCarbon.toStringAsFixed(1)} / 200 kg', style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.white, fontSize: 15)),
                        ],
                      ),
                      const SizedBox(height: 16),
                      ClipRRect(
                        borderRadius: BorderRadius.circular(10),
                        child: LinearProgressIndicator(
                          value: progress,
                          minHeight: 14,
                          backgroundColor: Colors.white.withOpacity(0.2),
                          valueColor: AlwaysStoppedAnimation<Color>(accentColor),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 20), 
              ],
            ),
          ),
        ),
      ),
    );
  }
}