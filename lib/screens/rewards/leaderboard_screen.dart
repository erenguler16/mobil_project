import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class LeaderboardScreen extends StatefulWidget {
  const LeaderboardScreen({super.key});

  @override
  State<LeaderboardScreen> createState() => _LeaderboardScreenState();
}

class _LeaderboardScreenState extends State<LeaderboardScreen> {
  // 0: EcoToken, 1: Tasarruf (TL), 2: Karbon (kg)
  int _activeFilterIndex = 0; 

  @override
  Widget build(BuildContext context) {
    String unitLabel = _activeFilterIndex == 0 ? 'EcoToken' : (_activeFilterIndex == 1 ? 'TL' : 'kg');
    String metricKey = _activeFilterIndex == 0 ? 'token' : (_activeFilterIndex == 1 ? 'money' : 'carbon');
    final String? currentUserUid = FirebaseAuth.instance.currentUser?.uid;

    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      appBar: AppBar(
        title: const Text('Liderlik Tablosu 🏆', style: TextStyle(fontWeight: FontWeight.bold)),
        backgroundColor: Colors.green,
        foregroundColor: Colors.white,
        centerTitle: true,
        elevation: 0,
      ),
      body: Column(
        children: [
          // 3'LÜ FİLTRE BUTONLARI
          Container(
            padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
            color: Theme.of(context).cardColor,
            child: Row(
              children: [
                _buildFilterButton(0, 'EcoToken', Icons.spa_rounded),
                const SizedBox(width: 8),
                _buildFilterButton(1, 'Tasarruf', Icons.paid_rounded),
                const SizedBox(width: 8),
                _buildFilterButton(2, 'Karbon', Icons.cloud_queue_rounded),
              ],
            ),
          ),

          // 
          Expanded(
            child: StreamBuilder<QuerySnapshot>(
              stream: FirebaseFirestore.instance.collection('users').snapshots(),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator(color: Colors.green));
                }
                if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
                  return const Center(child: Text('Henüz veri yok.'));
                }

                // 1. Tüm kullanıcıları sadece ve sadece Firebase'den çekiyoruz
                List<Map<String, dynamic>> fullList = [];
                double currentUserValue = 0.0;

                for (var doc in snapshot.data!.docs) {
                  final data = doc.data() as Map<String, dynamic>;
                  bool isMe = doc.id == currentUserUid;

                  double token = (data['token'] ?? 0.0).toDouble();
                  double money = (data['money'] ?? 0.0).toDouble();
                  double carbon = (data['carbon'] ?? 0.0).toDouble();

                  fullList.add({
                    'name': isMe ? '${data['name']}' : data['name'] ?? 'İsimsiz Kahraman',
                    'token': token,
                    'money': money,
                    'carbon': carbon,
                    'isCurrentUser': isMe,
                  });

                  if (isMe) {
                    if (_activeFilterIndex == 0) currentUserValue = token;
                    else if (_activeFilterIndex == 1) currentUserValue = money;
                    else currentUserValue = carbon;
                  }
                }

                // 2. Filtreye göre Büyükten Küçüğe Sırala
                fullList.sort((a, b) => b[metricKey].compareTo(a[metricKey]));

                // 3. Kullanıcının Gerçek Sırasını Listeden Bul
                int currentUserRank = fullList.indexWhere((user) => user['isCurrentUser'] == true) + 1;
                bool isInTop10 = currentUserRank > 0 && currentUserRank <= 10;
                
                // 4. Sadece İlk 10'u Filtrele
                List<Map<String, dynamic>> top10List = fullList.take(10).toList();

                return Column(
                  children: [
                    // İLK 10 LİSTESİ VİZYONU
                    Expanded(
                      child: ListView.builder(
                        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                        itemCount: top10List.length,
                        itemBuilder: (context, index) {
                          final user = top10List[index];
                          final isMe = user['isCurrentUser'] == true;
                          final rank = index + 1;

                          return Card(
                            color: isMe ? Colors.green.withOpacity(0.15) : Theme.of(context).cardColor, // 🔥 Kendi satırının rengi koyu moda uyarlandı
                            elevation: isMe ? 2 : 0,
                            margin: const EdgeInsets.only(bottom: 12),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(16),
                              side: BorderSide(color: isMe ? Colors.green : Colors.grey.withOpacity(0.2), width: isMe ? 1.5 : 1), // 🔥 Çizgi rengi temaya bağlandı
                            ),
                            child: Padding(
                              padding: const EdgeInsets.symmetric(vertical: 8),
                              child: ListTile(
                                leading: _buildRankBadge(rank),
                                title: Text(
                                  user['name'],
                                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: isMe ? Colors.green : null), // 🔥 Sabit siyah renk silindi
                                ),
                                trailing: Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                                  decoration: BoxDecoration(
                                    color: Theme.of(context).scaffoldBackgroundColor, // 🔥 Puan kutusu temaya bağlandı
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                  child: Text(
                                    '${user[metricKey].toStringAsFixed(0)} $unitLabel',
                                    style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13, color: isMe ? Colors.green : null), // 🔥 Sabit siyah renk silindi
                                  ),
                                ),
                              ),
                            ),
                          );
                        },
                      ),
                    ),

                    // ALTTTAKİ SABİT KUTU
                    Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: Theme.of(context).cardColor, // 🔥 Sabit beyaz silindi, temaya bağlandı
                        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 10, offset: const Offset(0, -4))],
                        borderRadius: const BorderRadius.only(topLeft: Radius.circular(20), topRight: Radius.circular(20)),
                      ),
                      child: SafeArea(
                        top: false,
                        child: Row(
                          children: [
                            Container(
                              width: 50,
                              height: 50,
                              decoration: BoxDecoration(
                                color: isInTop10 ? Colors.green : Colors.orange.withOpacity(0.2),
                                shape: BoxShape.circle,
                              ),
                              child: Center(
                                child: Text(
                                  isInTop10 ? '$currentUserRank.' : (currentUserRank == 0 ? '-.' : '10+'),
                                  style: TextStyle(
                                    fontSize: 16, 
                                    fontWeight: FontWeight.bold, 
                                    color: isInTop10 ? Colors.white : Colors.orange[800]
                                  ),
                                ),
                              ),
                            ),
                            const SizedBox(width: 16),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  const Text('Senin Durumun', style: TextStyle(fontSize: 12, color: Colors.grey, fontWeight: FontWeight.bold)),
                                  const SizedBox(height: 2),
                                  Text(
                                        currentUserRank == 1 
                                        ? 'Zirvedesin! Liderlik Tahtı Senin! 👑' 
                                        : (isInTop10 
                                        ? 'Tebrikler, İlk 10\'dasın! 🎉' 
                                        : 'İlk 10\'a girmek için biraz daha gayret!'),
                                        style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold), // 🔥 Sabit siyah renk silindi
                                  ),
                                ],
                              ),
                            ),
                            Text(
                              '${currentUserValue.toStringAsFixed(1)} $unitLabel',
                              style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.green),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  // Özel Filtre Butonu Tasarımı
  Widget _buildFilterButton(int index, String label, IconData icon) {
    bool isActive = _activeFilterIndex == index;
    return Expanded(
      child: GestureDetector(
        onTap: () => setState(() => _activeFilterIndex = index),
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 10),
          decoration: BoxDecoration(
            color: isActive ? Colors.green : Theme.of(context).scaffoldBackgroundColor, // 🔥 Sabit gri silindi, temaya bağlandı
            borderRadius: BorderRadius.circular(10),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(icon, size: 16, color: isActive ? Colors.white : Colors.grey[600]),
              const SizedBox(width: 4),
              Text(label, style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: isActive ? Colors.white : Colors.grey[600])),
            ],
          ),
        ),
      ),
    );
  }


  Widget _buildRankBadge(int rank) {
    if (rank == 1) {
      return Container(
        width: 44,
        height: 44,
        decoration: BoxDecoration(color: Colors.amber.withOpacity(0.2), shape: BoxShape.circle),
        child: const Icon(Icons.emoji_events, color: Colors.amber, size: 24),
      );
    }
    if (rank == 2) {
      return Container(
        width: 44,
        height: 44,
        decoration: BoxDecoration(color: Colors.grey.withOpacity(0.2), shape: BoxShape.circle), // 🔥 Shade yerine opacity kullanıldı, karanlıkta sırıtmaması için
        child: Icon(Icons.workspace_premium, color: Colors.grey.shade500, size: 24),
      );
    }
    if (rank == 3) {
      return Container(
        width: 44,
        height: 44,
        decoration: BoxDecoration(color: Colors.orange.withOpacity(0.2), shape: BoxShape.circle),
        child: Icon(Icons.workspace_premium, color: Colors.brown.shade400, size: 24),
      );
    }
    
    return Container(
      width: 44,
      height: 44,
      decoration: BoxDecoration(color: Theme.of(context).scaffoldBackgroundColor, shape: BoxShape.circle), // 🔥 Sabit gri silindi, temaya bağlandı
      alignment: Alignment.center,
      child: Text('#$rank', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15, color: Colors.grey.shade500)),
    );
  }
}