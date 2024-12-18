import 'dart:convert';

import 'package:crypto/crypto.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import 'package:laporan/utils/loadings/snackbar.dart';
import 'package:laporan/models/problem_data.dart';
import 'package:dio/dio.dart' as diomultipart;
import 'package:laporan/utils/routes/app_pages.dart';

class HomeUserController extends GetxController {
  RxBool isLoading = false.obs;

  RxString username = ''.obs;
  RxString usernameHash = ''.obs;
  RxString typeUser = ''.obs;
  RxString fotoUser = ''.obs;
  RxString divisi = ''.obs;
  RxList<ProblemData> problemList = <ProblemData>[].obs;

  final localStorage = GetStorage();

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
    fetchUserData();
  }

  fetchUserData() {
    isLoading.value = true;
    try {
      username.value = localStorage.read('username') ?? '';
      usernameHash.value = localStorage.read('username_hash') ?? '';
      typeUser.value = localStorage.read('type_user') ?? '';
      fotoUser.value = localStorage.read('foto_user') ?? '';
      divisi.value = localStorage.read('divisi') ?? '';
    } catch (e) {
      SnackbarLoader.warningSnackBar(
          title: 'Oops',
          message: 'Gagal mengambil data pengguna: ${e.toString()}');
    } finally {
      isLoading.value = false;
    }
  }

  getAllLaporan(String usernameHash) async {
    isLoading.value = true;

    try {
      final response = await _dio.get(
        '/getAllLaporan',
        queryParameters: {'username_hash': usernameHash},
      );

      if (response.statusCode == 200) {
        List<dynamic> data = response.data;
        // Simpan data ke RxList<ProblemData>
        problemList.value = data.map((e) => ProblemData.fromJson(e)).toList();
        print('Problem List: ${problemList.length} items loaded');
      }
    } on diomultipart.DioException catch (e) {
      if (e.response?.statusCode == 429) {
        SnackbarLoader.warningSnackBar(
          title: 'Limit Exceeded',
          message: 'Terlalu banyak permintaan. Coba lagi nanti',
        );
      } else {
        print('Error fetching data: $e');
        // SnackbarLoader.warningSnackBar(
        //   title: 'Error',
        //   message: e.response?.data['message'] ?? 'Terjadi kesalahan',
        // );
      }
    } finally {
      isLoading.value = false;
    }
  }

  deleteLaporan(String id) async {
    isLoading.value = true;
    try {
      // Hash ID sebelum mengirim ke backend
      String hashId = generateHash(id);
      print('INI HASH ID PADA DELETE LAPORAN $hashId');

      // Kirim permintaan DELETE ke backend
      final response = await _dio.delete(
        '/deleteLaporan',
        data: {'hash_id': hashId}, // Kirim hash ID
      );

      if (response.statusCode == 200) {
        // Hapus item dari problemList berdasarkan ID asli
        problemList.removeWhere((element) => element.id.toString() == id);

        SnackbarLoader.successSnackBar(
          title: 'Berhasil',
          message: response.data['message'] ?? 'Laporan berhasil dihapus',
        );
      } else {
        SnackbarLoader.errorSnackBar(
          title: 'Gagal',
          message: response.data['message'] ?? 'Gagal menghapus laporan',
        );
      }
    } on diomultipart.DioException catch (e) {
      if (e.response?.statusCode == 404) {
        SnackbarLoader.warningSnackBar(
          title: 'Tidak Ditemukan',
          message: 'Laporan tidak ditemukan',
        );
      } else if (e.response?.statusCode == 500) {
        SnackbarLoader.errorSnackBar(
          title: 'Kesalahan Server',
          message: 'Terjadi kesalahan pada server. Silakan coba lagi.',
        );
      } else {
        SnackbarLoader.errorSnackBar(
          title: 'Kesalahan',
          message: e.response?.data['message'] ?? 'Terjadi kesalahan',
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

  String generateHash(String id) {
    var bytes = utf8.encode(id); // Konversi ID ke bytes
    var digest = sha256.convert(bytes); // Hash dengan SHA-256
    return digest.toString(); // Ubah ke string
  }

  logout() {
    localStorage.remove('username');
    localStorage.remove('username_hash');
    localStorage.remove('type_user');
    localStorage.remove('foto_user');
    localStorage.remove('divisi');
    localStorage.write('isLoggedIn', false);
    Get.offAllNamed(Routes.LOGIN);
  }
}
