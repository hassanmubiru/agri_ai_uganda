import 'package:flutter/material.dart';
import 'package:agri_ai_uganda/utils/constants.dart';
import 'package:agri_ai_uganda/screens/main_screen.dart';
import 'package:agri_ai_uganda/screens/onboarding_screen.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  runApp(const AgriAIApp());
}

class AgriAIApp extends StatefulWidget {
  const AgriAIApp({super.key});

  @override
  State<AgriAIApp> createState() => _AgriAIAppState();
}

class _AgriAIAppState extends State<AgriAIApp> {
  bool _seenOnboarding = false;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _checkOnboarding();
  }

  Future<void> _checkOnboarding() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      _seenOnboarding = prefs.getBool('seenOnboarding') ?? false;
      _isLoading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const MaterialApp(home: Scaffold(body: Center(child: CircularProgressIndicator())));
    }

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
      home: _seenOnboarding ? const MainScreen() : const OnboardingScreen(),
    );
  }
}
