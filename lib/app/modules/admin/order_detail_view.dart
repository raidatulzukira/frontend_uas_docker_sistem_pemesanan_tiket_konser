import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:iconsax/iconsax.dart';
import 'package:intl/intl.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../../theme/app_colors.dart';
// --- IMPORT CONTROLLER UNTUK LOOKUP DATA ---
import 'manage_catalog_controller.dart';
import 'manage_users_controller.dart';

class OrderDetailView extends StatelessWidget {
  final Map<String, dynamic> order;

  const OrderDetailView({super.key, required this.order});

  @override
  Widget build(BuildContext context) {
    // Format Currency
    final currencyFormatter = NumberFormat.currency(
      locale: 'id_ID',
      symbol: 'Rp ',
      decimalDigits: 0,
    );
    String totalPrice = currencyFormatter.format(order['total'] ?? 0);

    // --- LOGIKA LOOKUP DATA ---
    String customerName = "Unknown Customer";
    String concertName = "Event #${order['event_id']}";
    String concertLocation = "Unknown Location";

    // 1. Cari Nama Customer
    if (Get.isRegistered<ManageUsersController>()) {
      final userCtrl = Get.find<ManageUsersController>();
      final user = userCtrl.userList.firstWhere(
        (u) => u['_id'].toString() == order['user_id'].toString() || u['id'].toString() == order['user_id'].toString(),
        orElse: () => null
      );
      if (user != null) customerName = user['name'] ?? user['email'];
    }

    // 2. Cari Nama & Lokasi Konser
    if (Get.isRegistered<ManageCatalogController>()) {
      final catalogCtrl = Get.find<ManageCatalogController>();
      final concert = catalogCtrl.concertList.firstWhere(
        (c) => c['id'].toString() == order['event_id'].toString(),
        orElse: () => null
      );
      if (concert != null) {
        concertName = concert['name'];
        concertLocation = concert['location'];
      }
    }

    // Status Logic (Tetap sama)
    String status = order['status'] ?? 'pending';
    Color statusColor;
    IconData statusIcon;
    String statusMessage;

    switch (status.toLowerCase()) {
      case 'paid':
      case 'success':
        statusColor = const Color(0xFF00C853);
        statusIcon = Iconsax.verify5;
        statusMessage = "Payment Successful";
        break;
      case 'pending':
        statusColor = const Color(0xFFFFAB00);
        statusIcon = Iconsax.timer_15;
        statusMessage = "Waiting for Payment";
        break;
      default:
        statusColor = Colors.redAccent;
        statusIcon = Iconsax.close_circle5;
        statusMessage = "Transaction Failed";
    }

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.background,
        elevation: 0,
        centerTitle: true,
        title: const Text("Order Details", style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Get.back(),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          children: [
            // --- 1. STATUS HEADER ---
            Container(
              padding: const EdgeInsets.symmetric(vertical: 30, horizontal: 20),
              width: double.infinity,
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [statusColor.withOpacity(0.2), Colors.transparent],
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                ),
                borderRadius: BorderRadius.circular(24),
                border: Border.all(color: statusColor.withOpacity(0.3)),
              ),
              child: Column(
                children: [
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(color: statusColor.withOpacity(0.2), shape: BoxShape.circle),
                    child: Icon(statusIcon, color: statusColor, size: 40),
                  ).animate().scale(duration: 500.ms, curve: Curves.elasticOut),
                  const SizedBox(height: 16),
                  Text(statusMessage, style: TextStyle(color: statusColor, fontSize: 20, fontWeight: FontWeight.bold)),
                  const SizedBox(height: 8),
                  Text("Order ID #${order['id']}", style: const TextStyle(color: Colors.grey, fontSize: 14)),
                ],
              ),
            ).animate().fadeIn().slideY(begin: -0.2),

            const SizedBox(height: 24),

