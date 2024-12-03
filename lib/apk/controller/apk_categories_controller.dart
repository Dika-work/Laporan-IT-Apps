import 'package:get/get.dart';
import 'package:dio/dio.dart' as diomultipart;
import 'package:laporan/models/apk_categories_model.dart';
import 'package:laporan/utils/loadings/snackbar.dart';

class ApkCategoriesController extends GetxController {
  RxBool isLoading = false.obs;
  RxList<ApkCategoriesModel> apkCategories = <ApkCategoriesModel>[].obs;

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
}
