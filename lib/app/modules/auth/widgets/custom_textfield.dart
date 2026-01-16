import 'package:flutter/material.dart';
// PERBAIKAN DI SINI: Tambah satu "../" lagi agar sampai ke folder theme
import '../../../theme/app_colors.dart'; 

class CustomTextField extends StatelessWidget {
  final String label;
  final IconData icon;
  final TextEditingController controller;
  final bool isPassword;
  final bool isObscure;
  final VoidCallback? onEyeTap;
  final bool isNumber; // Parameter baru untuk keyboard angka

  const CustomTextField({
    super.key,
    required this.label,
    required this.icon,
    required this.controller,
    this.isPassword = false,
    this.isObscure = false,
    this.onEyeTap,
    this.isNumber = false, // Default false
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(
            color: AppColors.textSecondary,
            fontSize: 14,
          ),
        ),
        const SizedBox(height: 8),
        TextField(
          controller: controller,
          obscureText: isObscure,
          // Logika Keyboard: Angka atau Email
          keyboardType: isNumber ? TextInputType.number : TextInputType.emailAddress,
          style: const TextStyle(color: Colors.white),
          decoration: InputDecoration(
            prefixIcon: Icon(icon, color: AppColors.textSecondary),
            suffixIcon: isPassword
                ? IconButton(
                    icon: Icon(
                      isObscure ? Icons.visibility_off : Icons.visibility,
                      color: AppColors.textSecondary,
                    ),
                    onPressed: onEyeTap,
                  )
                : null,
            filled: true,
            fillColor: AppColors.cardSurface, // Pastikan warna ini ada di app_colors.dart, atau ganti Colors.white10
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide.none,
            ),
            contentPadding: const EdgeInsets.symmetric(vertical: 16),
          ),
        ),
      ],
    );
  }
}