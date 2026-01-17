import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:iconsax/iconsax.dart';
import 'package:intl/intl.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../../theme/app_colors.dart';
import 'home_controller.dart'; // JANGAN LUPA: Import ini untuk ambil data konser

class TicketDetailView extends StatelessWidget {
  final Map<String, dynamic> ticket;

  const TicketDetailView({super.key, required this.ticket});

  @override
  Widget build(BuildContext context) {
    // Format Uang
    final currencyFormatter = NumberFormat.currency(
      locale: 'id_ID', symbol: 'IDR ', decimalDigits: 0);
    
    // Handle key 'total'
    var totalAmount = ticket['total'] ?? ticket['total_price'] ?? 0;
    String formattedTotal = currencyFormatter.format(totalAmount);

    // --- LOGIKA BARU: CARI NAMA & LOKASI ---
    String eventName = "Event #${ticket['event_id']}";
    String eventLocation = "Unknown Location";

    try {
      // Kita "pinjam" data dari HomeController yang sudah meload semua konser
      if (Get.isRegistered<HomeController>()) {
        final homeCtrl = Get.find<HomeController>();
        // Cari konser yang ID-nya sama dengan tiket ini
        final event = homeCtrl.concertList.firstWhere(
          (e) => e['id'] == ticket['event_id'], 
          orElse: () => null
        );
        
        if (event != null) {
          eventName = event['name'];
          eventLocation = event['location'];
        }
      }
    } catch (e) {
      // Kalau error, biarkan default
    }
    // ----------------------------------------

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text("E-Ticket", style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
        centerTitle: true,
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new, color: Colors.white, size: 20),
          onPressed: () => Get.back(),
        ),
        actions: [
          IconButton(
            icon: const Icon(Iconsax.share, color: Colors.white),
            onPressed: () {},
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          children: [
            const Text(
              "Tunjukkan tiket ini di pintu masuk",
              style: TextStyle(color: Colors.grey, fontSize: 14),
            ),
            const SizedBox(height: 24),

            // --- TICKET CARD ---
            Container(
              width: double.infinity,
              decoration: BoxDecoration(
                color: const Color(0xFF253334), // Warna Kartu Tiket
                borderRadius: BorderRadius.circular(24),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.3),
                    blurRadius: 20,
                    offset: const Offset(0, 10),
                  ),
                ],
              ),
              child: Column(
                children: [
                  // --- BAGIAN ATAS (EVENT INFO) ---
                  Container(
                    padding: const EdgeInsets.all(24),
                    decoration: const BoxDecoration(
                      color: AppColors.cardSurface, // Header tiket agak terang
                      borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
                    ),
                    child: Column(
                      children: [
                        // Poster / Icon Event
                        Container(
                          height: 80, width: 80,
                          decoration: BoxDecoration(
                            color: AppColors.primary.withOpacity(0.2),
                            shape: BoxShape.circle,
                          ),
                          child: const Icon(Iconsax.music_dashboard, size: 40, color: AppColors.primary),
                        ),
                        const SizedBox(height: 16),
                        
                        // --- TAMPILKAN NAMA EVENT (BUKAN ID LAGI) ---
                        Text(
                          eventName, 
                          textAlign: TextAlign.center,
                          style: const TextStyle(color: Colors.white, fontSize: 22, fontWeight: FontWeight.bold),
                        ),
                        const SizedBox(height: 4),
                        // --- TAMPILKAN LOKASI ---
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            const Icon(Iconsax.location, size: 14, color: Colors.grey),
                            const SizedBox(width: 4),
                            Text(
                              eventLocation,
                              style: const TextStyle(color: Colors.grey, fontSize: 14),
                            ),
                          ],
                        ),
                        // ---------------------------------------------

                        const SizedBox(height: 16),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                          decoration: BoxDecoration(
                            color: Colors.green.withOpacity(0.2),
                            borderRadius: BorderRadius.circular(20),
                            border: Border.all(color: Colors.green),
                          ),
                          child: const Text(
                            "CONFIRMED",
                            style: TextStyle(color: Colors.green, fontSize: 12, fontWeight: FontWeight.bold),
                          ),
                        ),
                      ],
                    ),
                  ),

