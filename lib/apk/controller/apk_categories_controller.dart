import 'package:get/get.dart';
import 'package:dio/dio.dart' as diomultipart;
import 'package:laporan/models/apk_categories_model.dart';
import 'package:laporan/utils/loadings/snackbar.dart';

class ApkCategoriesController extends GetxController {
  RxBool isLoading = false.obs;
  RxList<ApkCategoriesModel> apkCategories = <ApkCategoriesModel>[].obs;

  RxString selectedApk = ''.obs;
  RxString selectedJenisApk = ''.obs;
  RxString selectedKendaraanId = ''.obs;

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
        idApk: '',
        title: '',
        subtitle: '',
      ),
    );

    selectedApk.value = kendaraan.title;
    selectedKendaraanId.value = kendaraan.idApk;
  }

  void setselectedJenisApk(String jenis) {
    selectedJenisApk.value = jenis;
    updateSelectedKendaraan(selectedApk.value); // Menjaga konsistensi
  }

  void resetSelectedKendaraan() {
    selectedApk.value = '';
    selectedApk.value = '';
  }
}
