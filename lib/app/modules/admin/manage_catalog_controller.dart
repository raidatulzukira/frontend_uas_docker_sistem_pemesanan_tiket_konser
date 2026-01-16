import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:dio/dio.dart' as dio;
import 'package:intl/intl.dart';
import 'package:image_picker/image_picker.dart';
import '../../data/services/api_config.dart';
import '../../theme/app_colors.dart';

class ManageCatalogController extends GetxController {
  final dio.Dio _dio = dio.Dio();
  final ImagePicker _picker = ImagePicker();
  
  var isLoading = true.obs;
  var concertList = <dynamic>[].obs;
  
  final nameC = TextEditingController();
  final locationC = TextEditingController();
  final dateC = TextEditingController();
  final priceC = TextEditingController();
  final stockC = TextEditingController();

  DateTime? selectedDate;
  
  // LOGIC GAMBAR
  XFile? pickedImage; 
  var pickedImagePath = "".obs; // Gambar BARU dari Galeri (Lokal)
  var currentImageUrl = "".obs; // Gambar LAMA dari Database (Network)

  @override
  void onInit() {
    super.onInit();
    fetchConcerts();
  }

  // --- 1. RESET FORM ---
  void clearForm() {
    nameC.clear();
    locationC.clear();
    dateC.clear();
    priceC.clear();
    stockC.clear();
    selectedDate = null;
    pickedImage = null;
    pickedImagePath.value = "";
    currentImageUrl.value = ""; // Reset gambar lama
  }

  // --- 2. ISI DATA SAAT KLIK KARTU (View/Edit) ---
  void initFormWithData(Map<String, dynamic> concert) {
    clearForm();
    nameC.text = concert['name'];
    locationC.text = concert['location'];
    priceC.text = concert['price'].toString();
    stockC.text = concert['stock'].toString();
    
    // --- LOGIKA GAMBAR ---
    if (concert['image'] != null && concert['image'].toString().isNotEmpty) {
      // Gabungkan URL
      currentImageUrl.value = "${ApiConfig.imageBaseUrl}${concert['image']}";
      
      // DEBUG: Cek URL di Terminal (PENTING)
      print("GAMBAR DITEMUKAN: ${currentImageUrl.value}"); 
    } else {
      currentImageUrl.value = "";
      print("TIDAK ADA GAMBAR UNTUK KONSER INI");
    }

    try {
      selectedDate = DateTime.parse(concert['date']);
      dateC.text = DateFormat('dd MMM yyyy').format(selectedDate!);
    } catch (e) {
      selectedDate = DateTime.now();
    }
  }

  Future<void> pickImage() async {
    try {
      final XFile? image = await _picker.pickImage(source: ImageSource.gallery);
      if (image != null) {
        pickedImage = image;
        pickedImagePath.value = image.path;
      }
    } catch (e) {
      Get.snackbar("Izin Ditolak", "Mohon izinkan akses galeri di pengaturan HP.");
    }
  }

  // ... (Fungsi pickDate, fetchConcerts tetap sama) ...
  Future<void> fetchConcerts() async {
    try {
      isLoading.value = true;
      final response = await _dio.get(ApiConfig.concerts); 
      if (response.statusCode == 200) {
        concertList.assignAll(response.data);
      }
    } catch (e) {
      // Silent
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> pickDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: selectedDate ?? DateTime.now(),
      firstDate: DateTime.now(),
      lastDate: DateTime(2030),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: const ColorScheme.dark(
              primary: AppColors.primary,
              onPrimary: Colors.black,
              surface: Color(0xFF253334),
              onSurface: Colors.white,
            ),
          ),
          child: child!,
        );
      },
    );
    if (picked != null) {
      selectedDate = picked;
      dateC.text = DateFormat('dd MMM yyyy').format(picked);
    }
  }

  // --- 3. ADD CONCERT ---
  Future<void> addConcert() async {
    if (nameC.text.isEmpty || selectedDate == null) {
      Get.snackbar("Error", "Nama dan Tanggal wajib diisi", backgroundColor: Colors.red, colorText: Colors.white);
      return;
    }

    try {
      isLoading.value = true;
      String formattedDate = DateFormat('yyyy-MM-dd').format(selectedDate!);

      var formData = dio.FormData.fromMap({
        "name": nameC.text,
        "location": locationC.text,
        "date": formattedDate,
        "price": int.tryParse(priceC.text) ?? 0,
        "stock": int.tryParse(stockC.text) ?? 0,
      });

      if (pickedImage != null) {
        formData.files.add(MapEntry(
          "image",
          await dio.MultipartFile.fromFile(pickedImage!.path, filename: pickedImage!.name),
        ));
      }

      await _dio.post(ApiConfig.concerts, data: formData);

      Get.back(); 
      Get.snackbar("Sukses", "Konser berhasil ditambahkan!", backgroundColor: AppColors.success, colorText: Colors.white);
      fetchConcerts();
    } on dio.DioException catch (e) {
      Get.snackbar("Gagal", e.response?.data['message'] ?? "Terjadi kesalahan");
    } finally {
      isLoading.value = false;
    }
  }

  // --- 4. UPDATE CONCERT (EDIT) ---
  Future<void> updateConcert(int id) async {
    try {
      isLoading.value = true;
      String formattedDate = DateFormat('yyyy-MM-dd').format(selectedDate!);

      var formData = dio.FormData.fromMap({
        "_method": "PUT", // Trik Laravel
        "name": nameC.text,
        "location": locationC.text,
        "date": formattedDate,
        "price": int.tryParse(priceC.text) ?? 0,
        "stock": int.tryParse(stockC.text) ?? 0,
      });

      // Hanya kirim gambar jika user memilih gambar baru
      if (pickedImage != null) {
        formData.files.add(MapEntry(
          "image",
          await dio.MultipartFile.fromFile(pickedImage!.path, filename: pickedImage!.name),
        ));
      }

      await _dio.post("${ApiConfig.concerts}/$id", data: formData);
      
      Get.back(); // Tutup halaman
      Get.snackbar("Sukses", "Data konser diperbarui!", backgroundColor: AppColors.success, colorText: Colors.white);
      fetchConcerts(); // Refresh list
    } on dio.DioException catch (e) {
      Get.snackbar("Gagal", "Gagal update: ${e.message}");
    } finally {
      isLoading.value = false;
    }
  }

  // --- 5. DELETE CONCERT ---
  Future<void> deleteConcert(int id) async {
    try {
      isLoading.value = true;
      await _dio.delete("${ApiConfig.concerts}/$id");
      Get.back(); 
      Get.snackbar("Dihapus", "Konser telah dihapus.", backgroundColor: Colors.orange, colorText: Colors.white);
      fetchConcerts(); 
    } catch (e) {
      Get.snackbar("Error", "Gagal menghapus");
    } finally {
      isLoading.value = false;
    }
  }
}