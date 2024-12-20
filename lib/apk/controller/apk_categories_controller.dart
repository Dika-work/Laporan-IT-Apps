import 'dart:convert';

import 'package:crypto/crypto.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:dio/dio.dart' as diomultipart;
import 'package:laporan/models/apk_categories_model.dart';
import 'package:laporan/utils/loadings/snackbar.dart';

class ApkCategoriesController extends GetxController {
  RxBool isLoading = false.obs;
  RxList<ApkCategoriesModel> apkCategories = <ApkCategoriesModel>[].obs;

  RxString selectedApk = ''.obs; // Untuk menyimpan title yang dipilih
  RxString selectedJenisApk = ''.obs; // Untuk menyaring berdasarkan jenis APK
  RxString selectedKendaraanId = ''.obs; // Menyimpan title sebagai ID

  final formKey = GlobalKey<FormState>();

  TextEditingController apkC = TextEditingController();
  TextEditingController subtitleApkC = TextEditingController();

  final diomultipart.Dio _dio = diomultipart.Dio(
    diomultipart.BaseOptions(
      baseUrl: 'http://10.3.80.4:8080', // Ganti dengan URL backend Anda
      connectTimeout: const Duration(seconds: 10),
      receiveTimeout: const Duration(seconds: 10),
    ),
  );

  @override
  void onInit() {
    super.onInit();
    getApkCategories();
  }

  getApkCategories() async {
    isLoading.value = true;

    try {
      final response = await _dio.get('/getCategoryApk');

      if (response.statusCode == 200) {
        final Map<String, dynamic> jsonResponse = response.data;
        final List<dynamic> data = jsonResponse['data'];
        apkCategories.value =
            data.map((e) => ApkCategoriesModel.fromJson(e)).toList();
      }
    } on diomultipart.DioException catch (e) {
      if (e.response?.statusCode == 429) {
        SnackbarLoader.warningSnackBar(
            title: 'Limit Exceeded',
            message: 'Terlalu banyak permintaan. Coba lagi nanti');
      } else {
        SnackbarLoader.warningSnackBar(
            title: 'Error',
            message: e.response?.data['message'] ?? 'Terjadi kesalahan');
      }
    } finally {
      isLoading.value = false;
    }
  }

  // create apk category
  createApkCategory() async {
    isLoading.value = true;

    if (!formKey.currentState!.validate()) {
      isLoading.value = false;
      return;
    }

    try {
      diomultipart.FormData formData = diomultipart.FormData.fromMap(
          {'title': apkC.text.trim(), 'subtitle': subtitleApkC.text.trim()});

      final response = await _dio.post('/createApkCategory', data: formData);

      if (response.statusCode == 201) {
        await getApkCategories();
        SnackbarLoader.successSnackBar(
          title: 'Success',
          message: response.data['message'] ?? 'Apk berhasil ditambahkan',
        );

        apkC.clear();
        subtitleApkC.clear();

        Navigator.of(Get.overlayContext!).pop();
      } else {
        SnackbarLoader.errorSnackBar(
            title: 'Oops👻',
            message:
                response.data['message'] ?? 'Gagal menambahkan apk category');
      }
    } catch (e) {
      SnackbarLoader.warningSnackBar(
          title: 'Something went wrong', message: 'Terdapat kesalahan $e');
      print('error : $e');
    } finally {
      isLoading.value = false;
    }
  }

  deleteApkCategory(String title) async {
    isLoading.value = true;
    try {
      String hashTitle = generateHash(title);

      final response = await _dio.delete(
        '/deleteApkCategory',
        data: {'hash_title': hashTitle},
      );

      if (response.statusCode == 200) {
        print('ini id yg di pilih $title');
        await getApkCategories();
        SnackbarLoader.successSnackBar(
          title: 'Berhasil',
          message: response.data['message'] ?? 'Laporan berhasil dihapus',
        );
        Navigator.of(Get.overlayContext!).pop();
      } else {
        SnackbarLoader.errorSnackBar(
          title: 'Gagal',
          message: response.data['message'] ?? 'Gagal menghapus laporan',
        );
      }
    } catch (e) {
      SnackbarLoader.errorSnackBar(
        title: 'Kesalahan',
        message: 'Terjadi kesalahan: ${e.toString()}',
      );
    } finally {
      isLoading.value = false;
    }
  }

  List<ApkCategoriesModel> get filteredKendaraanModel {
    if (selectedJenisApk.value.isEmpty) {
      return apkCategories;
    }

    final filtered = apkCategories
        .where(
          (kendaraan) => kendaraan.title
              .toLowerCase()
              .contains(selectedJenisApk.value.toLowerCase()),
        )
        .toList();

    return filtered;
  }

  void updateSelectedKendaraan(String value) {
    final kendaraan = filteredKendaraanModel.firstWhere(
      (kendaraan) => kendaraan.title == value,
      orElse: () => ApkCategoriesModel(
        title: '',
        subtitle: '',
      ),
    );

    selectedApk.value = kendaraan.title;
    selectedKendaraanId.value = kendaraan.title; // Menyimpan title sebagai ID
  }

  void setselectedJenisApk(String jenis) {
    selectedJenisApk.value = jenis;
    updateSelectedKendaraan(selectedApk.value); // Menjaga konsistensi
  }

  void resetSelectedKendaraan() {
    selectedApk.value = '';
    selectedApk.value = '';
  }

  String generateHash(String id) {
    var bytes = utf8.encode(id); // Konversi ID ke bytes
    var digest = sha256.convert(bytes); // Hash dengan SHA-256
    return digest.toString(); // Ubah ke string
  }
}
