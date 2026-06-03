import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'screens/login_screen.dart';
import 'screens/dashboard_screen.dart';
import 'services/api_service.dart';

void main() {
  runApp(const SmileCraftApp());
}

class SmileCraftApp extends StatelessWidget {
  const SmileCraftApp({super.key});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (context) => ApiService(),
      child: MaterialApp(
        title: 'SmileCraft AI',
        theme: ThemeData(
          primaryColor: const Color(0xFF13B6A5),
          colorScheme: ColorScheme.fromSeed(
            seedColor: const Color(0xFF13B6A5),
            primary: const Color(0xFF13B6A5),
          ),
          appBarTheme: const AppBarTheme(
            backgroundColor: Color(0xFF13B6A5),
            foregroundColor: Colors.white,
          ),
        ),
        home: const AuthWrapper(),
      ),
    );
  }
}

class AuthWrapper extends StatelessWidget {
  const AuthWrapper({super.key});

  @override
  Widget build(BuildContext context) {
    final apiService = Provider.of<ApiService>(context);
    
    return FutureBuilder<String?>(
      future: apiService.getToken(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Scaffold(
            body: Center(child: CircularProgressIndicator()),
          );
        }
        
        if (snapshot.hasData && snapshot.data != null) {
          return const DashboardScreen();
        }
        
        return const LoginScreen();
      },
    );
  }
}