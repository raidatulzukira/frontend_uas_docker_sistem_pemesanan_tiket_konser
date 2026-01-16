import 'dart:io'; // Import untuk File()
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:iconsax/iconsax.dart';
import '../../theme/app_colors.dart';
import 'manage_catalog_controller.dart';
import '../auth/widgets/custom_textfield.dart';

class AddConcertView extends StatelessWidget {
  const AddConcertView({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = Get.find<ManageCatalogController>();
    controller.clearForm();

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text("New Concert", style: TextStyle(color: Colors.white)),
        backgroundColor: AppColors.background,
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          children: [
            // --- KOTAK UPLOAD GAMBAR ---
            GestureDetector(
              onTap: () => controller.pickImage(),
              child: Obx(() {
                bool hasImage = controller.pickedImagePath.value.isNotEmpty;
                return Container(
                  height: 200,
                  width: double.infinity,
                  decoration: BoxDecoration(
                    color: AppColors.cardSurface,
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: Colors.white24),
                    // Jika ada gambar, tampilkan sebagai background
                    image: hasImage 
                      ? DecorationImage(
                          image: FileImage(File(controller.pickedImagePath.value)),
                          fit: BoxFit.cover,
                        )
                      : null,
                  ),
                  child: hasImage 
                    ? null // Kalau ada gambar, icon hilang
                    : const Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(Iconsax.gallery_add, size: 40, color: AppColors.primary),
                          SizedBox(height: 8),
                          Text("Tap to upload poster", style: TextStyle(color: Colors.grey)),
                        ],
                      ),
                );
              }),
            ),
            
            const SizedBox(height: 24),

            // Form Fields
            CustomTextField(
              label: "Concert Name",
              icon: Iconsax.music,
              controller: controller.nameC,
            ),
            const SizedBox(height: 16),
            CustomTextField(
              label: "Location",
              icon: Iconsax.location,
              controller: controller.locationC,
            ),
            const SizedBox(height: 16),
            
            GestureDetector(
              onTap: () => controller.pickDate(context),
              child: AbsorbPointer(
                child: CustomTextField(
                  label: "Date",
                  icon: Iconsax.calendar,
                  controller: controller.dateC,
                ),
              ),
            ),
            
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: CustomTextField(
                    label: "Price (IDR)",
                    icon: Iconsax.money,
                    controller: controller.priceC,
                    isNumber: true,
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: CustomTextField(
                    label: "Stock",
                    icon: Iconsax.ticket,
                    controller: controller.stockC,
                    isNumber: true,
                  ),
                ),
              ],
            ),
            
            const SizedBox(height: 40),
            
            SizedBox(
              width: double.infinity,
              height: 50,
              child: Obx(() => ElevatedButton(
                onPressed: controller.isLoading.value ? null : () => controller.addConcert(),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primary,
                  foregroundColor: Colors.black,
                ),
                child: controller.isLoading.value 
                  ? const CircularProgressIndicator(color: Colors.white)
                  : const Text("Save Concert", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
              )),
            ),
          ],
        ),
      ),
    );
  }
}