                  // --- GARIS SOBEKAN (DASHED LINE) ---
                  Stack(
                    children: [
                      // Garis Putus-putus
                      Padding(
                        padding: const EdgeInsets.symmetric(vertical: 20),
                        child: Row(
                          children: List.generate(20, (index) => Expanded(
                            child: Container(
                              color: index % 2 == 0 ? Colors.transparent : Colors.grey.withOpacity(0.3),
                              height: 2,
                            ),
                          )),
                        ),
                      ),
                      // Lingkaran Kiri (Bolongan Tiket)
                      Positioned(
                        left: -15, top: 6,
                        child: Container(
                          height: 30, width: 30,
                          decoration: const BoxDecoration(
                            color: AppColors.background,
                            shape: BoxShape.circle,
                          ),
                        ),
                      ),
                      // Lingkaran Kanan (Bolongan Tiket)
                      Positioned(
                        right: -15, top: 6,
                        child: Container(
                          height: 30, width: 30,
                          decoration: const BoxDecoration(
                            color: AppColors.background,
                            shape: BoxShape.circle,
                          ),
                        ),
                      ),
                    ],
                  ),

                  // --- BAGIAN BAWAH (DETAIL & QR) ---
                  Padding(
                    padding: const EdgeInsets.fromLTRB(24, 0, 24, 30),
                    child: Column(
                      children: [
                        _buildTicketRow("Order ID", "#${ticket['id']}"),
                        const SizedBox(height: 16),
                        _buildTicketRow("Quantity", "${ticket['quantity']} Orang"),
                        const SizedBox(height: 16),
                        _buildTicketRow("Total Paid", formattedTotal, isBold: true),
                        
                        const SizedBox(height: 30),
                        
                        // SIMULASI QR CODE
                        // Container(
                        //   padding: const EdgeInsets.all(16),
                        //   decoration: BoxDecoration(
                        //     color: Colors.white,
                        //     borderRadius: BorderRadius.circular(16),
                        //   ),
                        //   child: Column(
                        //     children: [
                        //       const Icon(Iconsax.scan_barcode, size: 80, color: Colors.black),
                        //       const SizedBox(height: 8),
                        //       Text(
                        //         "SCAN ENTRY",
                        //         style: TextStyle(color: Colors.black.withOpacity(0.6), fontWeight: FontWeight.bold, letterSpacing: 3),
                        //       ),
                        //     ],
                        //   ),
                        // ),
                        
                        const SizedBox(height: 16),
                        Text(
                          "Ticket ID: ${ticket['id']}-${ticket['event_id']}-SECURE",
                          style: TextStyle(color: Colors.white.withOpacity(0.5), fontSize: 10),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ).animate().slideY(begin: 0.2, duration: 600.ms).fadeIn(),

            const SizedBox(height: 30),

            // --- TOMBOL DOWNLOAD ---
            // SizedBox(
            //   width: double.infinity,
            //   height: 56,
            //   child: ElevatedButton.icon(
            //     onPressed: () {
            //        Get.snackbar("Info", "Tiket berhasil disimpan ke galeri!", 
            //         backgroundColor: Colors.white, colorText: Colors.black);
            //     },
            //     style: ElevatedButton.styleFrom(
            //       backgroundColor: AppColors.primary,
            //       foregroundColor: Colors.black,
            //       shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
            //     ),
            //     icon: const Icon(Iconsax.document_download),
            //     label: const Text("Download PDF", style: TextStyle(fontWeight: FontWeight.bold)),
            //   ),
            // ).animate().fadeIn(delay: 400.ms),
          ],
        ),
      ),
    );
  }

  Widget _buildTicketRow(String label, String value, {bool isBold = false}) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(label, style: const TextStyle(color: Colors.grey, fontSize: 14)),
        Text(
          value, 
          style: TextStyle(
            color: isBold ? AppColors.primary : Colors.white, 
            fontSize: 16, 
            fontWeight: isBold ? FontWeight.bold : FontWeight.w500
          )
        ),
      ],
    );
  }
}