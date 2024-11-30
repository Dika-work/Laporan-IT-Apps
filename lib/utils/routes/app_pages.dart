import 'package:get/get.dart';
import 'package:laporan/home_admin/view/home_admin.dart';
import 'package:laporan/home_user/view/home_user.dart';
import 'package:laporan/laporan_bug/view/posting_bug.dart';
import 'package:laporan/login/view/login.dart';
import 'package:laporan/register/view/register.dart';
import 'package:laporan/utils/routes/bindings.dart';

part 'app_routes.dart';

class AppPages {
  AppPages._();

  static const INITIAL = Routes.LOGIN;

  static final routes = [
    GetPage(
      name: _Paths.HOME_ADMIN,
      page: () => const HomeAdmin(),
      binding: HomeAdminBinding(),
      transition: Transition.fadeIn,
    ),
    GetPage(
      name: _Paths.HOME_USER,
      page: () => const HomeUser(),
      binding: HomeUserBinding(),
      transition: Transition.fadeIn,
    ),
    GetPage(
      name: _Paths.LOGIN,
      page: () => const LoginView(),
      binding: LoginBinding(),
    ),
    GetPage(
      name: _Paths.REGISTER,
      page: () => const RegisterView(),
      binding: RegisterBinding(),
    ),
    GetPage(
      name: _Paths.POSTING_BUG,
      page: () => const PostingBug(),
      binding: PostingBugBinding(),
    ),
  ];
}
