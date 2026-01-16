class ApiConfig {
  // GANTI port 3001 sesuai dengan port user-services di docker-compose.yml kamu
  static const String baseUrl = "http://10.20.247.203:3001"; 
  
  static const String login = "$baseUrl/auth/login";
  static const String register = "$baseUrl/auth/register";
  static const String getAllUsers = "$baseUrl/users";
  static const String updateUser = "$baseUrl/users";
  static const String deleteUser = "$baseUrl/users";
  static const String catalogBaseUrl = "http://10.20.247.203:8001/api"; 
  static const String imageBaseUrl = "http://10.20.247.203:8001/storage/"; 

  static const String concerts = "$catalogBaseUrl/concerts";
}