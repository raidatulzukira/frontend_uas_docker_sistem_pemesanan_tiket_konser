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

  final emailController = TextEditingController();
  final passwordController = TextEditingController();
  final usernameController = TextEditingController();

  var isLoading = false.obs;
  var isObscure = true.obs;

  var isLoggedIn = false.obs;
  var userToken = "".obs;
  var userRole = "".obs;

  // --- TAMBAHAN: VARIABEL UNTUK MENYIMPAN USER ID ---
  var userId =
      "".obs; // Gunakan String karena MongoDB ID biasanya berupa string/objectID

  @override
  void onInit() {
    super.onInit();
    checkInitialStatus();
  }

  void checkInitialStatus() async {
    final prefs = await SharedPreferences.getInstance();
    String? token = prefs.getString('token');
    String? role = prefs.getString('role');
    String? savedId = prefs.getString('userId'); // Ambil ID yang tersimpan

    if (token != null && token.isNotEmpty) {
      isLoggedIn.value = true;
      userToken.value = token;
      userRole.value = role ?? "user";
      userId.value = savedId ?? ""; // Masukkan ID ke variabel reactive
      print("User terautentikasi dengan ID: ${userId.value}");
    }
  }

  void togglePasswordVisibility() {
    isObscure.value = !isObscure.value;
  }

  // Cari bagian login di AuthController

  Future<void> login() async {
    if (emailController.text.isEmpty || passwordController.text.isEmpty) {
      _showErrorSnackbar("Email dan Password wajib diisi");
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

      if (response.statusCode == 200) {
        final data = response.data;

        // 1. Ambil Data dari Response
        String idDariMongo =
            (data['user']['_id'] ?? data['user']['id']).toString();
        String token = data['token'];
        String role = data['user']['role']; // 'admin' atau 'user'

        // 2. Simpan ke SharedPreferences (Memori HP)
        final prefs = await SharedPreferences.getInstance();
        await prefs.setString('token', token);
        await prefs.setString('userId', idDariMongo);
        await prefs.setString('role', role);

        // 3. Update Variabel Reaktif (Update UI)
        userId.value = idDariMongo;
        userToken.value = token;
        userRole.value = role;
        isLoggedIn.value = true;

        Get.snackbar(
          "Sukses",
          "Selamat datang, ${data['user']['username']}!",
          backgroundColor: AppColors.success,
          colorText: Colors.white,
        );

        // --- PERBAIKAN LOGIKA NAVIGASI (ROLE BASED) ---
        if (role == 'admin') {
          // Jika admin, arahkan ke AdminView
          Get.offAll(() => const AdminView());
        } else {
          // Jika user biasa, arahkan ke HomeView
          Get.offAll(() => const HomeView());
        }
        // ----------------------------------------------

        // Bersihkan Form
        emailController.clear();
        passwordController.clear();
      }
    } on DioException catch (e) {
      String msg = e.response?.data['message'] ?? "Email atau Password salah";
      _showErrorSnackbar(msg);
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> register() async {
    if (usernameController.text.isEmpty ||
        emailController.text.isEmpty ||
        passwordController.text.isEmpty) {
      _showErrorSnackbar("Semua kolom wajib diisi");
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

      if (response.statusCode == 201) {
        FocusManager.instance.primaryFocus?.unfocus();
        Get.back();
        Get.snackbar(
          "Berhasil",
          "Akun dibuat! Silakan login.",
          backgroundColor: AppColors.success,
          colorText: Colors.white,
        );
        usernameController.clear();
      }
    } on DioException catch (e) {
      _showErrorSnackbar(e.response?.data['message'] ?? "Gagal mendaftar");
    } finally {
      isLoading.value = false;
    }
  }

  void logout() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.clear();

    isLoggedIn.value = false;
    userToken.value = "";
    userRole.value = "";
    userId.value = ""; // Kosongkan ID saat logout

    Get.offAll(() => const HomeView());
    Get.snackbar("Logout", "Anda telah keluar dari aplikasi");
  }

  void _showErrorSnackbar(String message) {
    Get.snackbar(
      "Error",
      message,
      backgroundColor: AppColors.error,
      colorText: Colors.white,
    );
  }
}
