  // lib/app/modules/home/booking_controller.dart

  import 'dart:async';
  import 'package:dio/dio.dart' as dio_client;
  import 'package:flutter/material.dart'; // Tambahkan import material untuk Dialog
  import 'package:frontend_uas_docker_sistem_pemesanan_tiket_konser/app/modules/home/payment_view.dart';
  import 'package:get/get.dart';
  import '../../data/services/api_config.dart';
  import '../home/home_view.dart';

  class BookingController extends GetxController {
    final dio_client.Dio _dio = dio_client.Dio();
    var isLoading = false.obs;
    var quantity = 1.obs;

    // --- VARIABEL TAMBAHAN UNTUK SIMULASI ---
    var simulationStatus = "".obs;

    Timer? _timer;
    var timeLeft = 300.obs;

    String get formattedTime {
      int minutes = timeLeft.value ~/ 60;
      int seconds = timeLeft.value % 60;
      return "${minutes.toString().padLeft(2, '0')}:${seconds.toString().padLeft(2, '0')}";
    }

    void startTimer() {
      timeLeft.value = 300;
      _timer?.cancel();
      _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
        if (timeLeft.value > 0) {
          timeLeft.value--;
        } else {
          _timer?.cancel();
          handleTimeout();
        }
      });
    }

    void handleTimeout() {
      Get.offAll(() => const HomeView());
      Get.defaultDialog(
        title: "Waktu Habis",
        middleText:
            "Sesi pembayaran berakhir. Stok tiket telah dilepaskan kembali.",
        textConfirm: "OK",
        onConfirm: () => Get.back(),
      );
    }

    void increment() => {if (quantity.value < 10) quantity.value++};
    void decrement() => {if (quantity.value > 1) quantity.value--};

    // Cari fungsi createOrder di BookingController

    Future<void> createOrder(int eventId, String userId) async {
      // Parameter userId jadi String
      try {
        isLoading.value = true;
        final response = await _dio.post(
          ApiConfig.createOrder,
          data: {
            "user_id": userId, // Mengirim String ID asli
            "event_id": eventId,
            "quantity": quantity.value,
          },
        );

        if (response.statusCode == 201) {
          startTimer();
          Get.to(() => PaymentView(orderData: response.data['data']));
        }
      } catch (e) {
        Get.snackbar("Gagal", "Stok habis atau sistem sibuk");
      } finally {
        isLoading.value = false;
      }
    }

    // --- STEP 2: CONFIRM PAYMENT (LOGIC ASLI ANDA + SIMULASI) ---
    Future<void> confirmPayment(int orderId) async {
      try {
        isLoading.value = true;

        // 1. Tampilkan Dialog Simulasi
        _showSimulationDialog();

        // 2. Tahap Simulasi 1: Koneksi Bank
        simulationStatus.value = "Menghubungkan ke Gateway Pembayaran...";
        await Future.delayed(const Duration(seconds: 2));

        // 3. Tahap Simulasi 2: Verifikasi Saldo
        simulationStatus.value = "Memverifikasi Saldo & PIN...";
        await Future.delayed(const Duration(seconds: 2));

        // 4. Tahap Simulasi 3: Memanggil API Go (Logic Asli Anda)
        simulationStatus.value = "Sinkronisasi ke Go Service & Database...";
        final response = await _dio.post(ApiConfig.confirmOrder(orderId));

        if (response.statusCode == 200) {
          _timer?.cancel();

          // Tutup dialog simulasi sebelum pindah halaman
          if (Get.isDialogOpen!) Get.back();

          Get.offAll(() => const HomeView());
          Get.defaultDialog(
            title: "Pembayaran Berhasil",
            middleText: "Tiket Anda telah dikonfirmasi. Selamat menonton!",
            textConfirm: "Selesai",
            onConfirm: () => Get.back(),
          );
        }
      } catch (e) {
        if (Get.isDialogOpen!) Get.back();
        Get.snackbar("Error", "Gagal konfirmasi pembayaran");
      } finally {
        isLoading.value = false;
      }
    }

    // Fungsi Helper untuk memunculkan Dialog Simulasi
    void _showSimulationDialog() {
      Get.dialog(
        barrierDismissible: false,
        Dialog(
          backgroundColor: const Color(0xFF1E1E1E),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
          child: Padding(
            padding: const EdgeInsets.all(30),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const CircularProgressIndicator(color: Colors.orange),
                const SizedBox(height: 25),
                Obx(
                  () => Text(
                    simulationStatus.value,
                    textAlign: TextAlign.center,
                    style: const TextStyle(color: Colors.white, fontSize: 16),
                  ),
                ),
              ],
            ),
          ),
        ),
      );
    }

    @override
    void onClose() {
      _timer?.cancel();
      super.onClose();
    }
  }
