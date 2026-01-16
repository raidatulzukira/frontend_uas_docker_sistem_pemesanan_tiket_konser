import 'package:get/get.dart';
import 'package:dio/dio.dart';
import '../../data/services/api_config.dart';

class HomeController extends GetxController {
  final Dio _dio = Dio();
  
  var isLoading = true.obs;
  var concertList = <dynamic>[].obs;

  @override
  void onInit() {
    super.onInit();
    fetchConcerts();
  }

  Future<void> fetchConcerts() async {
    try {
      isLoading.value = true;
      // Ambil data dari endpoint publik (tanpa token tidak masalah)
      final response = await _dio.get(ApiConfig.concerts);
      
      if (response.statusCode == 200) {
        concertList.assignAll(response.data);
      }
    } catch (e) {
      // Silent error atau tampilkan snackbar jika perlu
      print("Gagal ambil data home: $e");
    } finally {
      isLoading.value = false;
    }
  }
}