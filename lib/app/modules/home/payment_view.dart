import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import '../../theme/app_colors.dart';
import 'booking_controller.dart';

class PaymentView extends StatelessWidget {
  final dynamic orderData;
  const PaymentView({super.key, required this.orderData});

  @override
  Widget build(BuildContext context) {
    final controller = Get.find<BookingController>();
    final currencyFormatter = NumberFormat.currency(locale: 'id_ID', symbol: 'IDR ', decimalDigits: 0);

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text("Confirm Payment", style: TextStyle(fontWeight: FontWeight.bold)),
        backgroundColor: AppColors.background,
        elevation: 0,
      ),
      body: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          children: [
            // Timer Display
            Obx(() => Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.orange.withOpacity(0.1),
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: Colors.orange.withOpacity(0.4)),
              ),
              child: Row(
                children: [
                  const Icon(Icons.timer_outlined, color: Colors.orange),
                  const SizedBox(width: 12),
                  Text(
                    "Sisa Waktu Bayar: ${controller.formattedTime}",
                    style: const TextStyle(color: Colors.orange, fontWeight: FontWeight.bold),
                  ),
                ],
              ),
            )),
            
            const SizedBox(height: 32),

            // Order Summary Card
            Container(
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                color: AppColors.cardSurface,
                borderRadius: BorderRadius.circular(24),
                border: Border.all(color: Colors.white.withOpacity(0.05)),
              ),
              child: Column(
                children: [
                  _buildSummaryRow("Order ID", "#${orderData['id']}"),
                  _buildSummaryRow("Quantity", "${orderData['quantity']} Ticket"),
                  const Divider(color: Colors.white10, height: 40),
                  _buildSummaryRow(
                    "Total Bill", 
                    currencyFormatter.format(orderData['total']), 
                    isTotal: true
                  ),
                ],
              ),
            ),
            
            const Spacer(),

            // Pay Now Button
            SizedBox(
              width: double.infinity,
              child: Obx(() => ElevatedButton(
                onPressed: controller.isLoading.value 
                  ? null 
                  : () => controller.confirmPayment(orderData['id']),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primary,
                  foregroundColor: Colors.black, // Teks Gelap
                  padding: const EdgeInsets.symmetric(vertical: 20),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                  elevation: 0,
                ),
                child: controller.isLoading.value 
                  ? const SizedBox(
                      height: 24, 
                      width: 24, 
                      child: CircularProgressIndicator(color: Colors.black, strokeWidth: 3)
                    )
                  : const Text("Pay Now", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
              )),
            ),
            const SizedBox(height: 24),
          ],
        ),
      ),
    );
  }

  Widget _buildSummaryRow(String label, String value, {bool isTotal = false}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: const TextStyle(color: AppColors.textSecondary, fontSize: 14)),
          Text(
            value, 
            style: TextStyle(
              color: isTotal ? AppColors.primary : AppColors.textPrimary,
              fontWeight: isTotal ? FontWeight.bold : FontWeight.normal,
              fontSize: isTotal ? 22 : 16,
            )
          ),
        ],
      ),
    );
  }
}