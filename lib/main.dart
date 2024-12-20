import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import 'package:laporan/utils/routes/app_pages.dart';
import 'package:laporan/utils/theme/theme.dart';
import 'package:onesignal_flutter/onesignal_flutter.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  OneSignal.initialize("475d4f0d-d3e1-4bfe-8dc2-2ebb22eff462");

  OneSignal.Notifications.requestPermission(true);
  // var deviceState = await OneSignal.User.pushSubscription.id;
  // if (deviceState != null) {
  //   print("Player ID: $deviceState");
  //   // Kirim Player ID ke backend jika pengguna login
  //   sendPlayerIdToBackend(deviceState);
  // }

  await SystemChrome.setPreferredOrientations([DeviceOrientation.portraitUp]);

  // Inisialisasi GetStorage
  await GetStorage.init();

  final localStorage = GetStorage();
  final bool isFirstTime = localStorage.read('IsFirstTime') ?? true;

  final bool isLoggedIn = localStorage.read('isLoggedIn') ?? false;

  final String? typeUser = localStorage.read('type_user');

  String initialLocation;
  if (isFirstTime) {
    initialLocation = AppPages.INITIAL;
    await localStorage.write('IsFirstTime', false);
  } else if (isLoggedIn) {
    initialLocation =
        typeUser == 'admin' ? Routes.HOME_ADMIN : Routes.HOME_USER;
  } else {
    initialLocation = AppPages.INITIAL;
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
