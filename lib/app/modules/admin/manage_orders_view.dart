import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:iconsax/iconsax.dart';
import 'package:intl/intl.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../../theme/app_colors.dart';
import 'manage_orders_controller.dart';
import 'order_detail_view.dart';
// --- IMPORT CONTROLLER LAIN UNTUK LOOKUP DATA ---
import 'manage_catalog_controller.dart';
import 'manage_users_controller.dart'; 

class ManageOrdersView extends StatelessWidget {
  const ManageOrdersView({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = Get.put(ManageOrdersController());
    
    // --- PRE-LOAD DATA UNTUK LOOKUP NAMA ---
    // Menginisialisasi controller catalog dan user agar data list tersedia untuk dicocokkan
    final catalogCtrl = Get.put(ManageCatalogController(), permanent: false);
    final usersCtrl = Get.put(ManageUsersController(), permanent: false);

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.background,
        title: const Text("Transaction History", style: TextStyle(color: Colors.white)),
        iconTheme: const IconThemeData(color: Colors.white),
        elevation: 0,
      ),
      body: Obx(() {
        if (controller.isLoading.value) {
          return const Center(child: CircularProgressIndicator(color: AppColors.primary));
        }

        if (controller.orderList.isEmpty) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: const [
                Icon(Iconsax.receipt_1, size: 64, color: Colors.grey),
                SizedBox(height: 16),
                Text("Belum ada transaksi masuk", style: TextStyle(color: Colors.grey)),
              ],
            ),
          );
        }

        return RefreshIndicator(
          onRefresh: () async {
            await controller.refreshData();
            // Refresh data pendukung agar sinkron jika ada perubahan di service lain
            await catalogCtrl.fetchConcerts(); 
            await usersCtrl.fetchUsers();
          },
          color: AppColors.primary,
          child: ListView.builder(
            padding: const EdgeInsets.all(20),
            itemCount: controller.orderList.length,
            itemBuilder: (context, index) {
              final order = controller.orderList[index];
              return _buildOrderCard(order, index);
            },
          ),
        );
      }),
    );
  }

  Widget _buildOrderCard(dynamic order, int index) {
    // Format Rupiah
    final currencyFormatter = NumberFormat.currency(locale: 'id_ID', symbol: 'Rp ', decimalDigits: 0);
    String total = currencyFormatter.format(order['total'] ?? 0);
    
    // Status Logic
    String status = order['status'] ?? 'pending';
    Color statusColor;
    switch (status.toLowerCase()) {
      case 'paid':
      case 'success':
        statusColor = Colors.green;
        break;
      case 'pending':
        statusColor = Colors.orange;
        break;
      case 'failed':
      case 'cancelled':
        statusColor = Colors.red;
        break;
      default:
        statusColor = Colors.grey;
    }

    // --- LOGIKA PENCARIAN DATA NYATA (LOOKUP) ---
    String customerName = "Unknown Customer";
    String concertName = "Event #${order['event_id']}";
    String concertLocation = "Unknown Location";

    // 1. Mencocokkan Nama Customer dari ManageUsersController (Node.js/MongoDB)
    if (Get.isRegistered<ManageUsersController>()) {
      final userCtrl = Get.find<ManageUsersController>();
      final user = userCtrl.userList.firstWhere(
        (u) => u['_id'].toString() == order['user_id'].toString() || u['id'].toString() == order['user_id'].toString(),
        orElse: () => null
      );
      if (user != null) {
        customerName = user['name'] ?? user['email'] ?? "User #${order['user_id']}";
      }
    }

    // 2. Mencocokkan Nama & Lokasi Konser dari ManageCatalogController (Laravel/MySQL)
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
    // --------------------------------------

    return GestureDetector(
      onTap: () {
        Get.to(() => OrderDetailView(order: order));
      },
      child: Container(
        margin: const EdgeInsets.only(bottom: 16),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: const Color(0xFF253334),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: Colors.white10),
        ),
        child: Column(
          children: [
            // Baris Atas: Order ID & Status
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    const Icon(Iconsax.receipt, color: Colors.white70, size: 20),
                    const SizedBox(width: 8),
                    Text(
                      "Order #${order['id']}", 
                      style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 16)
                    ),
                  ],
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(
                    color: statusColor.withOpacity(0.2),
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: statusColor.withOpacity(0.5)),
                  ),
                  child: Text(
                    status.toUpperCase(),
                    style: TextStyle(color: statusColor, fontSize: 10, fontWeight: FontWeight.bold),
                  ),
                ),
              ],
            ),
            
            const Divider(color: Colors.white10, height: 24),
            
            // --- DATA HASIL LOOKUP SERVICE ---
            
            _buildRowInfo("Customer", customerName, icon: Iconsax.user),
            const SizedBox(height: 8),
            
            _buildRowInfo("Event", concertName, icon: Iconsax.music),
            const SizedBox(height: 8),
            
            _buildRowInfo("Location", concertLocation, icon: Iconsax.location),
            const SizedBox(height: 8),
            
            _buildRowInfo("Quantity", "${order['quantity']} Ticket(s)", icon: Iconsax.ticket),
            
            const Divider(color: Colors.white10, height: 24),
            
            // Bagian Total Pembayaran
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text("Total Payment", style: TextStyle(color: Colors.grey)),
                Text(total, style: const TextStyle(color: AppColors.secondary, fontWeight: FontWeight.bold, fontSize: 16)),
              ],
            ),
          ],
        ),
      ),
    ).animate().fadeIn(delay: (100 * index).ms).slideY(begin: 0.2);
  }

  // Helper Widget untuk baris informasi dengan ikon
  Widget _buildRowInfo(String label, String value, {IconData? icon}) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Row(
          children: [
            if (icon != null) ...[
              Icon(icon, size: 14, color: Colors.grey),
              const SizedBox(width: 6),
            ],
            Text(label, style: const TextStyle(color: Colors.grey, fontSize: 13)),
          ],
        ),
        Flexible(
          child: Text(
            value, 
            style: const TextStyle(color: Colors.white70, fontSize: 13, fontWeight: FontWeight.w500),
            overflow: TextOverflow.ellipsis,
            textAlign: TextAlign.right,
          ),
        ),
      ],
    );
  }
}