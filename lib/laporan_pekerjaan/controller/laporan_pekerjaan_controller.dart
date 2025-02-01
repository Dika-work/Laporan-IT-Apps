import 'dart:convert';

import 'package:crypto/crypto.dart';
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

  // ini model untuk bagian edit
  RxList<ApkCategoriesModel> apkModel = <ApkCategoriesModel>[].obs;
  RxString selectedApk = ''.obs;
  RxString selectedJenisKendaraan = ''.obs;
  RxString selectedApkId = ''.obs;
// akhir untuk bagian edit

  RxString status = 'Status pekerjaan'.obs;
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
      baseUrl: 'http://192.168.1.8:8080', // Ganti dengan URL backend Anda
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

  updatePekerjaan({
    required String hashId,
    required String apk,
    required String problem,
    required String pekerjaan,
    required String tgl,
    required String status,
  }) async {
    isLoading.value = true;

    try {
      final data = {
        'hash_id': hashId,
        'apk': apk,
        'problem': problem,
        'pekerjaan': pekerjaan,
        'tgl': tgl,
        'status': status,
      };

      // Debugging data yang dikirim
      print('Data yang dikirim: $data');

      final response = await _dio.put(
        '/update-pekerjaan',
        data: data, // Kirim data sebagai JSON
      );

      // Debugging response server
      print('Response Status: ${response.statusCode}');
      print('Response Data: ${response.data}');

      if (response.statusCode == 200) {
        Get.back(result: true);
        SnackbarLoader.successSnackBar(
          title: 'Sukses',
          message: 'Laporan berhasil diperbarui.',
        );
      } else {
        SnackbarLoader.errorSnackBar(
          title: 'Gagal',
          message: response.data['message'] ?? 'Terjadi kesalahan.',
        );
      }
    } catch (e) {
      SnackbarLoader.errorSnackBar(
        title: 'Error',
        message: 'Terjadi kesalahan: $e',
      );
      print('INI ERROR SAAT EDIT LAPORAN: $e');
    } finally {
      isLoading.value = false;
    }
  }

  String generateHash(String id) {
    var bytes = utf8.encode(id); // Konversi ID ke bytes
    var digest = sha256.convert(bytes); // Hash dengan SHA-256
    return digest.toString(); // Ubah ke string
  }
}
