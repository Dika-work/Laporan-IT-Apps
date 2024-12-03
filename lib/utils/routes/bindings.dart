import 'package:get/get.dart';
import 'package:laporan/apk/controller/apk_categories_controller.dart';
import 'package:laporan/laporan_bug/controller/posting_bug_controller.dart';

import '../../home_admin/controller/home_admin_controller.dart';
import '../../home_user/controller/home_user_controller.dart';
import '../../login/controller/login_controller.dart';
import '../../register/controller/register_controller.dart';

class HomeAdminBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<HomeAdminController>(
      () => HomeAdminController(),
    );
  }
}

class HomeUserBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<HomeUserController>(
      () => HomeUserController(),
    );
  }
}

class LoginBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<LoginController>(
      () => LoginController(),
    );
  }
}

class RegisterBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<RegisterController>(
      () => RegisterController(),
    );
  }
}

class PostingBugBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<PostingBugController>(
      () => PostingBugController(),
    );
  }
}

class ApkCategoriesBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<ApkCategoriesController>(
      () => ApkCategoriesController(),
    );
  }
}
