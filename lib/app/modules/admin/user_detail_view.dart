import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:iconsax/iconsax.dart';
import 'package:jwt_decoder/jwt_decoder.dart'; // Pastikan install: flutter pub add jwt_decoder
import 'package:shared_preferences/shared_preferences.dart';
import 'package:dio/dio.dart';
import '../../data/services/api_config.dart';
import '../../theme/app_colors.dart';
import 'manage_users_controller.dart'; // Untuk refresh list setelah delete

class UserDetailController extends GetxController {
  final Dio _dio = Dio();
  
  // Data user yang sedang dilihat (dikirim dari halaman sebelumnya)
  late RxMap<String, dynamic> user;
  
  // Status Hak Akses
  var isMe = false.obs;       // Apakah ini akun saya?
  var isAdmin = false.obs;    // Apakah saya admin?
  var isLoading = false.obs;

  // Controller untuk Form Edit
  final usernameC = TextEditingController();
  final emailC = TextEditingController();

  @override
  void onInit() {
    super.onInit();
    user = (Get.arguments as Map<String, dynamic>).obs;
    usernameC.text = user['username'];
    emailC.text = user['email'];
    checkPermissions();
  }

  Future<void> checkPermissions() async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('token');
    
    if (token != null) {
      Map<String, dynamic> decodedToken = JwtDecoder.decode(token);
      String myId = decodedToken['sub']; // ID saya dari token
      String myRole = decodedToken['role']; 

      // Logika: Ini akun saya jika ID di token == ID user yang dilihat
      // Backend pakai _id, jadi kita cek user['_id']
      isMe.value = myId == user['_id'];
      isAdmin.value = myRole == 'admin';
    }
  }

  // --- FUNGSI EDIT (Hanya Aktif jika isMe == true) ---
  Future<void> updateProfile() async {
    try {
      isLoading.value = true;
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString('token');

      final response = await _dio.put(
        "${ApiConfig.updateUser}/${user['_id']}",
        data: {
          "username": usernameC.text,
          "email": emailC.text,
        },
        options: Options(headers: {"Authorization": "Bearer $token"}),
      );

      if (response.statusCode == 200) {
        // 1. Refresh list user di halaman sebelumnya (biar namanya berubah di list)
        Get.find<ManageUsersController>().fetchUsers();

        // 2. Tutup halaman detail (Kembali ke List)
        Get.back();

        // 3. Tampilkan Notifikasi Sukses (Akan muncul di halaman List)
        Get.snackbar(
          "Sukses", 
          "Data profil berhasil diperbarui", 
          backgroundColor: AppColors.success, 
          colorText: Colors.white,
          snackPosition: SnackPosition.TOP,
          margin: const EdgeInsets.all(16),
          duration: const Duration(seconds: 3), // Durasi tampil
        );
      }
    } on DioException catch (e) {
      Get.snackbar(
        "Gagal", 
        e.response?.data['message'] ?? "Gagal update", 
        backgroundColor: AppColors.error, 
        colorText: Colors.white
      );
    } finally {
      isLoading.value = false;
    }
  }

  // --- FUNGSI HAPUS (Hanya Aktif jika isAdmin == true DAN user['role'] != admin) ---
  Future<void> deleteUser() async {
    Get.defaultDialog(
      title: "Hapus User?",
      middleText: "User ini akan dihapus permanen.",
      textConfirm: "Hapus",
      textCancel: "Batal",
      confirmTextColor: Colors.white,
      buttonColor: Colors.red,
      onConfirm: () async {
        Get.back(); // Tutup dialog
        try {
          isLoading.value = true;
          final prefs = await SharedPreferences.getInstance();
          final token = prefs.getString('token');

          await _dio.delete(
            "${ApiConfig.deleteUser}/${user['_id']}",
            options: Options(headers: {"Authorization": "Bearer $token"}),
          );

          Get.back(); // Kembali ke list
          Get.snackbar("Sukses", "User berhasil dihapus");
          Get.find<ManageUsersController>().fetchUsers(); // Refresh list
        } on DioException catch (e) {
          Get.snackbar("Gagal", e.response?.data['message'] ?? "Error", backgroundColor: AppColors.error);
        } finally {
          isLoading.value = false;
        }
      }
    );
  }
}

