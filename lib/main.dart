// lib/main.dart
import 'package:flutter/material.dart';
import 'package:machine_test_farhathullah/providers/auth_provider.dart';
import 'package:machine_test_farhathullah/providers/product_provider.dart';
import 'package:machine_test_farhathullah/screens/home_screen/home_screen.dart';
import 'package:machine_test_farhathullah/screens/login_screen/login_screen.dart';
import 'package:machine_test_farhathullah/screens/login_screen/login_screen_provider.dart';
import 'package:machine_test_farhathullah/screens/product_detail_screen/product_detail_screen.dart';
import 'package:machine_test_farhathullah/screens/splash_screen/splash_screen.dart';
import 'package:machine_test_farhathullah/services/api_service.dart';
import 'package:machine_test_farhathullah/services/auth_service.dart';
import 'package:machine_test_farhathullah/services/product_service.dart';
import 'package:machine_test_farhathullah/utils/app_constants.dart';
import 'package:provider/provider.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        Provider<ApiService>(create: (_) => ApiService()),
        Provider<AuthService>(create: (_) => AuthService()),
        Provider<ProductService>(
          create: (context) => ProductService(context.read<ApiService>()),
        ),
        ChangeNotifierProvider<AuthProvider>(
          create: (context) => AuthProvider(),
        ),
        ChangeNotifierProvider<ProductProvider>(
          create: (context) => ProductProvider(context.read<ProductService>()),
        ),
        ChangeNotifierProvider<LoginProvider>(
          create: (context) => LoginProvider(),
        ),
      ],
      child: MaterialApp(
        debugShowCheckedModeBanner: false,
        title: AppConstants.appName,
        theme: ThemeData(
          primarySwatch: Colors.deepPurple,
          scaffoldBackgroundColor: Colors.grey[50],
          textTheme: const TextTheme(
            bodyLarge: TextStyle(color: Colors.black87),
            bodyMedium: TextStyle(color: Colors.black87),
          ),
        ),
        initialRoute: '/splash',
        routes: {
          '/splash': (context) => const SplashScreen(),
          '/login': (context) => const LoginScreen(),
          '/home': (context) => const HomeScreen(),
          '/product_detail': (context) => const ProductDetailScreen(),
        },
      ),
    );
  }
}
