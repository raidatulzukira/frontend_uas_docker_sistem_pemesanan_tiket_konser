class ApiConfig {
  // GANTI port 3001 sesuai dengan port user-services di docker-compose.yml kamu
  // 1. Tambahkan http:// dan PORT (contoh: 3001)
  static const String baseUrl = "http://172.27.112.1:3001"; 
  
  static const String login = "$baseUrl/auth/login";
  static const String register = "$baseUrl/auth/register";
  static const String getAllUsers = "$baseUrl/users";
  static const String updateUser = "$baseUrl/users";
  static const String deleteUser = "$baseUrl/users";

  // Catalog sudah benar pakai http dan port
  static const String catalogBaseUrl = "http://172.27.112.1:8001/api"; 
  static const String imageBaseUrl = "http://172.27.112.1:8001/storage/"; 
  
  static const String concerts = "$catalogBaseUrl/concerts";

   // --- TAMBAHKAN ORDER SERVICE (GO) ---
  static const String orderBaseUrl = "http://172.27.112.1:8080"; 
  static const String createOrder = "$orderBaseUrl/orders";
  // Fungsi untuk mendapatkan URL konfirmasi berdasarkan ID
  static String confirmOrder(int id) => "$orderBaseUrl/orders/$id/confirm";
  static String userOrders(String userId) => "$orderBaseUrl/orders/user/$userId";
}