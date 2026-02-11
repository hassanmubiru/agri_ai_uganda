import 'package:flutter/material.dart';
import 'package:agri_ai_uganda/utils/constants.dart';
// import 'package:agri_ai_uganda/screens/home_screen.dart'; // Will create later

void main() {
  runApp(const AgriAIApp());
}

class AgriAIApp extends StatelessWidget {
  const AgriAIApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: AppStrings.appName,
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        useMaterial3: true,
        colorScheme: ColorScheme.fromSeed(
          seedColor: AppColors.primaryGreen,
          primary: AppColors.primaryGreen,
          secondary: AppColors.earthBrown,
          tertiary: AppColors.accentYellow,
          brightness: Brightness.light,
        ),
      ),
      darkTheme: ThemeData(
        useMaterial3: true,
        colorScheme: ColorScheme.fromSeed(
          seedColor: AppColors.primaryGreen,
          primary: AppColors.primaryGreen,
          secondary: AppColors.earthBrown,
          tertiary: AppColors.accentYellow,
          brightness: Brightness.dark,
        ),
      ),
      themeMode: ThemeMode.system,
      home: const Scaffold(body: Center(child: Text("AgriAI Starting..."))), // Placeholder
    );
  }
}
