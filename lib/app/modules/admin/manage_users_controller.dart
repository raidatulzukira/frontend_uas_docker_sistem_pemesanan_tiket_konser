import 'package:get/get.dart';
import 'package:dio/dio.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../data/services/api_config.dart';

class ManageUsersController extends GetxController {
  final Dio _dio = Dio();
  
  // State Variables
  var isLoading = true.obs;
  var userList = <dynamic>[].obs; // Menyimpan list user
  var errorMessage = "".obs;

  @override
  void onInit() {
    super.onInit();
    fetchUsers(); // Otomatis ambil data saat halaman dibuka
  }

  Future<void> fetchUsers() async {
    try {
      isLoading.value = true;
      errorMessage.value = "";

      // 1. Ambil Token dari HP
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString('token');

      if (token == null) {
        errorMessage.value = "Token tidak ditemukan. Silakan login ulang.";
        isLoading.value = false;
        return;
      }

      // 2. Request ke Backend dengan Header Authorization
      final response = await _dio.get(
        ApiConfig.getAllUsers,
        options: Options(
          headers: {
            "Authorization": "Bearer $token", // Kunci masuk backend
          },
        ),
      );

      // 3. Simpan data ke list
      if (response.statusCode == 200) {
        userList.assignAll(response.data);
      }
    } on DioException catch (e) {
      errorMessage.value = "Gagal mengambil data: ${e.message}";
      // Jika token expired (401), mungkin perlu logout otomatis (nanti saja)
    } finally {
      isLoading.value = false;
    }
  }
}