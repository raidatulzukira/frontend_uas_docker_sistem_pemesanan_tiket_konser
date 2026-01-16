import 'package:dio/dio.dart';
import 'package:get/get.dart';
import '../../data/services/api_config.dart';
import '../auth/auth_controller.dart';

class TicketController extends GetxController {
  final Dio _dio = Dio();
  var myTickets = [].obs;
  var isLoading = false.obs;

  @override
  void onInit() {
    super.onInit();
    fetchMyTickets();
  }

  Future<void> fetchMyTickets() async {
    final auth = Get.find<AuthController>();
    if (!auth.isLoggedIn.value) return;

    try {
      isLoading.value = true;
      // Ambil data dari Go Service
      final response = await _dio.get(ApiConfig.userOrders(auth.userId.value));
      if (response.statusCode == 200) {
        myTickets.value = response.data;
      }
    } catch (e) {
      print("Error fetch tickets: $e");
    } finally {
      isLoading.value = false;
    }
  }
}