import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:iconsax/iconsax.dart';
import 'package:intl/intl.dart';
import '../../theme/app_colors.dart';
import '../../data/services/api_config.dart';
import '../auth/auth_controller.dart'; // Import AuthController
import 'booking_controller.dart';

class ConcertDetailView extends StatelessWidget {
  final dynamic concert;
  const ConcertDetailView({super.key, required this.concert});

  @override
  Widget build(BuildContext context) {
    // Mencari instance controller yang sudah ada
    final bookingController = Get.put(BookingController());
    final authController = Get.find<AuthController>();

    final currencyFormatter = NumberFormat.currency(
      locale: 'id_ID',
      symbol: 'IDR ',
      decimalDigits: 0,
    );

    return Scaffold(
      backgroundColor: AppColors.background,
      body: CustomScrollView(
        slivers: [
          // 1. Header Gambar dengan Tombol Back
          SliverAppBar(
            expandedHeight: 300,
            pinned: true,
            leading: IconButton(
              icon: const Icon(Icons.arrow_back_ios_new, color: Colors.white),
              onPressed: () => Get.back(),
            ),
            backgroundColor: AppColors.background,
            flexibleSpace: FlexibleSpaceBar(
              background: Image.network(
                concert['image'] != null
                    ? "${ApiConfig.imageBaseUrl}${concert['image']}"
                    : 'https://images.unsplash.com/photo-1540039155733-5bb30b53aa14?q=80&w=1974&auto=format&fit=crop',
                fit: BoxFit.cover,
              ),
            ),
          ),

          // 2. Konten Detail
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.all(24.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    concert['name'] ?? "Concert Name",
                    style: const TextStyle(
                      fontSize: 26,
                      fontWeight: FontWeight.bold,
                      color: AppColors.textPrimary,
                    ),
                  ),
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      const Icon(
                        Iconsax.location,
                        color: AppColors.primary,
                        size: 22,
                      ),
                      const SizedBox(width: 8),
                      Text(
                        concert['location'] ?? "Venue Location",
                        style: const TextStyle(
                          color: AppColors.textSecondary,
                          fontSize: 16,
                        ),
                      ),
                    ],
                  ),
                  const Divider(height: 40, color: Colors.white10),
                  const Text(
                    "Tentang Konser",
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: AppColors.textPrimary,
                    ),
                  ),
                  const SizedBox(height: 10),
                  const Text(
                    "Saksikan penampilan spektakuler secara langsung. Stok tiket dikelola secara real-time menggunakan Redis untuk memastikan keadilan bagi semua pembeli.",
                    style: TextStyle(
                      color: AppColors.textSecondary,
                      height: 1.6,
                    ),
                  ),
                  const SizedBox(height: 30),

                  // 3. Pemilih Jumlah Tiket (Quantity Picker)
                  Container(
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      color: AppColors.cardSurface,
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(color: Colors.white10),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text(
                          "Pilih Jumlah",
                          style: TextStyle(
                            color: AppColors.textPrimary,
                            fontWeight: FontWeight.bold,
                            fontSize: 16,
                          ),
                        ),
                        Row(
                          children: [
                            IconButton(
                              onPressed: bookingController.decrement,
                              icon: const Icon(
                                Iconsax.minus_square,
                                color: AppColors.primary,
                                size: 30,
                              ),
                            ),
                            const SizedBox(width: 10),
                            Obx(
                              () => Text(
                                "${bookingController.quantity.value}",
                                style: const TextStyle(
                                  fontSize: 22,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.white,
                                ),
                              ),
                            ),
                            const SizedBox(width: 10),
                            IconButton(
                              onPressed: bookingController.increment,
                              icon: const Icon(
                                Iconsax.add_square,
                                color: AppColors.primary,
                                size: 30,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(
                    height: 100,
                  ), // Spasi bawah agar tidak tertutup bottom bar
                ],
              ),
            ),
          ),
        ],
      ),

      // 4. Bottom Bar (Harga & Tombol Confirm)
      bottomNavigationBar: Container(
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 20),
        decoration: BoxDecoration(
          color: AppColors.cardSurface,
          borderRadius: const BorderRadius.vertical(top: Radius.circular(32)),
          boxShadow: [
            BoxShadow(color: Colors.black.withOpacity(0.5), blurRadius: 20),
          ],
        ),
        child: SafeArea(
          child: Row(
            children: [
              Expanded(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      "Total Pembayaran",
                      style: TextStyle(
                        color: AppColors.textSecondary,
                        fontSize: 12,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Obx(
                      () => Text(
                        currencyFormatter.format(
                          (concert['price'] ?? 0) *
                              bookingController.quantity.value,
                        ),
                        style: const TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                          color: AppColors.primary,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Obx(
                  () => ElevatedButton(
                    onPressed:
                        bookingController.isLoading.value
                            ? null
                            : () {
                              // MENGAMBIL USER ID DARI AUTH CONTROLLER
                              // Gunakan int.tryParse jika ID di Go bertipe integer
                              String currentUserId =
                                  authController.userId.value;
                              int eventId = concert['id'];

                              bookingController.createOrder(
                                eventId,
                                currentUserId,
                              );
                            },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.primary,
                      // WARNA TEXT: Menggunakan Hitam/Gelap agar terlihat jelas di atas Primary
                      foregroundColor: const Color(0xFF121212),
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16),
                      ),
                      elevation: 0,
                    ),
                    child:
                        bookingController.isLoading.value
                            ? const SizedBox(
                              height: 20,
                              width: 20,
                              child: CircularProgressIndicator(
                                color: Colors.black,
                                strokeWidth: 2,
                              ),
                            )
                            : const Text(
                              "Konfirmasi",
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 16,
                              ),
                            ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
