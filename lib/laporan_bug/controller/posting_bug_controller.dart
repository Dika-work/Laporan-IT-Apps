import 'dart:io';

import 'package:flutter/material.dart';
import 'package:dio/dio.dart' as diomultipart;
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import 'package:image_picker/image_picker.dart';
import 'package:laporan/utils/loadings/snackbar.dart';

class PostingBugController extends GetxController {
  RxBool isLoading = false.obs;
  RxBool textVisible = true.obs;
  final localStorage = GetStorage();
  final formKey = GlobalKey<FormState>();
  File? selectedImage;
  RxString username = ''.obs;
  TextEditingController lampiranC = TextEditingController();

  final diomultipart.Dio _dio = diomultipart.Dio(
    diomultipart.BaseOptions(
      baseUrl: 'http://10.3.80.4:8080', // Ganti dengan URL backend Anda
      connectTimeout: const Duration(seconds: 10),
      receiveTimeout: const Duration(seconds: 10),
    ),
  );

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

  postingLampiranBug() async {
    isLoading.value = true;
    username.value = localStorage.read('username') ?? '';

    if (!formKey.currentState!.validate()) {
      isLoading.value = false;
      return;
    }

    try {
      diomultipart.FormData formData = diomultipart.FormData.fromMap({
        'username': username.value,
        'lampiran': lampiranC.text,
        'foto_user': await diomultipart.MultipartFile.fromFile(
          selectedImage!.path,
        ),
      });

      final response = await _dio.post('/createLaporan', data: formData);

      if (response.statusCode == 201) {
        SnackbarLoader.successSnackBar(
          title: 'Success',
          message: response.data['message'] ?? 'Lampiran berhasil ditambahkan',
        );

        lampiranC.clear();
        selectedImage = null;

        Get.back();
      } else {
        SnackbarLoader.errorSnackBar(
            title: 'Oops👻',
            message: response.data['message'] ?? 'Lampiran gagal ditambahkan');
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
    lampiranC.dispose();
    super.onClose();
  }
}