            // --- 2. RECEIPT CARD ---
            Container(
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                color: const Color(0xFF253334),
                borderRadius: BorderRadius.circular(24),
                boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.3), blurRadius: 20, offset: const Offset(0, 10))],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildSectionTitle("Customer Info", Iconsax.user),
                  const SizedBox(height: 16),
                  _buildInfoRow("Customer Name", customerName),
                  const SizedBox(height: 8),
                  _buildCopyableRow("User ID", order['user_id'] ?? "-"),
                  
                  const Padding(padding: EdgeInsets.symmetric(vertical: 20), child: Divider(color: Colors.white10)),

                  _buildSectionTitle("Ticket Details", Iconsax.ticket),
                  const SizedBox(height: 16),
                  _buildInfoRow("Event Name", concertName),
                  const SizedBox(height: 8),
                  _buildInfoRow("Location", concertLocation),
                  const SizedBox(height: 8),
                  _buildInfoRow("Quantity", "${order['quantity']} Ticket(s)"),
                  
                  const Padding(padding: EdgeInsets.symmetric(vertical: 20), child: Divider(color: Colors.white10, thickness: 1)),

                  // Total Section
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text("Total Amount", style: TextStyle(color: Colors.white70, fontSize: 16)),
                      Text(totalPrice, style: const TextStyle(color: AppColors.primary, fontSize: 24, fontWeight: FontWeight.bold)),
                    ],
                  ),
                ],
              ),
            ).animate().fadeIn(delay: 200.ms).slideY(begin: 0.2),

            const SizedBox(height: 30),

            // --- 3. ACTION BUTTON ---
            SizedBox(
              width: double.infinity,
              height: 56,
              // child: ElevatedButton.icon(
              //   onPressed: () {
              //      Get.snackbar("Info", "Fitur Cetak Invoice sedang dalam pengembangan", 
              //       backgroundColor: Colors.blueGrey, colorText: Colors.white);
              //   },
              //   style: ElevatedButton.styleFrom(
              //     backgroundColor: Colors.white.withOpacity(0.1),
              //     foregroundColor: Colors.white,
              //     shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
              //     side: const BorderSide(color: Colors.white24),
              //   ),
              //   icon: const Icon(Iconsax.printer),
              //   label: const Text("Print Invoice"),
              // ),
            ).animate().fadeIn(delay: 400.ms),
          ],
        ),
      ),
    );
  }

  // --- WIDGET HELPERS ---
  Widget _buildSectionTitle(String title, IconData icon) {
    return Row(
      children: [
        Icon(icon, color: AppColors.primary, size: 20),
        const SizedBox(width: 8),
        Text(title.toUpperCase(), style: const TextStyle(color: AppColors.primary, fontSize: 12, fontWeight: FontWeight.bold, letterSpacing: 1.2)),
      ],
    );
  }

  Widget _buildInfoRow(String label, String value) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: const TextStyle(color: Colors.grey, fontSize: 14)),
        const SizedBox(width: 10),
        Expanded(child: Text(value, textAlign: TextAlign.right, style: const TextStyle(color: Colors.white, fontSize: 14, fontWeight: FontWeight.w500))),
      ],
    );
  }

  Widget _buildCopyableRow(String label, String value) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: const TextStyle(color: Colors.grey, fontSize: 12)),
        const SizedBox(height: 4),
        InkWell(
          onTap: () {
            Clipboard.setData(ClipboardData(text: value));
            Get.snackbar("Copied", "ID berhasil disalin", snackPosition: SnackPosition.BOTTOM, backgroundColor: Colors.white, colorText: Colors.black);
          },
          child: Row(
            children: [
              Expanded(child: Text(value, style: const TextStyle(color: Colors.white, fontSize: 14, fontFamily: 'Monospace'), maxLines: 1, overflow: TextOverflow.ellipsis)),
              const Icon(Iconsax.copy, color: Colors.white30, size: 16),
            ],
          ),
        ),
      ],
    );
  }
}