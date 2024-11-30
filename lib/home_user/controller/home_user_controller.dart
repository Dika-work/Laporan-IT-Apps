import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import 'package:laporan/utils/loadings/snackbar.dart';
import 'package:laporan/utils/routes/app_pages.dart';

class HomeUserController extends GetxController {
  RxBool isLoading = false.obs;

  RxString username = ''.obs;
  RxString typeUser = ''.obs;
  RxString fotoUser = ''.obs;
  RxString divisi = ''.obs;

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
      divisi.value = localStorage.read('divisi') ?? '';
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
    localStorage.remove('divisi');
    Get.offAllNamed(Routes.LOGIN);
  }
}
