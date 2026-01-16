import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:iconsax/iconsax.dart';
import '../../theme/app_colors.dart';
import 'auth_controller.dart';
import 'widgets/custom_textfield.dart';

class RegisterView extends StatelessWidget {
  const RegisterView({super.key});

  @override
  Widget build(BuildContext context) {
    // PERBAIKAN: Gunakan Get.put agar controller dibuat jika belum ada
    final controller = Get.put(AuthController()); 

    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios, color: AppColors.textPrimary),
          onPressed: () => Get.back(),
        ),
      ),
      backgroundColor: AppColors.background,
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                "Create Account",
                style: TextStyle(
                    fontSize: 32, fontWeight: FontWeight.bold, color: AppColors.textPrimary),
              ),
              const SizedBox(height: 8),
              const Text(
                "Gabung dan rasakan euforianya!",
                style: TextStyle(color: AppColors.textSecondary, fontSize: 16),
              ),
              
              const SizedBox(height: 30),

              // Username Field
              CustomTextField(
                label: "Username",
                icon: Iconsax.user,
                controller: controller.usernameController,
              ),

              const SizedBox(height: 20),

              CustomTextField(
                label: "Email Address",
                icon: Iconsax.sms,
                controller: controller.emailController,
              ),

              const SizedBox(height: 20),

              Obx(() => CustomTextField(
                label: "Password",
                icon: Iconsax.lock,
                controller: controller.passwordController,
                isPassword: true,
                isObscure: controller.isObscure.value,
                onEyeTap: controller.togglePasswordVisibility,
              )),

              const SizedBox(height: 40),

              SizedBox(
                width: double.infinity,
                height: 56,
                child: Obx(() => ElevatedButton(
                  onPressed: controller.isLoading.value ? null : () => controller.register(),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primary, // Warna Cream (Smog)
                    foregroundColor: AppColors.buttonText, // Teks tombol jadi gelap
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                  ),
                  child: controller.isLoading.value
                      ? const CircularProgressIndicator(color: AppColors.blueGreen)
                      : const Text("Sign Up",
                          style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold)),
                )),
              ),
            ],
          ),
        ),
      ),
    );
  }
}