import 'dart:io';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:iconsax/iconsax.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:intl/intl.dart'; // Jangan lupa ini
import '../../theme/app_colors.dart';
import 'manage_catalog_controller.dart';
import '../auth/widgets/custom_textfield.dart';

class ConcertDetailView extends StatefulWidget {
  final Map<String, dynamic> concert;
  const ConcertDetailView({super.key, required this.concert});

  @override
  State<ConcertDetailView> createState() => _ConcertDetailViewState();
}

class _ConcertDetailViewState extends State<ConcertDetailView> {
  final controller = Get.find<ManageCatalogController>();
  bool isEditing = false; 

  @override
  void initState() {
    super.initState();
    controller.initFormWithData(widget.concert);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SingleChildScrollView(
        child: Column(
          children: [
            // --- HEADER GAMBAR (SAMA SEPERTI SEBELUMNYA) ---
            Stack(
              children: [
                GestureDetector(
                  onTap: isEditing ? () => controller.pickImage() : null,
                  child: Obx(() {
                    ImageProvider? imageProvider;
                    if (controller.pickedImagePath.value.isNotEmpty) {
                      imageProvider = FileImage(File(controller.pickedImagePath.value));
                    } else if (controller.currentImageUrl.value.isNotEmpty) {
                      imageProvider = NetworkImage(controller.currentImageUrl.value);
                    }

                    return Container(
                      height: 350,
                      width: double.infinity,
                      decoration: BoxDecoration(
                        color: const Color(0xFF2C5364),
                        borderRadius: const BorderRadius.only(
                          bottomLeft: Radius.circular(40),
                          bottomRight: Radius.circular(40),
                        ),
                        image: imageProvider != null 
                          ? DecorationImage(image: imageProvider, fit: BoxFit.cover)
                          : null,
                      ),
                      child: imageProvider == null
                        ? Center(child: Icon(Iconsax.music_dashboard, size: 80, color: Colors.white.withOpacity(0.2)))
                        : null,
                    );
                  }),
                ),
                // Gradient & Tombol Back/Delete (Sama)
                Container(
                  height: 350,
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                      colors: [Colors.transparent, Colors.black.withOpacity(0.8)],
                    ),
                    borderRadius: const BorderRadius.only(bottomLeft: Radius.circular(40), bottomRight: Radius.circular(40)),
                  ),
                ),
                Positioned(
                  top: 50, left: 20,
                  child: CircleAvatar(
                    backgroundColor: Colors.black45,
                    child: IconButton(icon: const Icon(Icons.arrow_back, color: Colors.white), onPressed: () => Get.back()),
                  ),
                ),
                Positioned(
                  top: 50, right: 20,
                  child: CircleAvatar(
                    backgroundColor: Colors.red.withOpacity(0.8),
                    child: IconButton(icon: const Icon(Iconsax.trash, color: Colors.white), onPressed: () => _showDeleteConfirm()),
                  ),
                ),
                if (isEditing)
                  Positioned.fill(
                    child: Center(
                      child: Container(
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(color: Colors.black54, shape: BoxShape.circle, border: Border.all(color: Colors.white, width: 2)),
                        child: const Icon(Iconsax.camera, color: Colors.white, size: 40),
                      ).animate().scale(),
                    ),
                  ),
              ],
            ),

            // --- BODY CONTENT ---
            Padding(
              padding: const EdgeInsets.all(24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Header Title & Edit Switch
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Expanded(
                        child: Text(
                          isEditing ? "Edit Mode" : widget.concert['name'],
                          style: const TextStyle(color: Colors.white, fontSize: 24, fontWeight: FontWeight.bold),
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      Transform.scale(
                        scale: 0.8,
                        child: Switch(
                          value: isEditing,
                          activeColor: AppColors.primary,
                          onChanged: (val) {
                            setState(() => isEditing = val);
                            if (!val) controller.initFormWithData(widget.concert);
                          },
                        ),
                      ),
                    ],
                  ),
                  
                  const SizedBox(height: 20),

                  // --- LOGIKA TAMPILAN (VIEW vs EDIT) ---
                  AnimatedCrossFade(
                    duration: 300.ms,
                    firstChild: _buildRichDetailView(), // Tampilan Keren (View)
                    secondChild: _buildEditForm(),      // Tampilan Form (Edit)
                    crossFadeState: isEditing ? CrossFadeState.showSecond : CrossFadeState.showFirst,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  // --- WIDGET 1: MODE VIEW (Tampilan Info Keren) ---
  Widget _buildRichDetailView() {
    final currencyFormatter = NumberFormat.currency(locale: 'id_ID', symbol: 'IDR ', decimalDigits: 0);
    String price = currencyFormatter.format(widget.concert['price'] ?? 0);
    
    DateTime date = DateTime.tryParse(widget.concert['date']) ?? DateTime.now();
    String fullDate = DateFormat('EEEE, d MMMM yyyy').format(date); // Senin, 10 Januari 2026

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Lokasi
        Row(
          children: [
            const Icon(Iconsax.location5, color: AppColors.primary, size: 20),
            const SizedBox(width: 8),
            Text(widget.concert['location'], style: const TextStyle(color: Colors.white70, fontSize: 16)),
          ],
        ),
        
        const SizedBox(height: 24),

        // Kartu Info (Date & Stock)
        Row(
          children: [
            // Kartu Tanggal
            Expanded(
              child: Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: AppColors.cardSurface,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: Colors.white10),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Icon(Iconsax.calendar5, color: Colors.orangeAccent),
                    const SizedBox(height: 8),
                    const Text("Concert Date", style: TextStyle(color: Colors.grey, fontSize: 12)),
                    const SizedBox(height: 4),
                    Text(DateFormat('d MMM yyyy').format(date), style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 16)),
                  ],
                ),
              ),
            ),
            const SizedBox(width: 16),
            // Kartu Harga
            Expanded(
              child: Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: AppColors.primary.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: AppColors.primary.withOpacity(0.3)),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Icon(Iconsax.ticket, color: AppColors.primary),
                    const SizedBox(height: 8),
                    const Text("Starting Price", style: TextStyle(color: Colors.grey, fontSize: 12)),
                    const SizedBox(height: 4),
                    Text(price.replaceAll("IDR", ""), style: const TextStyle(color: AppColors.primary, fontWeight: FontWeight.bold, fontSize: 16)),
                  ],
                ),
              ),
            ),
          ],
        ),

        const SizedBox(height: 24),

        // Statistik Stok
        const Text("Ticket Availability", style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 18)),
        const SizedBox(height: 12),
        Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: const Color(0xFF1E1E1E),
            borderRadius: BorderRadius.circular(16),
          ),
          child: Column(
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text("Available Stock", style: TextStyle(color: Colors.grey)),
                  Text("${widget.concert['stock']} Tickets", style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                ],
              ),
              const SizedBox(height: 12),
              // Dummy Progress Bar (Biar kelihatan hidup)
              ClipRRect(
                borderRadius: BorderRadius.circular(10),
                child: LinearProgressIndicator(
                  value: 0.7, // Dummy value 70%
                  backgroundColor: Colors.white10,
                  color: (widget.concert['stock'] < 100) ? Colors.red : AppColors.primary,
                  minHeight: 8,
                ),
              ),
              const SizedBox(height: 8),
              if (widget.concert['stock'] < 100)
                const Align(
                  alignment: Alignment.centerRight,
                  child: Text("Almost Sold Out!", style: TextStyle(color: Colors.redAccent, fontSize: 12, fontWeight: FontWeight.bold)),
                ),
            ],
          ),
        ),

        const SizedBox(height: 24),
        
        // Deskripsi Dummy (Karena database belum ada kolom deskripsi)
        // const Text("About Event", style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 18)),
        // const SizedBox(height: 8),
        // Text(
        //   "This is the official concert event for ${widget.concert['name']}. "
        //   "Enjoy an unforgettable night at ${widget.concert['location']}. "
        //   "Make sure to secure your tickets before they run out!",
        //   style: const TextStyle(color: Colors.white60, height: 1.5),
        // ),
      ],
    ).animate().fadeIn().slideY(begin: 0.1);
  }

  // --- WIDGET 2: MODE EDIT (Form Isian) ---
  Widget _buildEditForm() {
    return Column(
      children: [
        GestureDetector(
          onTap: () => controller.pickImage(),
          child: Container(
            margin: const EdgeInsets.only(bottom: 20),
            height: 100,
            width: double.infinity,
            decoration: BoxDecoration(
              color: AppColors.primary.withOpacity(0.1),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: AppColors.primary, width: 1, style: BorderStyle.solid),
            ),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: const [
                Icon(Iconsax.gallery_edit, size: 24, color: AppColors.primary),
                SizedBox(height: 8),
                Text("Change Poster Image", style: TextStyle(color: AppColors.primary, fontWeight: FontWeight.bold)),
              ],
            ),
          ),
        ),
        
        CustomTextField(label: "Concert Name", icon: Iconsax.music, controller: controller.nameC),
        const SizedBox(height: 16),
        CustomTextField(label: "Location", icon: Iconsax.location, controller: controller.locationC),
        const SizedBox(height: 16),
        GestureDetector(
          onTap: () => controller.pickDate(context),
          child: AbsorbPointer(child: CustomTextField(label: "Date", icon: Iconsax.calendar, controller: controller.dateC)),
        ),
        const SizedBox(height: 16),
        Row(
          children: [
            Expanded(child: CustomTextField(label: "Price (IDR)", icon: Iconsax.money, controller: controller.priceC, isNumber: true)),
            const SizedBox(width: 16),
            Expanded(child: CustomTextField(label: "Stock", icon: Iconsax.ticket, controller: controller.stockC, isNumber: true)),
          ],
        ),
        const SizedBox(height: 30),
        SizedBox(
          width: double.infinity,
          height: 50,
          child: Obx(() => ElevatedButton(
            onPressed: controller.isLoading.value ? null : () => controller.updateConcert(widget.concert['id']),
            style: ElevatedButton.styleFrom(backgroundColor: AppColors.primary),
            child: controller.isLoading.value 
              ? const CircularProgressIndicator(color: Colors.white)
              : const Text("Save Changes", style: TextStyle(fontWeight: FontWeight.bold, color: Colors.black)),
          )),
        ),
      ],
    ).animate().fadeIn();
  }

  void _showDeleteConfirm() {
    Get.defaultDialog(
      title: "Hapus Konser?",
      middleText: "Yakin ingin menghapus ${widget.concert['name']}?",
      textConfirm: "Hapus",
      textCancel: "Batal",
      confirmTextColor: Colors.white,
      buttonColor: Colors.red,
      onConfirm: () {
        Get.back();
        controller.deleteConcert(widget.concert['id']);
      }
    );
  }
}