import 'package:flutter/material.dart';
import '../../app_state.dart';

class AchievementsScreen extends StatelessWidget {
  const AchievementsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final achievements = AppState.achievements;
    
    // Doğru kilit açılma sayısını merkezi hafızadan hesaplıyoruz
    int unlockedCount = achievements.where((ach) => ach['isUnlocked'] == true).length;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Başarımlar', style: TextStyle(fontWeight: FontWeight.bold)),
        backgroundColor: Colors.green,
        foregroundColor: Colors.white,
        centerTitle: true,
      ),
      body: Column(
        children: [
        
          Container(
            padding: const EdgeInsets.all(16),
            color: Theme.of(context).cardColor,
            child: Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Tamamlanan Başarımlar: $unlockedCount / ${achievements.length}',
                        style: const TextStyle(fontWeight: FontWeight.bold),
                      ),
                      const SizedBox(height: 8),
                      LinearProgressIndicator(
                        value: achievements.isEmpty ? 0 : unlockedCount / achievements.length,
                        backgroundColor: Colors.grey[200],
                        color: Colors.green,
                        minHeight: 10,
                        borderRadius: BorderRadius.circular(5),
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 16),
                Text(
                  achievements.isEmpty 
                      ? '0.0%' 
                      : '${((unlockedCount / achievements.length) * 100).toStringAsFixed(1)}%',
                  style: const TextStyle(color: Colors.green, fontSize: 18, fontWeight: FontWeight.bold),
                ),
              ],
            ),
          ),
          
          
          Expanded(
            child: ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: achievements.length,
              itemBuilder: (context, index) {
                final ach = achievements[index];
                final isUnlocked = ach['isUnlocked'] as bool;

                return Container(
                  margin: const EdgeInsets.only(bottom: 12),
                  decoration: BoxDecoration(
                    color: isUnlocked ? Theme.of(context).cardColor : Colors.grey.withOpacity(0.2),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color: isUnlocked ? Colors.green.withOpacity(0.4) : Colors.grey.withOpacity(0.2),
                      width: isUnlocked ? 1.5 : 1,
                    ),
                    boxShadow: isUnlocked ? [
                      BoxShadow(color: Colors.black.withOpacity(0.04), blurRadius: 6, offset: const Offset(0, 2))
                    ] : [],
                  ),
                  child: ListTile(
                    contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                    leading: Container(
                      width: 48,
                      height: 48,
                      decoration: BoxDecoration(
                        color: isUnlocked ? ach['color'].withOpacity(0.15) : Colors.grey[400],
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Icon(
                        isUnlocked ? ach['icon'] : Icons.lock_outline, 
                        color: isUnlocked ? ach['color'] : Colors.grey[600],
                        size: 26,
                      ),
                    ),
                    title: Text(
                      ach['title'],
                      style: TextStyle(
                        color: isUnlocked ? null : Colors.grey[600],
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                      ),
                    ),
                    subtitle: Padding(
                      padding: const EdgeInsets.only(top: 4.0),
                      child: Text(
                        ach['desc'],
                        style: TextStyle(
                          color: isUnlocked ? null : Colors.grey[500],
                          fontSize: 13,
                        ),
                      ),
                    ),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}