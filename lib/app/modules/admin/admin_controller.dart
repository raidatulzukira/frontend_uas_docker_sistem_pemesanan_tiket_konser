import 'package:get/get.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'manage_users_view.dart';
import 'manage_catalog_view.dart';
import '../auth/login_view.dart'; // Pastikan import ini sesuai lokasi LoginView kamu

class AdminController extends GetxController {
  
  // Fungsi Logout
  Future<void> logout() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.clear(); // Hapus token dan role
    
    // Kembali ke halaman login & hapus semua history page
    Get.offAll(() => const LoginView());
    
    Get.snackbar("Logout", "Berhasil keluar dari sistem admin");
  }

  // Fungsi navigasi ke menu lain (nanti kita isi)
  void toManageUsers() {
     Get.to(() => const ManageUsersView());
  }

  void toManageCatalog() {
    Get.to(() => const ManageCatalogView());
  }

  void toViewOrders() {
    Get.snackbar("Info", "Fitur View Orders akan segera hadir");
  }
}