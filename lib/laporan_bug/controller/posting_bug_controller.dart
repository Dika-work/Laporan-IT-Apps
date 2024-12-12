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
import 'package:path_provider/path_provider.dart';

class PostingBugController extends GetxController {
  RxBool isLoading = false.obs;
  RxBool textVisible = true.obs;
  final localStorage = GetStorage();
  final formKey = GlobalKey<FormState>();
  RxList<File> selectedImages = <File>[].obs;
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

  pickImages(ImageSource source) async {
    final ImagePicker picker = ImagePicker();

    // Jika source adalah ImageSource.camera, pilih satu gambar, bukan multiple image
    if (source == ImageSource.camera) {
      final XFile? image = await picker.pickImage(source: source);
      if (image != null) {
        selectedImages.add(File(image.path));
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
      // Jika sumber adalah galeri (multi-image picker)
      final List<XFile> images = await picker.pickMultiImage();
      if (images.isNotEmpty) {
        selectedImages.value = images.map((image) => File(image.path)).toList();
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

  deleteImage(int index) {
    selectedImages.removeAt(index);
  }

  postingLampiranBug({
    required String? apk,
    required String priority,
    required String tglDiproses,
  }) async {
    isLoading.value = true;
    username.value = localStorage.read('username') ?? '';

    // if (!formKey.currentState!.validate()) {
    //   isLoading.value = false;
    //   return;
    // }

    try {
      // Log jumlah file yang akan di-upload
      print('Jumlah file yang diupload: ${selectedImages.length}');
      for (var image in selectedImages) {
        print('File Path: ${image.path}');
      }

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
      for (var image in selectedImages) {
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
        selectedImages.clear();
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

  getDataBeforeEdit({
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

      // Unduh semua gambar jika URL valid
      for (var url in imageUrls) {
        if (url.isNotEmpty && url.startsWith('http')) {
          final downloadedImage = await downloadImage(url);
          if (downloadedImage != null &&
              !selectedImages
                  .any((image) => image.path == downloadedImage.path)) {
            selectedImages.add(downloadedImage); // Tambahkan hanya jika unik
          }
        }
      }

      // Simpan data ke controller untuk digunakan di halaman Edit
      lampiranC.text = lampiran;
      selectedCategory.value = ApkCategoriesModel.fromString(apk);
      priorityLevel.value = priority;

      print('Jumlah gambar yang diunduh: ${selectedImages.length}');
      for (var image in selectedImages) {
        print('Gambar path: ${image.path}');
      }
      return true;
    } catch (e) {
      print('Error pada getDataBeforeEdit: $e');
      return false;
    } finally {
      isLoading.value = false; // Akhiri indikator loading
    }
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
    required List<File> selectedImages, // Daftar gambar yang dipilih
  }) async {
    isLoading.value = true;

    try {
      // Mengencode gambar menjadi base64 jika ada gambar yang dipilih
      String? encodedImage;
      if (selectedImages.isNotEmpty) {
        final imageBytes = await selectedImages[0].readAsBytes();
        encodedImage = base64Encode(imageBytes);
      }

      // Menyiapkan data JSON
      final data = {
        'hash_id': hashId,
        'lampiran': lampiran,
        'apk': apk.title,
        'priority': priority,
        'foto_user': encodedImage, // Mengirimkan gambar sebagai base64 string
      };

      print('Data yang akan dikirim:');
      print(data);

      // Mengirimkan data ke backend menggunakan Dio
      final response = await _dio.put(
        '/updateLaporan',
        data: data, // Mengirimkan data dalam format JSON
      );

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
        print('Gagal update laporan: ${response.data['message']}');
      }
    } catch (e) {
      SnackbarLoader.errorSnackBar(
        title: 'Error',
        message: 'Terjadi kesalahan: $e',
      );
      print('Error pada update laporan: $e');
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
    lampiranC.text = arguments['lampiran'] ?? '';
    priorityLevel.value = arguments['priority'] ?? 1;

    // Tambahkan semua gambar ke daftar
    if (arguments['imageUrls'] != null && arguments['imageUrls'] is List) {
      for (var url in arguments['imageUrls']) {
        downloadImage(url).then((file) {
          if (file != null) selectedImages.add(file);
        });
      }
    }

    selectedCategory.value = ApkCategoriesModel.fromString(
      arguments['apk'] ?? '',
    );
  }

  void resetEditState() {
    lampiranC.clear(); // Reset input lampiran
    selectedImages.clear(); // Reset daftar gambar
    selectedCategory.value = null; // Reset kategori
    priorityLevel.value = 1; // Setel prioritas ke default
  }

  @override
  void onClose() {
    lampiranC.dispose();
    super.onClose();
  }
}
