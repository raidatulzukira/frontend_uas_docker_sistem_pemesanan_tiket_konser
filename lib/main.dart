import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'app/theme/app_colors.dart';
import 'app/modules/welcome/welcome_screen.dart'; // Nanti kita buat ini

void main() {
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
        textTheme: GoogleFonts.poppinsTextTheme(), // Menggunakan Font Poppins
        colorScheme: ColorScheme.dark(
          primary: AppColors.primary,
          surface: AppColors.cardSurface,
          background: AppColors.background,
        ),
      ),
      home: const WelcomeScreen(),
    );
  }
}