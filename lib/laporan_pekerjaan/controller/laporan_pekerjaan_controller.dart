import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import 'package:dio/dio.dart' as diomultipart;
import 'package:laporan/models/apk_categories_model.dart';
import 'package:laporan/utils/loadings/snackbar.dart';

class LaporanPekerjaanController extends GetxController {
  RxBool isLoading = false.obs;
  final localStorage = GetStorage();
  final formKey = GlobalKey<FormState>();
  final Rxn<ApkCategoriesModel> selectedCategory = Rxn<ApkCategoriesModel>();
  final status = 'Status pekerjaan'.obs;
  final Map<String, int> listStatusPekerjaan = {
    'Status pekerjaan': 0,
    'Selesai': 1,
    'Belum selesai': 2,
  };
  int get getStatusPekerjaan => listStatusPekerjaan[status.value] ?? 0;

  RxString username = ''.obs;
  TextEditingController pekerjaanC = TextEditingController();
  TextEditingController problemC = TextEditingController();

  final diomultipart.Dio _dio = diomultipart.Dio(
    diomultipart.BaseOptions(
      baseUrl: 'http://10.3.80.4:8080', // Ganti dengan URL backend Anda
      connectTimeout: const Duration(seconds: 10),
      receiveTimeout: const Duration(seconds: 10),
    ),
  );

  postingLaporanPekerjaan({
    required String? apk,
    required String tgl,
  }) async {
    isLoading.value = true;
    username.value = localStorage.read('username') ?? '';

    if (!formKey.currentState!.validate()) {
      isLoading.value = false;
      return;
    }

    try {
      diomultipart.FormData formData = diomultipart.FormData.fromMap({
        'username': username.value,
        'apk': apk,
        'problem': problemC.text.trim(),
        'pekerjaan': pekerjaanC.text.trim(),
        'tgl': tgl,
        'status': getStatusPekerjaan,
      });

      final response = await _dio.post('/laporan-pekerjaan', data: formData);

      if (response.statusCode == 201) {
        Get.back(result: true);
        problemC.clear();
        pekerjaanC.clear();
        SnackbarLoader.successSnackBar(
            title: 'Berhasil', message: 'Pekerjaan hari ini sudah dilampirkan');
      }
    } catch (e) {
      SnackbarLoader.errorSnackBar(
        title: 'Error',
        message: 'Terjadi kesalahan: $e',
      );
      print('ERROR POSTING BUG : $e');
    } finally {
      isLoading.value = false;
    }
  }
}
