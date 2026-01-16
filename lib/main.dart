import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'app/theme/app_colors.dart';
import 'app/modules/welcome/welcome_screen.dart';
import 'app/modules/auth/auth_controller.dart'; // Import AuthController

void main() async {
  // 1. Wajib tambahkan ini karena AuthController pakai SharedPreferences
  WidgetsFlutterBinding.ensureInitialized();

  // 2. Inisialisasi AuthController secara GLOBAL dan PERMANEN
  // Dengan ini, AuthController tidak akan pernah hilang dari memori
  Get.put(AuthController(), permanent: true);

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return GetMaterialApp(
      title: 'Concert Ticket App',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        scaffoldBackgroundColor: AppColors.background,
        primaryColor: AppColors.primary,
        useMaterial3: true,
        textTheme: GoogleFonts.poppinsTextTheme(),
        colorScheme: ColorScheme.dark(
          primary: AppColors.primary,
          surface: AppColors.cardSurface,
          onSurface: AppColors.textPrimary,
        ),
      ),
      home: const WelcomeScreen(),
    );
  }
}