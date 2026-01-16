import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:frontend_uas_docker_sistem_pemesanan_tiket_konser/app/modules/home/home_view.dart';
import 'package:get/get.dart';
import '../../theme/app_colors.dart';
import '../auth/login_view.dart';
import '../auth/register_view.dart';

class WelcomeScreen extends StatelessWidget {
  const WelcomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          // 1. Background Image (Link Gambar Baru yang Aktif)
          Container(
            decoration: const BoxDecoration(
              image: DecorationImage(
                // Gambar konser crowd yang lebih terang dan hidup
                image: NetworkImage(
                  'https://images.unsplash.com/photo-1429962714451-bb934ecdc4ec?q=80&w=2070&auto=format&fit=crop',
                ),
                fit: BoxFit.cover,
              ),
            ),
          ),

          // 2. Overlay Gradient (Agar teks terbaca tapi tidak hitam pekat)
          Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [
                  Colors.transparent,
                  AppColors.background.withOpacity(
                    0.6,
                  ), // Transparansi BlueGreen
                  AppColors.background, // Solid BlueGreen di bawah
                ],
                stops: const [0.0, 0.5, 1.0],
              ),
            ),
          ),

          // 3. Content
          Padding(
            padding: const EdgeInsets.symmetric(
              horizontal: 24.0,
              vertical: 40.0,
            ),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.end,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  "Feel the\nBeat Live.",
                  style: TextStyle(
                    fontSize: 48,
                    fontWeight: FontWeight.bold,
                    color: AppColors.textPrimary, // Warna Cream
                    height: 1.1,
                  ),
                ).animate().fadeIn(duration: 600.ms).slideY(begin: 0.3, end: 0),

                const SizedBox(height: 16),

                Text(
                  "Platform pemesanan tiket konser termudah dan terpercaya.",
                  style: TextStyle(
                    fontSize: 16,
                    color: AppColors.textSecondary, // Warna Haze
                  ),
                ).animate().fadeIn(delay: 300.ms, duration: 600.ms),

                const SizedBox(height: 40),

                // Tombol Get Started
                SizedBox(
                      width: double.infinity,
                      height: 56,
                      child: ElevatedButton(
                        onPressed: () {
                          // _showAuthBottomSheet(context);
                          Get.offAll(() => const HomeView());
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.primary,
                          foregroundColor: AppColors.buttonText,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(16),
                          ),
                          elevation: 10,
                        ),
                        child: const Text(
                          "Get Started",
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    )
                    .animate()
                    .fadeIn(delay: 600.ms, duration: 600.ms)
                    .slideY(begin: 0.5, end: 0),
              ],
            ),
          ),
        ],
      ),
    );
  }

  void _showAuthBottomSheet(BuildContext context) {
    Get.bottomSheet(
      Container(
        padding: const EdgeInsets.all(24),
        decoration: const BoxDecoration(
          color: AppColors.cardSurface, // Warna Waterway (Teal)
          borderRadius: BorderRadius.vertical(top: Radius.circular(30)),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 40,
              height: 4,
              margin: const EdgeInsets.only(bottom: 24),
              decoration: BoxDecoration(
                color: AppColors.haze,
                borderRadius: BorderRadius.circular(2),
              ),
            ),

            // Tombol Login
            _buildAuthButton(
              "Masuk (Login)",
              AppColors.primary, // Background Cream
              AppColors.buttonText, // Teks Gelap
              () {
                Get.back();
                Get.to(() => const LoginView());
              },
            ),

            const SizedBox(height: 16),

            // Tombol Register
            _buildAuthButton(
              "Daftar Akun Baru",
              Colors.transparent,
              AppColors.primary, // Teks Cream
              () {
                Get.back();
                Get.to(() => const RegisterView());
              },
              isOutlined: true,
            ),
            const SizedBox(height: 16),
          ],
        ),
      ),
    );
  }

  Widget _buildAuthButton(
    String text,
    Color bgColor,
    Color textColor,
    VoidCallback onTap, {
    bool isOutlined = false,
  }) {
    return SizedBox(
      width: double.infinity,
      height: 56,
      child:
          isOutlined
              ? OutlinedButton(
                onPressed: onTap,
                style: OutlinedButton.styleFrom(
                  side: const BorderSide(color: AppColors.haze),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                ),
                child: Text(
                  text,
                  style: TextStyle(
                    color: textColor,
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              )
              : ElevatedButton(
                onPressed: onTap,
                style: ElevatedButton.styleFrom(
                  backgroundColor: bgColor,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                ),
                child: Text(
                  text,
                  style: TextStyle(
                    color: textColor,
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
    );
  }
}
