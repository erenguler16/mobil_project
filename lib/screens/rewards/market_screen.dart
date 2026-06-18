import 'package:flutter/material.dart';
import '../../app_state.dart';

class MarketScreen extends StatefulWidget {
  const MarketScreen({super.key});

  @override
  State<MarketScreen> createState() => _MarketScreenState();
}

class _MarketScreenState extends State<MarketScreen> {
  // 🛒 SEPET HAFIZASI
  List<Map<String, dynamic>> _cart = [];

  // 🛍️ VİTRİNDEKİ ÜRÜNLER VE GERÇEKÇİ FİYATLARI
  final List<Map<String, dynamic>> _products = [
    {'name': 'Kargo İndirimi (%50)', 'price': 80.0, 'icon': Icons.local_shipping_rounded, 'color': Colors.blueGrey},
    {'name': 'Kahve İndirim Kuponu', 'price': 100.0, 'icon': Icons.local_cafe_rounded, 'color': Colors.brown},
    {'name': 'Kitap İndirim Kuponu', 'price': 120.0, 'icon': Icons.menu_book_rounded, 'color': Colors.indigo},
    {'name': '1 Adet Fidan Bağışı', 'price': 150.0, 'icon': Icons.nature_people_rounded, 'color': Colors.green},
    {'name': 'Yemek Kuponu (100 TL)', 'price': 300.0, 'icon': Icons.restaurant_rounded, 'color': Colors.orange},
    {'name': 'Market İndirimi (%20)', 'price': 400.0, 'icon': Icons.shopping_basket_rounded, 'color': Colors.redAccent},
    {'name': 'Steam Cüzdan Kodu', 'price': 500.0, 'icon': Icons.sports_esports_rounded, 'color': Colors.deepPurple},
    {'name': 'Bluetooth Kulaklık', 'price': 1500.0, 'icon': Icons.headphones_rounded, 'color': Colors.blue},
    {'name': 'Kameralı Drone', 'price': 2000.0, 'icon': Icons.flight_takeoff_rounded, 'color': Colors.indigo},
    {'name': 'Güneş Enerjili Powerbank', 'price': 2500.0, 'icon': Icons.solar_power_rounded, 'color': Colors.amber},
    {'name': 'Profesyonel Oyun Kolu', 'price': 3500.0, 'icon': Icons.gamepad_rounded, 'color': Colors.teal},
    {'name': 'Akıllı Saat', 'price': 6000.0, 'icon': Icons.watch_rounded, 'color': Colors.cyan},
    {'name': 'Dizüstü Bilgisayar', 'price': 50000.0, 'icon': Icons.laptop_mac_rounded, 'color': Colors.grey}, // 🔥 Koyu modda siyah ikon kaybolmasın diye griye çekildi
  ];

