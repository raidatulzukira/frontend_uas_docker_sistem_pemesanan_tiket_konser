import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:iconsax/iconsax.dart';
import 'package:intl/intl.dart';
import '../../theme/app_colors.dart';
import 'ticket_controller.dart';

class MyTicketsView extends StatelessWidget {
  const MyTicketsView({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = Get.put(TicketController());
    final fmt = NumberFormat.currency(locale: 'id_ID', symbol: 'IDR ', decimalDigits: 0);

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text("Tiket Saya", style: TextStyle(fontWeight: FontWeight.bold)),
        backgroundColor: AppColors.background,
        elevation: 0,
      ),
      body: Obx(() {
        if (controller.isLoading.value) {
          return const Center(child: CircularProgressIndicator(color: AppColors.primary));
        }

        if (controller.myTickets.isEmpty) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Iconsax.ticket_expired, size: 64, color: Colors.grey.withOpacity(0.5)),
                const SizedBox(height: 16),
                const Text("Belum ada tiket yang dibeli", style: TextStyle(color: Colors.grey)),
              ],
            ),
          );
        }

        return RefreshIndicator(
          onRefresh: () => controller.fetchMyTickets(),
          child: ListView.builder(
            padding: const EdgeInsets.all(20),
            itemCount: controller.myTickets.length,
            itemBuilder: (context, index) {
              final ticket = controller.myTickets[index];
              bool isSuccess = ticket['status'] == "SUCCESS";

              return Container(
                margin: const EdgeInsets.only(bottom: 16),
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: AppColors.cardSurface,
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(color: isSuccess ? Colors.green.withOpacity(0.3) : Colors.orange.withOpacity(0.3)),
                ),
                child: Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: (isSuccess ? Colors.green : Colors.orange).withOpacity(0.1),
                        shape: BoxShape.circle,
                      ),
                      child: Icon(
                        isSuccess ? Iconsax.ticket_2 : Iconsax.timer_1,
                        color: isSuccess ? Colors.greenAccent : Colors.orangeAccent,
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text("Order #${ticket['id']}", style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.white)),
                          Text("Event ID: ${ticket['event_id']}", style: const TextStyle(color: Colors.grey, fontSize: 12)),
                          const SizedBox(height: 4),
                          Text(fmt.format(ticket['total']), style: const TextStyle(color: AppColors.primary, fontWeight: FontWeight.bold)),
                        ],
                      ),
                    ),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        Text("${ticket['quantity']} Tiket", style: const TextStyle(color: Colors.white70)),
                        const SizedBox(height: 4),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                          decoration: BoxDecoration(
                            color: isSuccess ? Colors.green : Colors.orange,
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Text(
                            ticket['status'],
                            style: const TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: Colors.black),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              );
            },
          ),
        );
      }),
    );
  }
}