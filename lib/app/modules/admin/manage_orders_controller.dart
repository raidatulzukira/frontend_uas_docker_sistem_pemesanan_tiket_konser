import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:dio/dio.dart';
import '../../data/services/api_config.dart';

class ManageOrdersController extends GetxController {
  final Dio _dio = Dio();
  
  var isLoading = true.obs;
  var orderList = <dynamic>[].obs;

  @override
  void onInit() {
    super.onInit();
    fetchOrders();
  }

  Future<void> fetchOrders() async {
    try {
      isLoading.value = true;
      // Panggil API Golang (GET /orders)
      final response = await _dio.get(ApiConfig.getAllOrders);
      
      if (response.statusCode == 200) {
        // Sesuaikan dengan format response JSON dari Golang temanmu
        // Biasanya: { "data": [...] } atau langsung [...]
        if (response.data is Map && response.data['data'] != null) {
           orderList.assignAll(response.data['data']);
        } else if (response.data is List) {
           orderList.assignAll(response.data);
        }
      }
    } catch (e) {
      // Print error lengkap ke terminal bawah VS Code
      print("===== ERROR DETAIL =====");
      print(e);
      if (e is DioException) {
        print("Status Code: ${e.response?.statusCode}");
        print("Response Data: ${e.response?.data}");
      }
      print("========================");

      // Tampilkan error di layar HP biar langsung kelihatan
      Get.snackbar(
        "Error", 
        e.toString(), // Ini akan memunculkan pesan error teknisnya
        backgroundColor: Colors.red, 
        colorText: Colors.white,
        duration: const Duration(seconds: 10), // Tahan lama biar sempat baca
      );
    } finally {
      isLoading.value = false;
    }
  }
  
  // Fitur Refresh Tarik Layar
  Future<void> refreshData() async {
    await fetchOrders();
  }
}