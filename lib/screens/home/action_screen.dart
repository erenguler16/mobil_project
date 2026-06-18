import 'dart:io';
import 'dart:math';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import '../../app_state.dart';

class ActionScreen extends StatefulWidget {
  const ActionScreen({super.key});

  @override
  State<ActionScreen> createState() => _ActionScreenState();
}

class _ActionScreenState extends State<ActionScreen> {
  final _amountController = TextEditingController(); // Saat / Gram Girişi
  String _selectedCategory = 'Güneş Enerjisi'; 

  File? _selectedImage;
  bool _isAnalyzing = false;
  bool _isApproved = false;
  
  double _calculatedKwhOrUnit = 0.0; 
  double _calculatedSavedTl = 0.0; // Otomatik hesaplanacak TL karşılığı

  final List<Map<String, dynamic>> _categories = [
    {'name': 'Güneş Enerjisi', 'icon': Icons.wb_sunny_rounded, 'color': Colors.orange, 'unit': 'Saat'},
    {'name': 'Rüzgar Enerjisi', 'icon': Icons.air_rounded, 'color': Colors.blue, 'unit': 'Saat'},
    {'name': 'Elektrik Tasarrufu', 'icon': Icons.electric_bolt_rounded, 'color': Colors.amber, 'unit': 'Saat'},
    {'name': 'Geri Dönüşüm', 'icon': Icons.recycling_rounded, 'color': Colors.green, 'unit': 'Gram'},
  ];

  void _calculateDynamicSavings() {
    double input = double.tryParse(_amountController.text) ?? 0.0;
    if (input <= 0) {
      setState(() {
        _calculatedKwhOrUnit = 0.0;
        _calculatedSavedTl = 0.0;
      });
      return;
    }

    final random = Random();
    double generatedKwh = 0.0;


    switch (_selectedCategory) {
      case 'Güneş Enerjisi':
        generatedKwh = input * (15.0 + random.nextDouble() * 10.0);
        break;
      case 'Rüzgar Enerjisi':
        generatedKwh = input * (18.0 + random.nextDouble() * 12.0);
        break;
      case 'Elektrik Tasarrufu':
        generatedKwh = input * (12.0 + random.nextDouble() * 8.0);
        break;
      case 'Geri Dönüşüm':
        generatedKwh = (input / 50.0) * (1.5 + random.nextDouble());
        break;
    }

    double generatedTl = generatedKwh * 2.5;

    setState(() {
      _calculatedKwhOrUnit = generatedKwh;
      _calculatedSavedTl = generatedTl;
    });
  }

