import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:iconsax/iconsax.dart';
import 'package:flutter_animate/flutter_animate.dart'; // Pastikan sudah install ini
import '../../theme/app_colors.dart';
import 'admin_controller.dart';

class AdminView extends StatelessWidget {
  const AdminView({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = Get.put(AdminController());

    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // --- HEADER SECTION ---
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        "Hello, Admin 👋",
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                        ),
                      ).animate().fadeIn().moveX(begin: -20),
                      const SizedBox(height: 4),
                      Text(
                        "Manage your concert empire here.",
                        style: TextStyle(
                          color: Colors.white.withOpacity(0.6),
                          fontSize: 14,
                        ),
                      ).animate().fadeIn(delay: 200.ms),
                    ],
                  ),
                  // Tombol Logout Bulat
                  Container(
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.1),
                      shape: BoxShape.circle,
                    ),
                    child: IconButton(
                      onPressed: () => controller.logout(),
                      icon: const Icon(Iconsax.logout_1, color: Colors.redAccent),
                      tooltip: "Logout",
                    ),
                  ).animate().scale(delay: 300.ms),
                ],
              ),

              const SizedBox(height: 32),

              // --- STATS BANNER (Hiasan Visual) ---
              // Ini statis dulu, biar dashboard tidak kosong melompong
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [const Color.fromARGB(255, 25, 49, 51), const Color.fromARGB(255, 199, 199, 199).withOpacity(0.7)],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  borderRadius: BorderRadius.circular(24),
                  boxShadow: [
                    BoxShadow(
                      color: AppColors.primary.withOpacity(0.4),
                      blurRadius: 20,
                      offset: const Offset(0, 10),
                    ),
                  ],
                ),
                child: Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.2),
                        borderRadius: BorderRadius.circular(16),
                      ),
                      child: const Icon(Iconsax.chart_21, color: Colors.white, size: 28),
                    ),
                    const SizedBox(width: 16),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          "System Status",
                          style: TextStyle(color: Colors.white70, fontSize: 12),
                        ),
                        const SizedBox(height: 4),
                        const Text(
                          "All Services Online",
                          style: TextStyle(
                              color: Colors.white,
                              fontSize: 16,
                              fontWeight: FontWeight.bold),
                        ),
                      ],
                    ),
                  ],
                ),
              ).animate().fadeIn(delay: 400.ms).slideY(begin: 0.2),

              const SizedBox(height: 32),

              // --- GRID MENU SECTION ---
              Text(
                "Quick Actions",
                style: TextStyle(
                  color: Colors.white.withOpacity(0.9),
                  fontSize: 18,
                  fontWeight: FontWeight.w600,
                ),
              ).animate().fadeIn(delay: 500.ms),
              
              const SizedBox(height: 16),

              GridView.count(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                crossAxisCount: 2,
                crossAxisSpacing: 16,
                mainAxisSpacing: 16,
                // UBAH DISINI: Ganti 1.1 jadi 1.0 agar kartu lebih tinggi (Anti Overflow)
                childAspectRatio: 1.0, 
                children: [
                  _AdminMenuCard(
                    title: "Manage Users",
                    subtitle: "Control accounts",
                    icon: Iconsax.people,
                    iconColor: const Color(0xFF4A90E2), // Biru
                    delay: 600,
                    onTap: controller.toManageUsers,
                  ),
                  _AdminMenuCard(
                    title: "Manage Catalog",
                    subtitle: "Events & Tickets",
                    icon: Iconsax.music_dashboard, 
                    iconColor: const Color(0xFFF5A623), // Orange
                    delay: 700,
                    onTap: controller.toManageCatalog,
                  ),
                  _AdminMenuCard(
                    title: "View Orders",
                    subtitle: "Transaction history",
                    icon: Iconsax.receipt_item,
                    iconColor: const Color(0xFF7ED321), // Hijau Neon
                    delay: 800,
                    onTap: controller.toViewOrders,
                  ),
                  // _AdminMenuCard(
                  //   title: "Settings",
                  //   subtitle: "App configuration",
                  //   icon: Iconsax.setting_2,
                  //   iconColor: const Color(0xFFBD10E0), // Ungu
                  //   delay: 900,
                  //   onTap: () {},
                  // ),
                ],
              ),
              // Tambahan space di bawah agar tidak mentok
              const SizedBox(height: 40), 
            ],
          ),
        ),
      ),
    );
  }
}

// --- WIDGET KARTU (UPDATE WARNA) ---
class _AdminMenuCard extends StatelessWidget {
  final String title;
  final String subtitle;
  final IconData icon;
  final Color iconColor; // Warna icon tetap warna-warni biar cantik
  final VoidCallback onTap;
  final int delay;

  const _AdminMenuCard({
    required this.title,
    required this.subtitle,
    required this.icon,
    required this.iconColor,
    required this.onTap,
    required this.delay,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(24),
        child: Container(
          decoration: BoxDecoration(
            // UBAH DISINI: Warna dasar kartu jadi Hijau Soft Gelap
            color: const Color(0xFF253334), 
            borderRadius: BorderRadius.circular(24),
            // Border tipis agar terlihat terpisah dari background
            border: Border.all(color: Colors.white.withOpacity(0.1)),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.2), // Shadow lebih soft
                blurRadius: 10,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Stack(
            children: [
              // Dekorasi Background Icon Besar (Transparan)
              Positioned(
                right: -10,
                bottom: -10,
                child: Icon(
                  icon,
                  size: 80,
                  // Icon background dibuat transparan putih/abu biar netral
                  color: Colors.white.withOpacity(0.03), 
                ),
              ),
              
              // Konten Utama
              Padding(
                padding: const EdgeInsets.all(20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    // Icon Circle
                    Container(
                      padding: const EdgeInsets.all(10),
                      decoration: BoxDecoration(
                        // Background lingkaran icon mengikuti warna icon tapi transparan
                        color: iconColor.withOpacity(0.15),
                        shape: BoxShape.circle,
                      ),
                      child: Icon(icon, color: iconColor, size: 24),
                    ),
                    
                    // Teks
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          title,
                          style: const TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                            fontSize: 16,
                          ),
                        ),
                        const SizedBox(height: 4),
                        // Gunakan Flexible agar teks subtitle kalau kepanjangan tidak error, tapi turun ke bawah
                        Text(
                          subtitle,
                          maxLines: 2, // Maksimal 2 baris
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(
                            color: Colors.white.withOpacity(0.5),
                            fontSize: 12,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    ).animate().fadeIn(delay: delay.ms).slideY(begin: 0.2);
  }
}