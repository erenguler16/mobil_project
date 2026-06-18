import 'package:flutter/material.dart';
import 'forest_screen.dart'; 

class ButterflyMapScreen extends StatelessWidget {
  const ButterflyMapScreen({super.key});

  @override
  Widget build(BuildContext context) {
    // Haritadaki bölümlerin listesi
    final List<Map<String, dynamic>> stages = [
      {'id': 1, 'title': 'Orman Muhafızı', 'icon': Icons.park_rounded, 'isUnlocked': true, 'color': Colors.green},
      {'id': 2, 'title': 'Kirli Okyanus', 'icon': Icons.water_drop_rounded, 'isUnlocked': false, 'color': Colors.blue},
      {'id': 3, 'title': 'Kurak Vadiler', 'icon': Icons.landscape_rounded, 'isUnlocked': false, 'color': Colors.orange},
      {'id': 4, 'title': 'Zehirli Şehir', 'icon': Icons.location_city_rounded, 'isUnlocked': false, 'color': Colors.grey},
      {'id': 5, 'title': 'Buzul Kurtarılışı', 'icon': Icons.ac_unit_rounded, 'isUnlocked': false, 'color': Colors.cyan},
    ];

    bool isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      appBar: AppBar(
        title: const Text('Kelebek Etkisi', style: TextStyle(fontWeight: FontWeight.bold)),
        backgroundColor: Colors.green,
        foregroundColor: Colors.white,
        centerTitle: true,
      ),

      body: ListView.builder(
        padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 20),
        itemCount: stages.length,
        itemBuilder: (context, index) {
          final stage = stages[index];
          final isEven = index % 2 == 0; 
          
          return Stack(
            alignment: Alignment.center,
            children: [
              Positioned.fill(
                child: CustomPaint(
                  painter: WavyMapPainter(
                    isEven: isEven,
                    pathColor: isDark ? Colors.grey[800]! : Colors.grey[300]!,
                  ),
                ),
              ),

              // BÖLÜM KARTLARI
              Container(
                margin: const EdgeInsets.only(bottom: 60, top: 10), // Yolun kıvrılması için mesafe
                alignment: isEven ? Alignment.centerLeft : Alignment.centerRight,
                child: FractionallySizedBox(
                  widthFactor: 0.6, // Ekranın %60'ını kaplasın
                  child: GestureDetector(
                    onTap: () {
                      if (stage['isUnlocked']) {
                        Navigator.push(
                          context,
                          MaterialPageRoute(builder: (context) => const ForestSimulationScreen()),
                        );
                      } else {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text('🔒 ${stage['title']} Bölgesi Çok Yakında Eklenecek!'),
                            backgroundColor: Colors.orange[800],
                            behavior: SnackBarBehavior.floating,
                          ),
                        );
                      }
                    },
                    child: Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                       
                        color: stage['isUnlocked'] ? Theme.of(context).cardColor : (isDark ? Colors.grey[850] : Colors.grey[200]),
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(
                          color: stage['isUnlocked'] ? stage['color'] : Colors.grey[500]!,
                          width: stage['isUnlocked'] ? 3 : 1,
                        ),
                        boxShadow: stage['isUnlocked'] 
                            ? [BoxShadow(color: stage['color'].withOpacity(0.3), blurRadius: 10, offset: const Offset(0, 4))] 
                            : [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 6, offset: const Offset(0, 3))],
                      ),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Container(
                            padding: const EdgeInsets.all(12),
                            decoration: BoxDecoration(
                              color: stage['isUnlocked'] ? stage['color'].withOpacity(0.1) : Colors.grey[400]?.withOpacity(0.3),
                              shape: BoxShape.circle,
                            ),
                            child: Icon(
                              stage['isUnlocked'] ? stage['icon'] : Icons.lock_rounded,
                              color: stage['isUnlocked'] ? stage['color'] : Colors.grey[500],
                              size: 32,
                            ),
                          ),
                          const SizedBox(height: 12),
                          Text(
                            stage['title'],
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.bold,
                              color: stage['isUnlocked'] ? null : Colors.grey[500],
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            stage['isUnlocked'] ? 'Açık' : 'Kilitli',
                            style: TextStyle(
                              fontSize: 12,
                              color: stage['isUnlocked'] ? Colors.green : Colors.grey[500],
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}


class WavyMapPainter extends CustomPainter {
  final bool isEven;
  final Color pathColor;

  WavyMapPainter({required this.isEven, required this.pathColor});

  @override
  void paint(Canvas canvas, Size size) {
    Paint paint = Paint()
      ..color = pathColor
      ..strokeWidth = 10 // Yolun kalınlığı
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round;

    Path path = Path();

    path.moveTo(size.width / 2, 0);

    double controlX = isEven ? (size.width / 2) - 100 : (size.width / 2) + 100;
    
    // Yolu kıvırıp bir sonraki satırın ortasına kusursuzca bağlar
    path.quadraticBezierTo(controlX, size.height / 2, size.width / 2, size.height);

    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}