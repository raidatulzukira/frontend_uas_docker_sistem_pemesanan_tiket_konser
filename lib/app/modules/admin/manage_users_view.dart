import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:iconsax/iconsax.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../../theme/app_colors.dart';
import 'manage_users_controller.dart';
import 'user_detail_view.dart';

class ManageUsersView extends StatelessWidget {
  const ManageUsersView({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = Get.put(ManageUsersController());

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.background,
        elevation: 0,
        title: const Text("Manage Users", style: TextStyle(color: Colors.white)),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Get.back(),
        ),
        actions: [
          IconButton(
            icon: const Icon(Iconsax.refresh, color: AppColors.primary),
            onPressed: () => controller.fetchUsers(),
          )
        ],
      ),
      body: Obx(() {
        if (controller.isLoading.value) {
          return const Center(child: CircularProgressIndicator(color: AppColors.primary));
        }

        if (controller.errorMessage.isNotEmpty) {
          return Center(
            child: Text(controller.errorMessage.value, 
            style: const TextStyle(color: Colors.redAccent)),
          );
        }

        if (controller.userList.isEmpty) {
          return const Center(child: Text("Belum ada user terdaftar", style: TextStyle(color: Colors.white54)));
        }

        return ListView.builder(
          padding: const EdgeInsets.all(20),
          itemCount: controller.userList.length,
          itemBuilder: (context, index) {
            final user = controller.userList[index];
            final role = user['role'] ?? 'user';
            final isAdmin = role == 'admin';

            // --- BAGIAN INI YANG DIUBAH (DIBUNGKUS GESTURE DETECTOR) ---
            return GestureDetector(
              onTap: () {
                // Saat diklik, pindah ke UserDetailView bawa data 'user'
                Get.to(() => const UserDetailView(), arguments: user);
              },
              child: Container(
                margin: const EdgeInsets.only(bottom: 16),
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: const Color(0xFF253334),
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(
                    color: isAdmin ? AppColors.primary.withOpacity(0.5) : Colors.white10,
                  ),
                ),
                child: Row(
                  children: [
                    // Avatar Circle
                    Container(
                      width: 50, height: 50,
                      decoration: BoxDecoration(
                        color: isAdmin ? AppColors.primary.withOpacity(0.2) : Colors.white10,
                        shape: BoxShape.circle,
                      ),
                      child: Icon(
                        Iconsax.user, 
                        color: isAdmin ? AppColors.primary : Colors.white70
                      ),
                    ),
                    const SizedBox(width: 16),
                    
                    // Info User
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            user['username'] ?? "No Name",
                            style: const TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                              fontSize: 16,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            user['email'] ?? "-",
                            style: TextStyle(
                              color: Colors.white.withOpacity(0.5),
                              fontSize: 12,
                            ),
                          ),
                        ],
                      ),
                    ),

                    // Badge Role
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                      decoration: BoxDecoration(
                        color: isAdmin ? AppColors.primary : Colors.grey.withOpacity(0.2),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Text(
                        role.toUpperCase(),
                        style: TextStyle(
                          color: isAdmin ? Colors.black : Colors.white70,
                          fontSize: 10,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ],
                ),
              ).animate().fadeIn(delay: (100 * index).ms).slideX(),
            );
            // -----------------------------------------------------------
          },
        );
      }),
    );
  }
}