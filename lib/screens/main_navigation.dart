import 'package:flutter/material.dart';
import 'home/panel_screen.dart';        
import 'home/action_screen.dart';       
import 'rewards/leaderboard_screen.dart';  
import 'rewards/achievements_screen.dart'; 
import 'rewards/market_screen.dart';       
import 'map/butterfly_map_screen.dart'; 

class MainNavigation extends StatefulWidget {
  const MainNavigation({super.key});

  
  static _MainNavigationState? of(BuildContext context) =>
      context.findAncestorStateOfType<_MainNavigationState>();

  @override
  State<MainNavigation> createState() => _MainNavigationState();
}

class _MainNavigationState extends State<MainNavigation> {
  int _selectedIndex = 0; 


  void changeTab(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  // Listeyi dinamik çizebilmek için getter yapıyoruz ki her setState'te sayfalar güncel değerleri okusun
  List<Widget> get _screens => [
    const PanelScreen(),        
    const ActionScreen(),       
    const LeaderboardScreen(),  
    const ButterflyMapScreen(), 
    const AchievementsScreen(), 
    const MarketScreen(),       
  ];

  @override
  Widget build(BuildContext context) {
    bool isDark = Theme.of(context).brightness == Brightness.dark;
    return Scaffold(
      body: _screens[_selectedIndex],
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _selectedIndex,
        onTap: (index) {
          changeTab(index);
        },
        type: BottomNavigationBarType.fixed, 
        backgroundColor: isDark ? Colors.grey[900] : Colors.white,
        selectedItemColor: Colors.green, 
        unselectedItemColor: isDark ? Colors.grey[400] : Colors.grey[500],
        selectedLabelStyle: const TextStyle(fontWeight: FontWeight.bold, fontSize: 11),
        unselectedLabelStyle: const TextStyle(fontSize: 11),
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.dashboard_rounded), label: 'Panel'),
          BottomNavigationBarItem(icon: Icon(Icons.add_circle_rounded), label: 'Giriş'),
          BottomNavigationBarItem(icon: Icon(Icons.leaderboard_rounded), label: 'Sıralama'),
          BottomNavigationBarItem(icon: Icon(Icons.map_rounded), label: 'Harita'),
          BottomNavigationBarItem(icon: Icon(Icons.emoji_events_rounded), label: 'Başarım'),
          BottomNavigationBarItem(icon: Icon(Icons.shopping_bag_rounded), label: 'Market'),
        ],
      ),
    );
  }
}