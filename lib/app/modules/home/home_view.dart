import 'package:flutter/material.dart';
import 'concert_detail_view.dart';
import 'package:get/get.dart';
import 'package:iconsax/iconsax.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:intl/intl.dart';
import '../../theme/app_colors.dart';
import '../../data/services/api_config.dart'; // <--- JANGAN LUPA IMPORT INI
import '../auth/auth_controller.dart';
import '../auth/login_view.dart';
import 'home_controller.dart';
import 'my_tickets_view.dart';

class HomeView extends StatelessWidget {
  const HomeView({super.key});

  @override
  Widget build(BuildContext context) {
    // KODE BARU: Langsung temukan (find) yang sudah dibuat di main.dart
    final authController = Get.find<AuthController>();
    final controller = Get.put(HomeController());

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.background,
        elevation: 0,
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: const [
            Text(
              "Discover",
              style: TextStyle(fontSize: 14, color: AppColors.textSecondary),
            ),
            Text(
              "Live Concerts",
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: AppColors.textPrimary,
              ),
            ),
          ],
        ),
        actions: [
          // --- TAMBAHKAN KODE INI (Tombol Tiket Saya) ---
          Obx(
            () =>
                authController.isLoggedIn.value
                    ? IconButton(
                      onPressed: () {
                        Get.to(
                          () => const MyTicketsView(),
                        ); // Pastikan MyTicketsView sudah di-import
                      },
                      icon: Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: AppColors.cardSurface,
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(
                            color: AppColors.primary.withOpacity(0.2),
                          ),
                        ),
                        child: const Icon(
                          Iconsax.ticket,
                          color: AppColors.primary,
                        ),
                      ),
                    )
                    : const SizedBox(),
          ), // Jika belum login, tampilkan kotak kosong (tidak terlihat)
          // --- KODE PROFIL ANDA DI BAWAH INI ---
          Padding(
            padding: const EdgeInsets.only(right: 16.0),
            child: Obx(
              () => IconButton(
                onPressed: () {
                  if (authController.isLoggedIn.value) {
                    // JIKA SUDAH LOGIN -> Tampilkan Dialog Logout
                    Get.defaultDialog(
                      title: "Akun Saya",
                      backgroundColor: AppColors.cardSurface,
                      // ... sisa kode dialog logout Anda ...
                      onConfirm: () {
                        Get.back();
                        authController.logout();
                      },
                    );
                  } else {
                    // JIKA BELUM LOGIN -> Ke halaman Login
                    Get.to(() => const LoginView());
                  }
                },
                icon: Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: AppColors.cardSurface,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color:
                          authController.isLoggedIn.value
                              ? Colors.greenAccent.withOpacity(0.5)
                              : AppColors.haze.withOpacity(0.3),
                    ),
                  ),
                  child: Icon(
                    authController.isLoggedIn.value
                        ? Iconsax.user_tick
                        : Iconsax.user,
                    color:
                        authController.isLoggedIn.value
                            ? Colors.greenAccent
                            : AppColors.primary,
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
      body: Obx(() {
        if (controller.isLoading.value) {
          return const Center(
            child: CircularProgressIndicator(color: AppColors.primary),
          );
        }

        if (controller.concertList.isEmpty) {
          return const Center(
            child: Text(
              "Belum ada konser tersedia",
              style: TextStyle(color: Colors.grey),
            ),
          );
        }

        return RefreshIndicator(
          onRefresh: () => controller.fetchConcerts(),
          color: AppColors.primary,
          child: ListView.builder(
            padding: const EdgeInsets.all(24),
            itemCount: controller.concertList.length,
            itemBuilder: (context, index) {
              final concert = controller.concertList[index];
              return _buildConcertCard(concert, index);
            },
          ),
        );
      }),
    );
  }

  Widget _buildConcertCard(dynamic concert, int index) {
    final authController = Get.find<AuthController>();
    // Format Data
    final currencyFormatter = NumberFormat.currency(
      locale: 'id_ID',
      symbol: 'IDR ',
      decimalDigits: 0,
    );
    String price = currencyFormatter.format(concert['price'] ?? 0);

    DateTime date = DateTime.tryParse(concert['date']) ?? DateTime.now();
    String day = DateFormat('dd').format(date);
    String month = DateFormat('MMM').format(date).toUpperCase();

    // --- LOGIKA GAMBAR REAL ---
    String imageUrl;
    // Cek apakah database punya data image?
    if (concert['image'] != null && concert['image'].toString().isNotEmpty) {
      // Gabungkan Base URL Storage dengan path dari database
      imageUrl = "${ApiConfig.imageBaseUrl}${concert['image']}";
    } else {
      // Fallback: Jika admin belum upload gambar, pakai gambar default yang cantik
      imageUrl =
          'https://images.unsplash.com/photo-1540039155733-5bb30b53aa14?q=80&w=1974&auto=format&fit=crop';
    }

    return Container(
      margin: const EdgeInsets.only(bottom: 24),
      decoration: BoxDecoration(
        color: AppColors.cardSurface,
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.2),
            blurRadius: 20,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // 1. Gambar Konser
          Stack(
            children: [
              ClipRRect(
                borderRadius: const BorderRadius.vertical(
                  top: Radius.circular(24),
                ),
                child: Image.network(
                  imageUrl, // <--- Sudah pakai URL asli sekarang
                  height: 180,
                  width: double.infinity,
                  fit: BoxFit.cover,
                  // Error Builder: Jaga-jaga kalau link rusak/koneksi putus
                  errorBuilder:
                      (context, error, stackTrace) => Container(
                        height: 180,
                        color: Colors.grey.shade900,
                        child: const Center(
                          child: Icon(
                            Iconsax.image,
                            color: Colors.white24,
                            size: 40,
                          ),
                        ),
                      ),
                  loadingBuilder: (context, child, loadingProgress) {
                    if (loadingProgress == null) return child;
                    return Container(
                      height: 180,
                      color: AppColors.cardSurface,
                      child: const Center(
                        child: CircularProgressIndicator(
                          color: AppColors.primary,
                        ),
                      ),
                    );
                  },
                ),
              ),
              // Tanggal di pojok
              Positioned(
                top: 16,
                right: 16,
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 6,
                  ),
                  decoration: BoxDecoration(
                    color: AppColors.background.withOpacity(0.8),
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(
                      color: AppColors.primary.withOpacity(0.5),
                    ),
                  ),
                  child: Column(
                    children: [
                      Text(
                        month,
                        style: const TextStyle(
                          color: AppColors.textSecondary,
                          fontSize: 10,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      Text(
                        day,
                        style: const TextStyle(
                          color: AppColors.textPrimary,
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),

          // 2. Detail Konser
          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  concert['name'] ?? "Unknown Concert",
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: AppColors.textPrimary,
                  ),
                ),
                const SizedBox(height: 8),
                Row(
                  children: [
                    const Icon(
                      Iconsax.location,
                      size: 16,
                      color: AppColors.textSecondary,
                    ),
                    const SizedBox(width: 4),
                    Expanded(
                      child: Text(
                        concert['location'] ?? "Unknown Location",
                        style: const TextStyle(color: AppColors.textSecondary),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),

                // Harga & Tombol Beli
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          "Start from",
                          style: TextStyle(
                            color: AppColors.textSecondary,
                            fontSize: 12,
                          ),
                        ),
                        Text(
                          price,
                          style: const TextStyle(
                            color: AppColors.primary,
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),

                    // Pastikan di dalam widget build, controller sudah didefinisikan:
                    ElevatedButton(
                      onPressed: () {
                        // CEK STATUS LOGIN
                        if (authController.isLoggedIn.value) {
                          // JIKA SUDAH LOGIN -> PINDAH KE DETAIL
                          Get.to(() => ConcertDetailView(concert: concert));
                        } else {
                          // JIKA BELUM LOGIN -> Suruh Login
                          Get.defaultDialog(
                            title: "Login Diperlukan",
                            middleText:
                                "Anda harus masuk akun untuk dapat memesan tiket konser.",
                            backgroundColor: AppColors.cardSurface,
                            titleStyle: const TextStyle(
                              color: AppColors.error,
                              fontWeight: FontWeight.bold,
                            ),
                            middleTextStyle: const TextStyle(
                              color: AppColors.textSecondary,
                            ),
                            textConfirm: "Login Sekarang",
                            textCancel: "Nanti Saja",
                            confirmTextColor: Colors.white,
                            buttonColor: AppColors.primary,
                            onConfirm: () {
                              Get.back(); // Tutup dialog
                              Get.to(
                                () => const LoginView(),
                              ); // Pindah ke Login
                            },
                          );
                        }
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.primary,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      child: const Text("Book Now"),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    ).animate().fadeIn(delay: (100 * index).ms).slideY(begin: 0.2, end: 0);
  }
}