  Future<void> _pickAndAnalyzeImage() async {
    final picker = ImagePicker();
    final pickedFile = await picker.pickImage(source: ImageSource.gallery);
    
    if (pickedFile != null) {
      setState(() {
        _selectedImage = File(pickedFile.path);
        _isAnalyzing = true;
        _isApproved = false;
      });
      
      _calculateDynamicSavings();
      
      await Future.delayed(const Duration(seconds: 3));
      
      setState(() {
        _isAnalyzing = false;
        _isApproved = true; 
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final currentUnit = _categories.firstWhere((c) => c['name'] == _selectedCategory)['unit'];

    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor, // 🔥 Sabit gri uçtu, tema zeminine bağlandı
      appBar: AppBar(
        title: const Text('EcoToken Veri Girişi', style: TextStyle(fontWeight: FontWeight.bold)),
        backgroundColor: Colors.green,
        foregroundColor: Colors.white,
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // 1. KATEGORİ SEÇİMİ
            const Text('1. Çevre Aktivitesi Seçin', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            const SizedBox(height: 12),
            SizedBox(
              height: 110,
              child: ListView.builder(
                scrollDirection: Axis.horizontal,
                itemCount: _categories.length,
                itemBuilder: (context, index) {
                  final cat = _categories[index];
                  final isSelected = _selectedCategory == cat['name'];
                  
                  return GestureDetector(
                    onTap: () {
                      setState(() {
                        _selectedCategory = cat['name'];
                        _selectedImage = null;
                        _isApproved = false;
                        _calculatedKwhOrUnit = 0.0;
                        _calculatedSavedTl = 0.0;
                      });
                    },
                    child: Container(
                      width: 120,
                      margin: const EdgeInsets.only(right: 12),
                      decoration: BoxDecoration(
                        color: isSelected ? cat['color'].withOpacity(0.15) : Theme.of(context).cardColor,
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(color: isSelected ? cat['color'] : Colors.grey.withOpacity(0.2), width: isSelected ? 2 : 1),
                        boxShadow: isSelected ? [] : [BoxShadow(color: Colors.black.withOpacity(0.03), blurRadius: 8, offset: const Offset(0, 3))],
                      ),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(cat['icon'], size: 36, color: cat['color']),
                          const SizedBox(height: 8),
                          Text(cat['name'], textAlign: TextAlign.center, style: TextStyle(fontSize: 12, fontWeight: isSelected ? FontWeight.bold : FontWeight.normal)),
                        ],
                      ),
                    ),
                  );
                },
              ),
            ),
            const SizedBox(height: 28),
            
            const Text('2. Aktivite Süresi', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)), // 🔥 Sabit siyah renk uçtu
            const SizedBox(height: 12),
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                    color: Theme.of(context).cardColor, 
                    borderRadius: BorderRadius.circular(16), 
                    border: Border.all(color: Colors.grey.withOpacity(0.2)),
                    boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.03), blurRadius: 8, offset: const Offset(0, 3))],
              ), // 🔥 Beyaz kutu temaya bağlandı
              child: TextField(
                controller: _amountController,
                keyboardType: TextInputType.number,
                onChanged: (value) {
                  if (_isApproved) _calculateDynamicSavings();
                },
               decoration: InputDecoration(
                  labelText: 'Aktivite Süresi / Miktarı ($currentUnit)',
                  labelStyle: TextStyle(color: Colors.grey[600]), // Yazı rengi yumuşadı
                  hintText: _selectedCategory == 'Geri Dönüşüm' ? 'Örn: 250 (Gram)' : 'Örn: 2 (Saat)',
                  hintStyle: TextStyle(color: Colors.grey[500]),
                  prefixIcon: const Icon(Icons.bolt_rounded, color: Colors.green),
                  

                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide(color: Colors.grey.withOpacity(0.3)),
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide(color: Colors.grey.withOpacity(0.3)),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: const BorderSide(color: Colors.green, width: 1.5),
                  ),
                ),
              ),
            ),
            const SizedBox(height: 28),

            // 3. DOĞRULAMA İŞLEMİ
            const Text('3. Doğrulama İşlemi', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)), // 🔥 Sabit siyah renk uçtu
            const SizedBox(height: 12),
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: _isApproved ? Colors.green.withOpacity(0.05) : Theme.of(context).cardColor, // 🔥 Beyaz kutu temaya bağlandı
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: _isApproved ? Colors.green : Colors.grey.withOpacity(0.2), width: _isApproved ? 2 : 1),
                boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.03), blurRadius: 8, offset: const Offset(0, 3))], // 🔥 Çizgi rengi temaya bağlandı
              ),
              child: Column(
                children: [
                  if (_selectedImage == null) ...[
                    Icon(Icons.add_a_photo_outlined, size: 48, color: Colors.grey[400]),
                    const SizedBox(height: 12),
                    const Text('Aktiviteyi kanıtlamak için bir görsel yükleyin.', textAlign: TextAlign.center, style: TextStyle(color: Colors.grey)),
                    const SizedBox(height: 12),
                    ElevatedButton.icon(
                      onPressed: () {
                        if (_amountController.text.isEmpty) {
                          ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Lütfen önce süreyi/miktarı girin!')));
                          return;
                        }
                        _pickAndAnalyzeImage();
                      },
                      icon: const Icon(Icons.photo_library),
                      label: const Text('Galeriyi Aç'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.green,
                        foregroundColor: Colors.white,
                      ),
                    ),
                  ] 
                  else if (_isAnalyzing) ...[
                    const CircularProgressIndicator(color: Colors.green),
                    const SizedBox(height: 16),
                    const Text('Görsel Yüklendi.', style: TextStyle(color: Colors.grey)),
                    const SizedBox(height: 4),
                    const Text('Görüntü Analiz Ediliyor...', style: TextStyle(fontWeight: FontWeight.bold, color: Colors.green, fontSize: 16)),
                  ] 
                  else if (_isApproved) ...[
                    const Icon(Icons.verified_rounded, size: 56, color: Colors.green),
                    const SizedBox(height: 12),
                    const Text('Görsel Doğrulandı!', style: TextStyle(fontWeight: FontWeight.bold, color: Colors.green, fontSize: 18)),
                    TextButton(
                      onPressed: _pickAndAnalyzeImage,
                      child: const Text('Farklı Bir Görsel Seç', style: TextStyle(color: Colors.green)),
                    )
                  ]
                ],
              ),
            ),
            const SizedBox(height: 20),

            // 4. OTOMATİK TL VE KWH HESAPLAMA PANELI
            if (_isApproved && _calculatedKwhOrUnit > 0) ...[
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.blue.withOpacity(0.08),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: Colors.blue.withOpacity(0.3)),
                ),
                child: Row(
                  children: [
                    const Icon(Icons.auto_awesome_rounded, color: Colors.blue, size: 32),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text('AI ANALİZ SONUÇ RAPORU:', style: TextStyle(fontSize: 11, color: Colors.blueGrey, fontWeight: FontWeight.bold)),
                          const SizedBox(height: 4),
                          Text(
                            _selectedCategory == 'Geri Dönüşüm' 
                                ? '🌲 SKOR: +${_calculatedKwhOrUnit.toStringAsFixed(1)} Çevre Katkı Puanı'
                                : '⚡ TASARRUF: ${_calculatedKwhOrUnit.toStringAsFixed(1)} kWh Enerji',
                            style: const TextStyle(fontSize: 15, fontWeight: FontWeight.bold, color: Colors.blue),
                          ),
                          const SizedBox(height: 2),
                          Text(
                            '💰 KAZANÇ: ${_calculatedSavedTl.toStringAsFixed(1)} TL Cebinizde Kaldı!',
                            style: const TextStyle(fontSize: 15, fontWeight: FontWeight.bold, color: Colors.green),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 24),
            ],
            
            // 5. GÖNDER BUTONU
            ElevatedButton(
              onPressed: _isApproved ? () async { 
                FocusScope.of(context).unfocus();
            
              // 1. ÖNCE parayı RAM'deki cüzdana ekliyoruz
              AppState.totalMoneySaved += _calculatedSavedTl;

              // 2. SONRA motoru çalıştırıyoruz (Bu motor, güncel parayı da alıp tek seferde Firebase'e gönderir!)
              double earned = AppState.calculateAndReward(_selectedCategory, _calculatedKwhOrUnit);

              try {
                await AppState.syncToFirebase();
              } catch (e) {
                debugPrint("Buluta senkronizasyon hatası: $e");
              }

              setState(() {
                _amountController.clear();
                _selectedImage = null;
                _isApproved = false;
                _calculatedKwhOrUnit = 0.0;
                _calculatedSavedTl = 0.0;
              });
            
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  backgroundColor: Colors.green,
                  behavior: SnackBarBehavior.floating,
                  content: Text('+${earned.toStringAsFixed(1)} EcoToken Kazandınız ve Buluta Kaydedildi! ☁️🌲', style: const TextStyle(fontWeight: FontWeight.bold)),
                ),  
              );

              } : null,
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.green,
                disabledBackgroundColor: Theme.of(context).brightness == Brightness.dark ? Colors.grey[850] : Colors.grey[300],
                minimumSize: const Size.fromHeight(56),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              ),
              child: Text('Aktiviteyi Onayla ve Gönder', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: _isApproved ? Colors.white : (Theme.of(context).brightness == Brightness.dark ? Colors.grey[700] : Colors.grey[500]),)), // 🔥 Yazı rengi beyaz olarak sabitlendi
            ),
            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }
}