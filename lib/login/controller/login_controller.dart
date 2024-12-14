import 'package:dio/dio.dart';
import 'package:flutter/widgets.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';

import '../../utils/loadings/snackbar.dart';
import '../../utils/routes/app_pages.dart';

class LoginController extends GetxController {
  RxBool isLoading = false.obs;
  RxBool obscureText = true.obs;
  final rememberMe = false.obs;
  final formKey = GlobalKey<FormState>();
  final localStorage = GetStorage();

  TextEditingController usernameC = TextEditingController();
  TextEditingController passC = TextEditingController();

  final Dio _dio = Dio(
    BaseOptions(
      baseUrl: 'http://10.3.80.6:8080', // Ganti dengan URL backend Anda
      connectTimeout: const Duration(seconds: 10),
      receiveTimeout: const Duration(seconds: 10),
    ),
  );

  @override
  void onInit() {
    usernameC.text = localStorage.read('REMEMBER_ME_EMAIL') ?? '';
    passC.text = localStorage.read('REMEMBER_ME_PASSWORD') ?? '';
    super.onInit();
  }

  loginEmailandPassword() async {
    isLoading.value = true;
    if (!formKey.currentState!.validate()) {
      isLoading.value = false;
      return;
    }

    if (rememberMe.value) {
      // Simpan username dan password jika opsi "Ingat Saya" aktif
      localStorage.write('REMEMBER_ME_EMAIL', usernameC.text.trim());
      localStorage.write('REMEMBER_ME_PASSWORD', passC.text.trim());
    }

    try {
      final response = await _dio.post(
        '/login',
        data: {
          'username': usernameC.text,
          'password': passC.text,
        },
      );

      if (response.statusCode == 200) {
        final data = response.data['data'];

        final fotoUserUrl = '${_dio.options.baseUrl}/${data['foto_user']}';

        localStorage.write('username_hash', data['username_hash']);
        localStorage.write('type_user', data['type_user']);
        localStorage.write('foto_user', fotoUserUrl);

        await localStorage.write('isLoggedIn', true);
        await fetchUsername();

        SnackbarLoader.successSnackBar(
            title: 'Success',
            message: response.data['message'] ?? 'Login berhasil');

        // Navigasi berdasarkan type_user
        if (data['type_user'] == 'admin') {
          Get.offAllNamed(Routes.HOME_ADMIN);
        } else if (data['type_user'] == 'user') {
          Get.offAllNamed(Routes.HOME_USER);
        } else {
          SnackbarLoader.errorSnackBar(
              title: 'Oops',
              message: response.data['message'] ?? 'Tipe pengguna tidak valid');
        }
      } else {
        print('Terjadi kesalahan saat ingin login ${response.data['message']}');
        SnackbarLoader.errorSnackBar(
            title: 'Oops👻',
            message: response.data['message'] ?? 'Terjadi kesalahan');
      }
    } on DioException catch (e) {
      if (e.response?.statusCode == 429) {
        SnackbarLoader.warningSnackBar(
            title: 'Limit Exceeded',
            message: 'Terlalu banyak permintaan. Coba lagi nanti');
      } else {
        SnackbarLoader.warningSnackBar(
            title: 'Limit Exceeded',
            message: e.response?.data['message'] ?? 'Terjadi kesalahan');
      }
    } finally {
      isLoading.value = false;
    }
  }

  // get username by hashed
  Future<void> fetchUsername() async {
    isLoading.value = true;

    try {
      // Ambil username_hash dari localStorage
      final usernameHash = localStorage.read('username_hash');

      if (usernameHash == null) {
        SnackbarLoader.errorSnackBar(
          title: 'Error',
          message: 'username_hash tidak ditemukan',
        );
        return;
      }

      final response = await _dio.get(
        '/getDeHashUsername',
        queryParameters: {'username_hash': usernameHash},
      );

      if (response.statusCode == 200) {
        final data = response.data['data'];

        localStorage.write('username', data['username']);
        localStorage.write('divisi', data['divisi']);
        print('Username berhasil diambil: ${data['username']}');
        print('Divisi berhasil diambil: ${data['divisi']}');
      } else {
        SnackbarLoader.errorSnackBar(
          title: 'Oops',
          message: response.data['message'] ?? 'Gagal mengambil username',
        );
      }
    } catch (e) {
      SnackbarLoader.errorSnackBar(
        title: 'Oops',
        message: 'Terjadi kesalahan saat mengambil username',
      );
      print(e);
    } finally {
      isLoading.value = false;
    }
  }
}
