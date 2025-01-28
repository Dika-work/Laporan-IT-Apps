import 'dart:io';
import 'package:dio/dio.dart' as diomultipart;
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';

import '../../utils/loadings/snackbar.dart';

class RegisterController extends GetxController {
  RxBool isLoading = false.obs;
  RxBool obscureText = true.obs;
  RxBool confirmObscureText = true.obs;
  final formKey = GlobalKey<FormState>();
  RxString selectedTypeUser = 'User'.obs;
  Rx<File?> selectedImage = Rx<File?>(null);
  final RegExp passwordRegex =
      RegExp(r'^(?=.*[A-Z])(?=.*\d)(?=.*[@$!%*?&])[A-Za-z\d@$!%*?&]{8,}$');

  TextEditingController usernameC = TextEditingController();
  TextEditingController divisiC = TextEditingController();
  TextEditingController passC = TextEditingController();
  TextEditingController confirmPassC = TextEditingController();

  final List<String> typeUserOptions = [
    'Admin',
    'User',
  ];

  final diomultipart.Dio _dio = diomultipart.Dio(
    diomultipart.BaseOptions(
      baseUrl: 'http://192.168.1.3:8080', // Ganti dengan URL backend Anda
      connectTimeout: const Duration(seconds: 10),
      receiveTimeout: const Duration(seconds: 10),
    ),
  );

  /// Mengambil gambar dari galeri atau kamera
  pickImage(ImageSource source) async {
    final ImagePicker picker = ImagePicker();
    final XFile? image = await picker.pickImage(source: source);

    if (image != null) {
      selectedImage.value = File(image.path);
    } else {
      Get.snackbar(
        'Error',
        'Tidak ada gambar yang dipilih.',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
    }
  }

  /// Fungsi untuk mendaftarkan user baru
  registerEmailandPassword() async {
    isLoading.value = true;

    // Validasi form
    if (!formKey.currentState!.validate()) {
      isLoading.value = false;
      return;
    }

    if (passC.text != confirmPassC.text) {
      isLoading.value = false;
      SnackbarLoader.errorSnackBar(
          title: 'Oops', message: 'Password dan Confirm Password tidak sama');
      return;
    }

    // Validasi jika gambar belum dipilih
    if (selectedImage.value == null) {
      isLoading.value = false;
      SnackbarLoader.errorSnackBar(
        title: 'Oops',
        message: 'Gambar pengguna harus diunggah.',
      );
      return;
    }

    try {
      // Membuat form-data
      diomultipart.FormData formData = diomultipart.FormData.fromMap({
        'username': usernameC.text.trim(),
        'divisi': divisiC.text.trim().toLowerCase(),
        'type_user': selectedTypeUser.value.toLowerCase(),
        'password': passC.text,
        'foto_user': await diomultipart.MultipartFile.fromFile(
          selectedImage.value!.path,
        ),
      });

      final response = await _dio.post('/register-user', data: formData);

      if (response.statusCode == 201) {
        Get.back();

        usernameC.clear();
        passC.clear();
        confirmPassC.clear();
        selectedImage.value = null;

        SnackbarLoader.successSnackBar(
          title: 'Success',
          message: response.data['message'] ?? 'User berhasil ditambahkan',
        );
      } else {
        SnackbarLoader.errorSnackBar(
            title: 'Oops👻',
            message: response.data['message'] ?? 'Gagal menambahkan pengguna');
      }
    } on diomultipart.DioException catch (e) {
      if (e.response?.statusCode == 429) {
        SnackbarLoader.warningSnackBar(
            title: 'Limit Exceeded',
            message: 'Terlalu banyak permintaan. Coba lagi nanti');
      } else {
        SnackbarLoader.warningSnackBar(
            title: 'Limit Exceeded',
            message: e.response?.data['message'] ?? 'Terjadi kesalahan');
      }
    } finally {
      isLoading.value = false;
    }
  }

  @override
  void onClose() {
    usernameC.dispose();
    passC.dispose();
    confirmPassC.dispose();
    super.onClose();
  }
}
