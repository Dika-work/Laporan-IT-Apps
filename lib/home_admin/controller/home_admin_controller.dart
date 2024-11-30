import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import 'package:laporan/utils/loadings/snackbar.dart';
import 'package:laporan/utils/routes/app_pages.dart';

class HomeAdminController extends GetxController {
  RxBool isLoading = false.obs;
  RxString username = ''.obs;
  RxString typeUser = ''.obs;
  RxString fotoUser = ''.obs;
  final GlobalKey<TooltipState> tooltipkey = GlobalKey<TooltipState>();

  final localStorage = GetStorage();

  @override
  void onInit() {
    super.onInit();
    fetchUserData();
  }

  fetchUserData() {
    isLoading.value = true;
    try {
      username.value = localStorage.read('username') ?? '';
      typeUser.value = localStorage.read('type_user') ?? '';
      fotoUser.value = localStorage.read('foto_user') ?? '';
    } catch (e) {
      SnackbarLoader.warningSnackBar(
          title: 'Oops',
          message: 'Gagal mengambil data pengguna: ${e.toString()}');
    } finally {
      isLoading.value = false;
    }
  }

  logout() {
    localStorage.remove('username');
    localStorage.remove('type_user');
    localStorage.remove('foto_user');
    Get.offAllNamed(Routes.LOGIN);
  }
}
