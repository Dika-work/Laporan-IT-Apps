import 'dart:convert';
import 'dart:io';

import 'package:crypto/crypto.dart';
import 'package:flutter/material.dart';
import 'package:dio/dio.dart' as diomultipart;
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import 'package:image_picker/image_picker.dart';
import 'package:laporan/models/apk_categories_model.dart';
import 'package:laporan/models/problem_data.dart';
import 'package:laporan/utils/loadings/snackbar.dart';

class PostingBugController extends GetxController {
  RxBool isLoading = false.obs;
  RxBool textVisible = true.obs;
  final localStorage = GetStorage();
  final formKey = GlobalKey<FormState>();
  final Rxn<ApkCategoriesModel> selectedCategory = Rxn<ApkCategoriesModel>();
  RxList<ProblemData> problemList = <ProblemData>[].obs;

  var priorityLevel = 1.obs;

  RxString username = ''.obs;
  TextEditingController lampiranC = TextEditingController();

  RxList<String> oldImageUrls = <String>[].obs; // Gambar lama (URL dari server)
  RxList<File> newImages = <File>[].obs; // Gambar baru yang dipilih pengguna

  final diomultipart.Dio _dio = diomultipart.Dio(
    diomultipart.BaseOptions(
      baseUrl: 'http://10.3.80.6:8080', // Ganti dengan URL backend Anda
      connectTimeout: const Duration(seconds: 10),
      receiveTimeout: const Duration(seconds: 10),
    ),
  );

  Future<void> pickImages(ImageSource source) async {
    final ImagePicker picker = ImagePicker();

    if (source == ImageSource.camera) {
      // Ambil satu gambar dari kamera
      final XFile? image = await picker.pickImage(source: source);
      if (image != null) {
        newImages.add(File(image.path)); // Tambahkan ke newImages
      } else {
        Get.snackbar(
          'Error',
          'Tidak ada gambar yang diambil.',
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: Colors.red,
          colorText: Colors.white,
        );
      }
    } else {
      // Ambil banyak gambar dari galeri
      final List<XFile> images = await picker.pickMultiImage();
      if (images.isNotEmpty) {
        newImages.addAll(
            images.map((img) => File(img.path))); // Tambahkan ke newImages
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
  }

  // Fungsi untuk menghapus gambar lama atau baru
  void deleteImage(int index, {required bool isOldImage}) {
    if (isOldImage) {
      oldImageUrls.removeAt(index); // Hapus gambar lama dari URL
    } else {
      newImages.removeAt(index); // Hapus gambar baru dari File
    }
  }

  Future<void> postingLampiranBug({
    required String? apk,
    required String priority,
    required String tglDiproses,
  }) async {
    isLoading.value = true;
    username.value = localStorage.read('username') ?? '';

    try {
      // Membuat FormData
      diomultipart.FormData formData = diomultipart.FormData();

      // Tambahkan data teks
      formData.fields.addAll([
        MapEntry('username', username.value),
        MapEntry('lampiran', lampiranC.text),
        MapEntry('apk', apk ?? ''),
        MapEntry('priority', priority),
        MapEntry('tgl_diproses', tglDiproses),
        const MapEntry('status_kerja', '0'),
      ]);

      // Tambahkan data file
      for (var image in newImages) {
        formData.files.add(
          MapEntry(
            'foto_user[]',
            await diomultipart.MultipartFile.fromFile(
              image.path,
              filename: image.path.split('/').last,
            ),
          ),
        );
      }

      // Kirim request ke endpoint
      final response = await _dio.post('/createLaporan', data: formData);

      // Respons berhasil
      if (response.statusCode == 201) {
        Get.back(result: true);
        lampiranC.clear();
        resetEditState(); // Bersihkan semua state
        SnackbarLoader.successSnackBar(
          title: 'Success',
          message: response.data['message'] ?? 'Lampiran berhasil ditambahkan',
        );
      } else {
        SnackbarLoader.errorSnackBar(
          title: 'Oops👻',
          message: response.data['message'] ?? 'Lampiran gagal ditambahkan',
        );
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

  Future<bool> getDataBeforeEdit({
    required String hashId,
    required String usernameHash,
    required String lampiran,
    required List<String> imageUrls,
    required String apk,
    required int priority,
  }) async {
    try {
      resetEditState(); // Reset state sebelum memuat data baru
      isLoading.value = true; // Mulai indikator loading

      // Simpan URL gambar lama
      oldImageUrls.value = imageUrls;

      // Simpan data lainnya ke controller untuk digunakan di halaman Edit
      lampiranC.text = lampiran;
      selectedCategory.value = ApkCategoriesModel.fromString(apk);
      priorityLevel.value = priority;

      print('Gambar lama yang diambil dari server: ${oldImageUrls.length}');
      return true;
    } catch (e) {
      print('Error pada getDataBeforeEdit: $e');
      return false;
    } finally {
      isLoading.value = false; // Akhiri indikator loading
    }
  }

  Future<void> updateLaporan({
    required String hashId,
    required String lampiran,
    required ApkCategoriesModel apk,
    required int priority,
  }) async {
    isLoading.value = true;

    try {
      final formData = diomultipart.FormData();

      // Tambahkan data teks
      formData.fields.addAll([
        MapEntry('hash_id', hashId),
        MapEntry('lampiran', lampiran),
        MapEntry('apk', apk.title),
        MapEntry('priority', priority.toString()),
      ]);

      // Debug: Cetak formData untuk melihat apa yang akan dikirim
      print("FormData Fields: ${formData.fields}");

      // Kirim URL gambar lama
      for (var imageUrl in oldImageUrls) {
        formData.fields.add(MapEntry('existing_images[]', imageUrl));
      }

      // Debug: Cetak existing_images yang dikirimkan
      print("Existing Image URLs: $oldImageUrls");

      // Kirim file gambar baru
      for (var image in newImages) {
        formData.files.add(MapEntry(
          'new_images[]',
          await diomultipart.MultipartFile.fromFile(image.path),
        ));
      }

      // Debug: Cetak file baru yang akan dikirimkan
      print("New Image Files: ${newImages.map((image) => image.path)}");

      // Kirim request ke server
      final response = await _dio.put('/updateLaporan', data: formData);

      // Debug: Cetak status code dan response dari server
      print("Response Status: ${response.statusCode}");
      print("Response Data: ${response.data}");

      if (response.statusCode == 200) {
        Get.snackbar('Sukses', 'Laporan berhasil diperbarui');
        resetEditState(); // Reset state setelah update
        Get.back(result: true);
        Navigator.of(Get.overlayContext!).pop();
      } else {
        throw Exception(response.data['message'] ?? 'Gagal menyimpan laporan');
      }
    } catch (e) {
      Get.snackbar('Error', 'Terjadi kesalahan saat menyimpan: $e');
    } finally {
      isLoading.value = false;
    }
  }

  String generateHash(String id) {
    var bytes = utf8.encode(id);
    var digest = sha256.convert(bytes);
    return digest.toString();
  }

  void resetEditState() {
    lampiranC.clear();
    oldImageUrls.clear();
    newImages.clear();
    selectedCategory.value = null;
    priorityLevel.value = 1;
  }

  @override
  void onClose() {
    lampiranC.dispose();
    super.onClose();
  }
}
