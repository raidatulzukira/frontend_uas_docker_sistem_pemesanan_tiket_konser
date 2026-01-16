import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:iconsax/iconsax.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:intl/intl.dart';
import '../../theme/app_colors.dart';
import 'manage_catalog_controller.dart';
import 'concert_detail_view.dart';
import 'add_concert_view.dart'; // Nanti kita buat file ini

class ManageCatalogView extends StatelessWidget {
  const ManageCatalogView({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = Get.put(ManageCatalogController());

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.background,
        title: const Text("Manage Catalog", style: TextStyle(color: Colors.white)),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Get.back(),
        ),
      ),
      
      // Tombol Tambah (Floating Action Button)
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => Get.to(() => const AddConcertView()),
        backgroundColor: AppColors.primary,
        icon: const Icon(Iconsax.add, color: Colors.black),
        label: const Text("Add Concert", style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold)),
      ),

      body: Obx(() {
        if (controller.isLoading.value) {
          return const Center(child: CircularProgressIndicator(color: AppColors.primary));
        }

        if (controller.concertList.isEmpty) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(Iconsax.music_dashboard, size: 64, color: Colors.white24),
                const SizedBox(height: 16),
                const Text("Belum ada konser", style: TextStyle(color: Colors.white54)),
              ],
            ),
          );
        }

        return ListView.builder(
          // FIX: Hapus padding yang duplikat, pakai satu saja yang ada bottom: 80
          padding: const EdgeInsets.only(left: 20, right: 20, top: 20, bottom: 80), 
          itemCount: controller.concertList.length,
          itemBuilder: (context, index) {
            final concert = controller.concertList[index];
            
            // Format Rupiah
            final currencyFormatter = NumberFormat.currency(locale: 'id_ID', symbol: 'Rp ', decimalDigits: 0);
            String price = currencyFormatter.format(concert['price'] ?? 0);
            
            // Format Tanggal
            DateTime date = DateTime.tryParse(concert['date']) ?? DateTime.now();

            // --- PERUBAHAN DI SINI (DIBUNGKUS GESTURE DETECTOR) ---
            return GestureDetector(
              onTap: () {
                // Navigasi ke Halaman Detail & kirim data konser
                Get.to(() => ConcertDetailView(concert: concert));
              },
              child: Container(
                margin: const EdgeInsets.only(bottom: 16),
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: const Color(0xFF253334),
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: Colors.white10),
                ),
                child: Row(
                  children: [
                    // Icon Kotak Tanggal
                    Container(
                      width: 60, height: 60,
                      decoration: BoxDecoration(
                        color: AppColors.primary.withOpacity(0.2),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(DateFormat('dd').format(date), 
                            style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18, color: AppColors.primary)),
                          Text(DateFormat('MMM').format(date).toUpperCase(), 
                            style: const TextStyle(fontSize: 10, color: Colors.white70)),
                        ],
                      ),
                    ),
                    const SizedBox(width: 16),
                    
                    // Detail Info
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            concert['name'] ?? "Unknown Concert",
                            style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 16),
                            maxLines: 1, overflow: TextOverflow.ellipsis,
                          ),
                          const SizedBox(height: 4),
                          Row(
                            children: [
                              const Icon(Iconsax.location, size: 14, color: Colors.grey),
                              const SizedBox(width: 4),
                              Expanded(
                                child: Text(
                                  concert['location'] ?? "-",
                                  style: const TextStyle(color: Colors.grey, fontSize: 12),
                                  maxLines: 1, overflow: TextOverflow.ellipsis,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 8),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(price, style: const TextStyle(color: AppColors.secondary, fontWeight: FontWeight.bold)),
                              Text("Stock: ${concert['stock']}", style: const TextStyle(color: Colors.white54, fontSize: 12)),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ).animate().fadeIn(delay: (100 * index).ms).slideX(),
            );
          },
        );
      }),
    );
  }
}