class UserDetailView extends StatelessWidget {
  const UserDetailView({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = Get.put(UserDetailController());

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text("User Detail", style: TextStyle(color: Colors.white)),
        backgroundColor: AppColors.background,
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: Padding(
        padding: const EdgeInsets.all(24),
        child: Obx(() => Column(
          children: [
            // Avatar Besar
            CircleAvatar(
              radius: 50,
              backgroundColor: controller.user['role'] == 'admin' 
                  ? AppColors.primary.withOpacity(0.2) 
                  : Colors.grey.withOpacity(0.2),
              child: Icon(
                Iconsax.user, 
                size: 50, 
                color: controller.user['role'] == 'admin' ? AppColors.primary : Colors.white
              ),
            ),
            const SizedBox(height: 30),

            // Form Fields (ReadOnly kalau bukan akun sendiri)
            _buildTextField("Username", controller.usernameC, controller.isMe.value),
            const SizedBox(height: 16),
            _buildTextField("Email", controller.emailC, controller.isMe.value),
            
            const SizedBox(height: 16),
            // Info Role (Tidak bisa diedit siapapun)
            Container(
              padding: const EdgeInsets.all(16),
              width: double.infinity,
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.05),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text("Role Access", style: TextStyle(color: Colors.grey)),
                  Text(
                    controller.user['role'].toString().toUpperCase(), 
                    style: const TextStyle(color: AppColors.primary, fontWeight: FontWeight.bold)
                  ),
                ],
              ),
            ),

            const Spacer(),

            // --- TOMBOL UPDATE (Hanya muncul jika isMe == true) ---
            if (controller.isMe.value)
              SizedBox(
                width: double.infinity,
                height: 50,
                child: ElevatedButton(
                  onPressed: controller.isLoading.value ? null : () => controller.updateProfile(),
                  style: ElevatedButton.styleFrom(backgroundColor: AppColors.primary),
                  child: controller.isLoading.value 
                      ? const CircularProgressIndicator(color: Colors.white)
                      : const Text("Simpan Perubahan", style: TextStyle(color: Color.fromARGB(255, 20, 53, 61), fontWeight: FontWeight.bold)),
                ),
              ),

            const SizedBox(height: 16),

            // --- TOMBOL DELETE (Hanya Admin yang lihat, dan bukan admin targetnya) ---
            if (controller.isAdmin.value && controller.user['role'] != 'admin')
              SizedBox(
                width: double.infinity,
                height: 50,
                child: OutlinedButton(
                  onPressed: controller.isLoading.value ? null : () => controller.deleteUser(),
                  style: OutlinedButton.styleFrom(
                    side: const BorderSide(color: Colors.red),
                    foregroundColor: Colors.red,
                  ),
                  child: const Text("Hapus User Ini"),
                ),
              ),
          ],
        )),
      ),
    );
  }

  Widget _buildTextField(String label, TextEditingController controller, bool isEditable) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: const TextStyle(color: Colors.grey, fontSize: 12)),
        const SizedBox(height: 8),
        TextField(
          controller: controller,
          enabled: isEditable, // Kunci jika bukan akun sendiri
          style: TextStyle(color: isEditable ? Colors.white : Colors.white60),
          decoration: InputDecoration(
            filled: true,
            fillColor: isEditable ? Colors.white.withOpacity(0.05) : Colors.black26,
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide.none,
            ),
            suffixIcon: isEditable ? const Icon(Iconsax.edit, color: Colors.white30, size: 18) : null,
          ),
        ),
      ],
    );
  }
}