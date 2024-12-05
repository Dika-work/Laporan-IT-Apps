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
import 'package:laporan/utils/routes/app_pages.dart';
import 'package:path_provider/path_provider.dart';

class PostingBugController extends GetxController {
  RxBool isLoading = false.obs;
  RxBool textVisible = true.obs;
  final localStorage = GetStorage();
  final formKey = GlobalKey<FormState>();
  Rxn<File> selectedImage = Rxn<File>();
  final Rxn<ApkCategoriesModel> selectedCategory = Rxn<ApkCategoriesModel>();
  RxList<ProblemData> problemList = <ProblemData>[].obs;

  var priorityLevel = 1.obs;

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

  deleteImage() async {
    if (selectedImage.value != null) {
      await selectedImage.value!.delete();
      selectedImage.value = null;
    }
  }

  postingLampiranBug(
    String? apk,
    String priority,
    String tglDiproses,
  ) async {
    isLoading.value = true;
    username.value = localStorage.read('username');

    if (!formKey.currentState!.validate()) {
      isLoading.value = false;
      return;
    }

    try {
      diomultipart.FormData formData = diomultipart.FormData.fromMap({
        'username': username.value,
        'lampiran': lampiranC.text,
        'apk': apk,
        'priority': priority,
        'tgl_diproses': tglDiproses,
        'status_kerja': '0',
        'foto_user': selectedImage.value != null
            ? await diomultipart.MultipartFile.fromFile(
                selectedImage.value!.path,
                filename: selectedImage.value!.path.split('/').last,
              )
            : null,
      });

      print('Request Payload: ${formData.fields}');
      print('Request File: ${formData.files}');

      final response = await _dio.post('/createLaporan', data: formData);

      if (response.statusCode == 201) {
        print('Response success: 201 status code');
        Get.back(result: true);
        lampiranC.clear();
        selectedImage.value = null;
        print('DATANYA SUDAH BERHASIL MASUK POSTINGAN');
        SnackbarLoader.successSnackBar(
          title: 'Success',
          message: response.data['message'] ?? 'Lampiran berhasil ditambahkan',
        );
      } else {
        print('Unexpected response: ${response.statusCode}');
        SnackbarLoader.errorSnackBar(
            title: 'Oops👻',
            message: response.data['message'] ?? 'Lampiran gagal ditambahkan');
      }
    } on diomultipart.DioException catch (e) {
      print('DioException caught: $e');
      if (e.response != null) {
        print('Response data: ${e.response!.data}');
      }
      SnackbarLoader.errorSnackBar(
        title: 'Error',
        message: e.response?.data['message'] ?? 'Terjadi kesalahan',
      );
    } finally {
      isLoading.value = false;
    }
  }

  getDataBeforeEdit({
    required String hashId,
    required String usernameHash,
    required String lampiran,
    required String fotoUserPath,
    required String apk,
    required int priority,
  }) async {
    // Reset state sebelum memuat data baru
    resetEditState();

    String id = generateHash(hashId);

    // Siapkan arguments
    final arguments = {
      'hash_id': id,
      'usernameHash': usernameHash,
      'lampiran': lampiran,
      'fotoUserPath': fotoUserPath,
      'apk': apk,
      'priority': priority,
    };

    // Unduh gambar jika URL valid
    if (fotoUserPath.isNotEmpty && fotoUserPath.startsWith('http')) {
      isLoading.value = true; // Tampilkan indikator loading
      final downloadedImage = await downloadImage(fotoUserPath);
      if (downloadedImage != null) {
        selectedImage.value = downloadedImage;
      } else {
        print("Gagal mengunduh gambar: $fotoUserPath");
      }
      isLoading.value = false; // Sembunyikan indikator loading
    } else if (fotoUserPath.isNotEmpty) {
      // Jika file adalah lokal
      selectedImage.value = File(fotoUserPath);
    }

    // Inisialisasi data untuk pengeditan
    initializeEditData(arguments);

    // Navigasi ke halaman edit setelah semua proses selesai
    Get.toNamed(
      Routes.EDIT_POSTING,
      arguments: arguments,
    );
  }

  Future<File?> downloadImage(String url) async {
    try {
      // Unduh file menggunakan Dio
      final response = await _dio.get(
        url,
        options:
            diomultipart.Options(responseType: diomultipart.ResponseType.bytes),
      );

      // Simpan file di direktori sementara
      final tempDir = await getTemporaryDirectory();
      final file = File('${tempDir.path}/${url.split('/').last}');
      await file.writeAsBytes(response.data);

      return file; // Kembalikan file lokal
    } catch (e) {
      print('Error downloading image: $e');
      return null;
    }
  }

  updateLaporan({
    required String hashId,
    required String lampiran,
    required ApkCategoriesModel apk,
    required int priority,
  }) async {
    isLoading.value = true;

    try {
      // Siapkan payload untuk API
      final formData = diomultipart.FormData.fromMap({
        'hash_id': hashId,
        'lampiran': lampiran,
        'apk': apk.title,
        'priority': priority.toString(),
        'foto_user': selectedImage.value != null
            ? await diomultipart.MultipartFile.fromFile(
                selectedImage.value!.path,
                filename: selectedImage.value!.path.split('/').last,
              )
            : null,
      });

      // Kirim request ke API
      final response = await _dio.put('/updateLaporan', data: formData);

      if (response.statusCode == 200) {
        Get.back(result: true);
        SnackbarLoader.successSnackBar(
          title: 'Sukses',
          message: 'Laporan berhasil diperbarui.',
        );
      } else {
        SnackbarLoader.errorSnackBar(
          title: 'Gagal',
          message: response.data['message'] ?? 'Terjadi kesalahan',
        );
      }
    } on diomultipart.DioException catch (e) {
      SnackbarLoader.errorSnackBar(
        title: 'Error',
        message: e.response?.data['message'] ?? 'Terjadi kesalahan',
      );
    } finally {
      isLoading.value = false;
    }
  }

  String generateHash(String id) {
    var bytes = utf8.encode(id); // Konversi ID ke bytes
    var digest = sha256.convert(bytes); // Hash dengan SHA-256
    return digest.toString(); // Ubah ke string
  }

  void initializeEditData(Map<String, dynamic> arguments) {
    // Isi data berdasarkan arguments
    lampiranC.text = arguments['lampiran'] ?? '';
    priorityLevel.value = arguments['priority'] ?? 1;

    if (arguments['fotoUserPath'] != null && arguments['fotoUserPath'] != '') {
      final fotoUserPath = arguments['fotoUserPath'];
      if (fotoUserPath.startsWith('http')) {
        downloadImage(fotoUserPath).then((file) {
          if (file != null) selectedImage.value = file;
        });
      } else {
        selectedImage.value = File(fotoUserPath);
      }
    }

    selectedCategory.value = ApkCategoriesModel.fromString(
      arguments['apk'] ?? '',
    );
  }

  void resetEditState() {
    lampiranC.clear(); // Reset input lampiran
    selectedImage.value = null; // Reset gambar yang dipilih
    selectedCategory.value = null; // Reset kategori
    priorityLevel.value = 1; // Setel prioritas ke default
  }

  @override
  void onClose() {
    lampiranC.dispose();
    super.onClose();
  }
}