  // ➕ SEPETE EKLEME FONKSİYONU
  void _addToCart(Map<String, dynamic> product) {
    setState(() {
      _cart.add(product);
    });
    ScaffoldMessenger.of(context).hideCurrentSnackBar();
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('${product['name']} sepete eklendi!'),
        backgroundColor: Colors.green,
        duration: const Duration(seconds: 1),
      ),
    );
  }

  // SEPETTEN ÇIKARMA FONKSİYONU
  void _removeFromCart(int index, StateSetter setModalState) {
    // Hem alt pencereyi (BottomSheet) hem de ana ekranı günceller
    setModalState(() {
      _cart.removeAt(index);
    });
    setState(() {}); // Ana ekrandaki kırmızı rozetteki sayıyı düşürür
  }

  //  SATIN ALMA İŞLEMİ 
  void _checkout() {
    double totalCost = _cart.fold(0, (sum, item) => sum + item['price']);

    if (AppState.totalEcoToken >= totalCost) {
      setState(() {
        AppState.makePurchase(totalCost);
        _cart.clear(); // Sepeti boşalt
      });

      Navigator.pop(context); // Sepet penceresini kapat

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Satın alma başarılı! Doğayı koruduğunuz için teşekkürler. 🌲'),
          backgroundColor: Colors.teal,
          duration: Duration(seconds: 3),
        ),
      );
    } else {
      // Yetersiz Bakiye Uyarısı
      Navigator.pop(context); // Sepet penceresini kapat
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Yetersiz EcoToken! Bu sepet için ${totalCost - AppState.totalEcoToken} Token daha lazım.'),
          backgroundColor: Colors.redAccent,
          duration: const Duration(seconds: 3),
        ),
      );
    }
  }

  //SEPETİ GÖSTEREN ALT PENCERE
  void _showCartBottomSheet() {
    showModalBottomSheet(
      context: context,
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(24))),
      builder: (context) {

        return StatefulBuilder(
          builder: (BuildContext context, StateSetter setModalState) {
            double totalCost = _cart.fold(0, (sum, item) => sum + item['price']);

            return Padding(
              padding: const EdgeInsets.all(20.0),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Text('Alışveriş Sepeti', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
                  const SizedBox(height: 16),
                  
                  // Sepet Boş mu Dolu mu Kontrolü
                  _cart.isEmpty
                      ? const Padding(
                          padding: EdgeInsets.all(20.0),
                          child: Text('Sepetiniz şu an boş.', style: TextStyle(color: Colors.grey, fontSize: 16)),
                        )
                      : Expanded(
                          child: ListView.builder(
                            itemCount: _cart.length,
                            itemBuilder: (context, index) {
                              final item = _cart[index];
                              return ListTile(
                                leading: Icon(item['icon'], color: item['color']),
                                title: Text(item['name'], style: const TextStyle(fontWeight: FontWeight.bold)), // 🔥 Yazı rengi temaya bağlandı
                                subtitle: Text('${item['price']} Token'),
                                trailing: IconButton(
                                  icon: const Icon(Icons.remove_circle, color: Colors.redAccent),
                                  // BAĞLANTI BURADA KURULDU! Artık özel fonksiyonumuzu çağırıyor
                                  onPressed: () => _removeFromCart(index, setModalState),
                                ),
                              );
                            },
                          ),
                        ),
                  
                  const Divider(thickness: 1.5),
                  
                  // Toplam Tutar ve Onay Butonu
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text('Toplam Tutar:', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)), // 🔥 Yazı rengi temaya bağlandı
                      Text('$totalCost Token', style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.green)),
                    ],
                  ),
                  const SizedBox(height: 16),
                  ElevatedButton(
                    onPressed: _cart.isEmpty ? null : _checkout,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.green,
                      minimumSize: const Size.fromHeight(50),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    ),
                    child: const Text('Sepeti Onayla ve Satın Al', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.white)),
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor, 
      appBar: AppBar(
        backgroundColor: Colors.green,
        elevation: 0,

        leadingWidth: 120,
        leading: Padding(
          padding: const EdgeInsets.only(left: 12.0, top: 8, bottom: 8),
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 8),
            decoration: BoxDecoration(color: Colors.white.withOpacity(0.2), borderRadius: BorderRadius.circular(20)),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(Icons.spa_rounded, color: Colors.white, size: 16),
                const SizedBox(width: 4),
                Text(
                  AppState.totalEcoToken.toStringAsFixed(0),
                  style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 14),
                ),
              ],
            ),
          ),
        ),
        title: const Text('Ödül Marketi', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
        centerTitle: true,

        actions: [
          Stack(
            alignment: Alignment.center,
            children: [
              IconButton(
                icon: const Icon(Icons.shopping_cart_rounded, color: Colors.white, size: 28),
                onPressed: _showCartBottomSheet,
              ),
              if (_cart.isNotEmpty)
                Positioned(
                  right: 8,
                  top: 8,
                  child: Container(
                    padding: const EdgeInsets.all(4),
                    decoration: const BoxDecoration(color: Colors.redAccent, shape: BoxShape.circle),
                    child: Text(
                      '${_cart.length}',
                      style: const TextStyle(color: Colors.white, fontSize: 10, fontWeight: FontWeight.bold),
                    ),
                  ),
                ),
            ],
          ),
          const SizedBox(width: 8),
        ],
      ),
      
      // ÜRÜNLERİN VİTRİNİ 
      body: GridView.builder(
        padding: const EdgeInsets.all(16),
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 2,           // Yan yana 2 ürün
          crossAxisSpacing: 16,
          mainAxisSpacing: 16,
          childAspectRatio: 0.75,      // Kartların boy oranı 
        ),
        itemCount: _products.length,
        itemBuilder: (context, index) {
          final product = _products[index];
          return Container(
            decoration: BoxDecoration(
              color: Theme.of(context).cardColor, 
              borderRadius: BorderRadius.circular(16),
              boxShadow: [
                BoxShadow(color: Colors.black.withOpacity(0.04), blurRadius: 8, offset: const Offset(0, 4))
              ],
            ),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                // Üst Kısım: İkon
                Expanded(
                  child: Container(
                    width: double.infinity,
                    decoration: BoxDecoration(
                      color: product['color'].withOpacity(0.1),
                      borderRadius: const BorderRadius.vertical(top: Radius.circular(16)),
                    ),
                    child: Icon(product['icon'], size: 64, color: product['color']),
                  ),
                ),
                // Alt Kısım: Bilgiler ve Buton
                Padding(
                  padding: const EdgeInsets.all(12.0),
                  child: Column(
                    children: [
                      Text(
                        product['name'],
                        textAlign: TextAlign.center,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13), // 🔥 Sabit siyah silindi, temaya bağlandı
                      ),
                      const SizedBox(height: 8),
                      Text(
                        '${product['price']} Token',
                        style: const TextStyle(color: Colors.green, fontWeight: FontWeight.bold, fontSize: 15),
                      ),
                      const SizedBox(height: 12),
                      ElevatedButton(
                        onPressed: () => _addToCart(product),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.green,
                          foregroundColor: Colors.white,
                          minimumSize: const Size.fromHeight(36),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                          elevation: 0,
                        ),
                        child: const Text('Sepete Ekle', style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold)),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}