import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import 'package:laporan/models/all_problem_admin.dart';
import 'package:laporan/utils/loadings/snackbar.dart';
import 'package:dio/dio.dart' as diomultipart;
import 'package:laporan/utils/routes/app_pages.dart';

class HomeAdminController extends GetxController {
  RxBool isLoading = false.obs;

  RxString username = ''.obs;
  RxString usernameHash = ''.obs;
  RxString typeUser = ''.obs;
  RxString fotoUser = ''.obs;
  RxString divisi = ''.obs;
  RxList<ProblemDataForAdmin> problemList = <ProblemDataForAdmin>[].obs;

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
    getLaporanAdmin();
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

  getLaporanAdmin() async {
    isLoading.value = true;

    try {
      final response = await _dio.get('/get-laporan-admin');
      print('Response Data: ${response.data}');

      if (response.statusCode == 200) {
        List<dynamic> data = response.data;
        print('..INI RESPONSE DARI GET ALL PROBLEM.. ${data.toList()}');

        // Simpan data ke RxList<ProblemDataForAdmin>
        problemList.value =
            data.map((e) => ProblemDataForAdmin.fromJson(e)).toList();
        print('Problem List: ${problemList.length} items loaded');
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

  logout() {
    localStorage.remove('username');
    localStorage.remove('username_hash');
    localStorage.remove('type_user');
    localStorage.remove('foto_user');
    localStorage.remove('divisi');
    Get.offAllNamed(Routes.LOGIN);
  }
}
