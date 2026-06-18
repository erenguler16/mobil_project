import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'app_state.dart';
import 'screens/auth/login_screen.dart';
import 'screens/main_navigation.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<ThemeMode>(
      valueListenable: AppState.themeNotifier,
      builder: (context, mode, child) {
        return MaterialApp(
          scaffoldMessengerKey: AppState.scaffoldKey,
          title: 'EcoToken',
          debugShowCheckedModeBanner: false,
          themeMode: mode, 
          
      
          theme: ThemeData(
            colorScheme: ColorScheme.fromSeed(seedColor: Colors.green),
            useMaterial3: true,
          ),
          

          darkTheme: ThemeData(
            colorScheme: ColorScheme.fromSeed(
              seedColor: Colors.green, 
              brightness: Brightness.dark,
            ),

            appBarTheme: AppBarTheme(
              backgroundColor: Colors.grey[900],
              foregroundColor: Colors.white,
            ),
            useMaterial3: true,
          ),
          

          home: FirebaseAuth.instance.currentUser == null 
              ? const LoginScreen() 
              : const MainNavigation(),
        );
      },
    );
  }
}