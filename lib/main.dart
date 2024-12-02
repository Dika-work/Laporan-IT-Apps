import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import 'package:laporan/utils/routes/app_pages.dart';
import 'package:laporan/utils/theme/theme.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await SystemChrome.setPreferredOrientations([DeviceOrientation.portraitUp]);

  // Inisialisasi GetStorage
  await GetStorage.init();

  final localStorage = GetStorage();
  final bool isFirstTime = localStorage.read('IsFirstTime') ?? true;

  final bool isLoggedIn = localStorage.read('isLoggedIn') ?? false;

  final String? typeUser = localStorage.read('type_user');

  String initialLocation;
  if (isFirstTime) {
    localStorage.write('IsFirstTime', false);
    initialLocation = Routes.LOGIN;
  } else if (isLoggedIn) {
    initialLocation =
        typeUser == 'admin' ? Routes.HOME_ADMIN : Routes.HOME_USER;
  } else {
    initialLocation = Routes.LOGIN;
  }
  // debugPaintSizeEnabled = true;

  runApp(MyApp(initialRoute: initialLocation));
}

class MyApp extends StatelessWidget {
  final String initialRoute;
  const MyApp({super.key, required this.initialRoute});

  @override
  Widget build(BuildContext context) {
    return GetMaterialApp(
      debugShowCheckedModeBanner: false,
      themeMode: ThemeMode.light,
      theme: AppTheme.lightTheme,
      localizationsDelegates: const [
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      initialRoute: initialRoute,
      getPages: AppPages.routes,
    );
  }
}
