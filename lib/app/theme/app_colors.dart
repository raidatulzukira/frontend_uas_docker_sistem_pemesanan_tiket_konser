import 'package:flutter/material.dart';

class AppColors {
  // Palet dari Canva yang kamu kirim
  static const Color blueGreen = Color(0xFF2C4A52); // Background Utama
  static const Color waterway = Color(0xFF537072);  // Warna Card / Input Field
  static const Color haze = Color(0xFF8E9B97);      // Text Secondary / Icon
  static const Color smog = Color(0xFFF4EBDB);      // Aksen Utama (Tombol/Text Highlight)

  // Mapping ke fungsi aplikasi
  static const Color background = blueGreen; 
  static const Color cardSurface = waterway;
  
  // Warna Utama kita ubah jadi Smog (Cream) agar kontras dengan background gelap
  static const Color primary = smog; 
  
  // Warna Sekunder
  static const Color secondary = Color(0xFFE0C097); // Gold/Cream sedikit gelap untuk variasi
  
  // Text Colors
  static const Color textPrimary = smog;     // Teks Utama jadi terang (Cream)
  static const Color textSecondary = haze;   // Teks kedua abu-abu kehijauan
  
  // Tombol Text (Karena tombolnya warna terang, teks di dalamnya harus gelap)
  static const Color buttonText = blueGreen; 

  static const Color success = Color(0xFF10B981);
  static const Color error = Color(0xFFEF4444);
}