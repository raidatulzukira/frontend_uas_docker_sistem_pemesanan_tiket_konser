import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:dio/dio.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../data/services/api_config.dart';
import '../../theme/app_colors.dart';
import '../home/home_view.dart';
import '../admin/admin_view.dart';

class AuthController extends GetxController {
  final Dio _dio = Dio();

  // Text Controllers untuk input form
  final emailController = TextEditingController();
  final passwordController = TextEditingController();
  final usernameController = TextEditingController(); // Khusus Register

  // Reactive variables untuk UI
  var isLoading = false.obs;
  var isObscure = true.obs; // Untuk hide/show password

  // Fungsi Toggle Password Visibility
  void togglePasswordVisibility() {
    isObscure.value = !isObscure.value;
  }

  // --- LOGIN FUNCTION ---
  Future<void> login() async {
    if (emailController.text.isEmpty || passwordController.text.isEmpty) {
      Get.snackbar(
        "Error",
        "Email dan Password wajib diisi",
        backgroundColor: AppColors.error,
        colorText: Colors.white,
      );
      return;
    }

    try {
      isLoading.value = true;

      final response = await _dio.post(
        ApiConfig.login,
        data: {
          "email": emailController.text,
          "password": passwordController.text,
        },
      );

      // Jika sukses (Status 200)
      if (response.statusCode == 200) {
        final data = response.data;
        final String token = data['token'];
        final String role = data['user']['role']; // 'admin' atau 'user'

        // Simpan token ke HP (Shared Preferences)
        final prefs = await SharedPreferences.getInstance();
        await prefs.setString('token', token);
        await prefs.setString('role', role);

        Get.snackbar(
          "Sukses",
          "Selamat datang kembali, ${data['user']['username']}!",
          backgroundColor: AppColors.success,
          colorText: Colors.white,
        );

        // LOGIKA NAVIGASI BERDASARKAN ROLE
        // if (role == 'admin') {
        //   // Get.offAllNamed('/admin-dashboard');
        // } else {
        //   // Jika user biasa, kembalikan ke Home tapi reset stack agar tombol back tidak ke login lagi
        //   Get.offAll(
        //     () => const HomeView(),
        //   ); // Kita gunakan class langsung agar aman
        // }

        if (role == 'admin') {
          // Arahkan ke Admin Dashboard
          Get.offAll(() => const AdminView());
        } else {
          // Jika user biasa, kembalikan ke Home
          Get.offAll(() => const HomeView());
        }
        // if (role == 'admin') {
        //    // Nanti kita buat rute ini
        //    Get.offAllNamed('/admin-dashboard');
        // } else {
        //    // Nanti kita buat rute ini
        //    Get.offAllNamed('/home');
        // }
      }
    } on DioException catch (e) {
      // Menangkap error dari backend (misal: password salah)
      String message =
          e.response?.data['message'] ?? "Terjadi kesalahan koneksi";
      Get.snackbar(
        "Gagal Login",
        message,
        backgroundColor: AppColors.error,
        colorText: Colors.white,
      );
    } finally {
      isLoading.value = false;
    }
  }

  // --- REGISTER FUNCTION ---
  Future<void> register() async {
    if (usernameController.text.isEmpty ||
        emailController.text.isEmpty ||
        passwordController.text.isEmpty) {
      Get.snackbar(
        "Error",
        "Semua kolom wajib diisi",
        backgroundColor: AppColors.error,
        colorText: Colors.white,
      );
      return;
    }

    try {
      isLoading.value = true;

      final response = await _dio.post(
        ApiConfig.register,
        data: {
          "username": usernameController.text,
          "email": emailController.text,
          "password": passwordController.text,
        },
      );

      // --- BAGIAN INI YANG DIUBAH ---
      if (response.statusCode == 201) {
        // 1. Tutup keyboard agar rapi
        FocusManager.instance.primaryFocus?.unfocus();

        // 2. Kembali ke halaman Login (Mundur satu langkah)
        // Ganti Get.offNamed('/login') menjadi Get.back()
        Get.back();

        // 3. Tampilkan pesan sukses SETELAH kembali ke login
        Get.snackbar(
          "Registrasi Berhasil",
          "Akun berhasil dibuat! Silakan tekan tombol Login.",
          backgroundColor: AppColors.success,
          colorText: Colors.white,
          snackPosition: SnackPosition.TOP, // Muncul di atas
          margin: const EdgeInsets.all(16),
          duration: const Duration(seconds: 4),
        );
      }
      // -----------------------------
    } on DioException catch (e) {
      String message = e.response?.data['message'] ?? "Gagal mendaftar";
      Get.snackbar(
        "Error",
        message,
        backgroundColor: AppColors.error,
        colorText: Colors.white,
      );
    } finally {
      isLoading.value = false;
    }
  }
}
