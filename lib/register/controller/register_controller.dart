import 'dart:io';
import 'package:dio/dio.dart' as diomultipart;
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';
import 'package:laporan/utils/routes/app_pages.dart';

import '../../utils/loadings/snackbar.dart';

class RegisterController extends GetxController {
  RxBool isLoading = false.obs;
  RxBool obscureText = true.obs;
  RxBool confirmObscureText = true.obs;
  final formKey = GlobalKey<FormState>();
  RxString selectedTypeUser = ''.obs;
  File? selectedImage;
  final RegExp passwordRegex =
      RegExp(r'^(?=.*[A-Z])(?=.*\d)(?=.*[@$!%*?&])[A-Za-z\d@$!%*?&]{8,}$');

  TextEditingController usernameC = TextEditingController();
  TextEditingController passC = TextEditingController();
  TextEditingController confirmPassC = TextEditingController();

  final List<String> typeUserOptions = [
    'Admin',
    'User',
  ];

  final diomultipart.Dio _dio = diomultipart.Dio(
    diomultipart.BaseOptions(
      baseUrl: 'http://10.3.80.4:8080', // Ganti dengan URL backend Anda
      connectTimeout: const Duration(seconds: 10),
      receiveTimeout: const Duration(seconds: 10),
    ),
  );

  /// Mengambil gambar dari galeri atau kamera
  pickImage(ImageSource source) async {
    final ImagePicker picker = ImagePicker();
    final XFile? image = await picker.pickImage(source: source);

    if (image != null) {
      selectedImage = File(image.path);
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

    // Validasi jika gambar belum dipilih
    if (selectedImage == null) {
      Get.snackbar(
        'Error',
        'Gambar pengguna harus diunggah.',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
      isLoading.value = false;
      return;
    }

    try {
      // Membuat form-data
      diomultipart.FormData formData = diomultipart.FormData.fromMap({
        'username': usernameC.text.trim(),
        'type_user': selectedTypeUser.value,
        'password': passC.text,
        'foto_user': await diomultipart.MultipartFile.fromFile(
          selectedImage!.path,
        ),
      });

      final response = await _dio.post('/register-user', data: formData);

      if (response.statusCode == 201) {
        SnackbarLoader.successSnackBar(
          title: 'Success',
          message: response.data['message'] ?? 'User berhasil ditambahkan',
        );

        usernameC.clear();
        passC.clear();
        confirmPassC.clear();
        selectedTypeUser.value = '';
        selectedImage = null;

        Get.offAllNamed(Routes.LOGIN);
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
