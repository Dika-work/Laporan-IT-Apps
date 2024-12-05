import 'dart:io';

import 'package:flutter/material.dart';
import 'package:dio/dio.dart' as diomultipart;
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import 'package:image_picker/image_picker.dart';
import 'package:laporan/home_user/controller/home_user_controller.dart';
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
  RxString fotoProfile = ''.obs;
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
    fotoProfile.value = localStorage.read('foto_user');

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
    required String usernameHash,
    required String lampiran,
    required String fotoUserPath,
    required String apk,
    required int priority,
  }) {
    lampiranC.text = lampiran;

    // Konversi apk ke model
    selectedCategory.value = ApkCategoriesModel.fromString(apk);

    // Atur prioritas
    priorityLevel.value = priority;

    // Konversi fotoUserPath menjadi File
    if (fotoUserPath.isNotEmpty) {
      final filePath = fotoUserPath; // URL lengkap
      selectedImage.value = File(filePath); // Gunakan File untuk local handling
    } else {
      selectedImage.value = null;
    }

    Get.toNamed(
      Routes.EDIT_POSTING,
      arguments: {
        'usernameHash': usernameHash,
        'lampiran': lampiran,
        'fotoUserPath': fotoUserPath,
        'apk': apk,
        'priority': priority,
      },
    );
  }

  Future<File?> downloadImage(String url) async {
    try {
      // Gunakan Dio untuk mengunduh file
      final response = await _dio.get(
        url,
        options:
            diomultipart.Options(responseType: diomultipart.ResponseType.bytes),
      );

      // Simpan file di direktori sementara
      final tempDir = await getTemporaryDirectory();
      final file = File('${tempDir.path}/${url.split('/').last}');
      await file.writeAsBytes(response.data);

      return file;
    } catch (e) {
      print('Error downloading image: $e');
      return null;
    }
  }

  updateLaporan({
    required String usernameHash,
    required String lampiran,
    required ApkCategoriesModel apk,
    required int priority,
  }) async {
    isLoading.value = true;

    try {
      // Siapkan payload
      final formData = diomultipart.FormData.fromMap({
        'lampiran': lampiran,
        'apk': apk.title, // Gunakan field yang sesuai dari model
        'priority': priority.toString(),
        'foto_user': selectedImage.value != null
            ? await diomultipart.MultipartFile.fromFile(
                selectedImage.value!.path,
                filename: selectedImage.value!.path.split('/').last,
              )
            : null,
      });

      final response = await _dio.put(
        '/updateLaporan/$usernameHash',
        data: formData,
      );

      if (response.statusCode == 200) {
        Get.back(result: true); // Kembali ke halaman sebelumnya
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

  // getAllLaporan(String usernameHash) async {
  //   isLoading.value = true;

  //   try {
  //     final response = await _dio.get(
  //       '/getAllLaporan',
  //       queryParameters: {'username_hash': usernameHash},
  //     );
  //     print('Response Data: ${response.data}');

  //     if (response.statusCode == 200) {
  //       List<dynamic> data = response.data;
  //       print('Response data dari API: ${response.data}');
  //       // Simpan data ke RxList<ProblemData>
  //       problemList.value = data.map((e) => ProblemData.fromJson(e)).toList();
  //       print('Problem List: ${problemList.length} items loaded');
  //     }
  //   } on diomultipart.DioException catch (e) {
  //     if (e.response?.statusCode == 429) {
  //       SnackbarLoader.warningSnackBar(
  //           title: 'Limit Exceeded',
  //           message: 'Terlalu banyak permintaan. Coba lagi nanti');
  //     } else {
  //       print('ini error ketika get postingan by username hash : $e');
  //       SnackbarLoader.warningSnackBar(
  //           title: 'Error',
  //           message: e.response?.data['message'] ?? 'Terjadi kesalahan');
  //     }
  //   } finally {
  //     isLoading.value = false;
  //   }
  // }

  @override
  void onClose() {
    lampiranC.dispose();
    super.onClose();
  }
}
