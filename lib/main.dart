import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import 'package:laporan/utils/routes/app_pages.dart';
import 'package:laporan/utils/theme/theme.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:permission_handler/permission_handler.dart';

// Inisialisasi flutter_local_notifications
final FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin =
    FlutterLocalNotificationsPlugin();

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();

  await setupFlutterNotifications(); // Inisialisasi notifikasi
  getFCMToken(); // Ambil token FCM

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

  runApp(MyApp(initialRoute: initialLocation));
}

// Fungsi untuk setup flutter_local_notifications
Future<void> setupFlutterNotifications() async {
  const AndroidInitializationSettings initializationSettingsAndroid =
      AndroidInitializationSettings('@mipmap/ic_launcher');

  const InitializationSettings initializationSettings = InitializationSettings(
    android: initializationSettingsAndroid,
  );

  await flutterLocalNotificationsPlugin.initialize(initializationSettings);

  FirebaseMessaging.onMessage.listen((RemoteMessage message) {
    debugPrint("🚀 Notifikasi diterima: ${message.data}");

    if (message.data.containsKey('action')) {
      debugPrint("⚡ Action: ${message.data['action']}");
    }

    String? title = message.notification?.title ?? "Notifikasi";
    String? body = message.notification?.body ?? "Tidak ada isi";

    // 🔴 **Jika aksi adalah logout**
    if (message.data['action'] == 'logout') {
      debugPrint("🔴 Logout diterima dari server");

      showNotification(
        title: title,
        body: body,
        channelId: 'logout_channel_id',
        channelName: 'Logout Notifications',
      );

      // Tunggu sebentar sebelum logout
      Future.delayed(const Duration(seconds: 2), () {
        logout();
      });

      return;
    }

    // 🆕 **Jika aksi adalah new_report**
    if (message.data['action'] == 'new_report') {
      showNotification(
        title: title,
        body: body,
        channelId: 'report_channel_id',
        channelName: 'Report Notifications',
      );
      return;
    }

    // 📢 **Jika notifikasi biasa**
    // if (message.notification != null) {
    //   debugPrint("📢 Notifikasi biasa: $title");
    //   showNotification(
    //     title: title,
    //     body: body,
    //     channelId: 'default_channel_id',
    //     channelName: 'General Notifications',
    //   );
    // }
  });
}

// Fungsi untuk mengambil token FCM
Future<void> getFCMToken() async {
  FirebaseMessaging messaging = FirebaseMessaging.instance;

  NotificationSettings settings = await messaging.requestPermission(
    alert: true,
    announcement: false,
    badge: true,
    carPlay: false,
    criticalAlert: false,
    provisional: false,
    sound: true,
  );

  if (settings.authorizationStatus == AuthorizationStatus.authorized) {
    String? token = await messaging.getToken();

    // Coba ulang jika token masih null
    int retryCount = 0;
    while (token == null && retryCount < 3) {
      await Future.delayed(const Duration(seconds: 2));
      token = await messaging.getToken();
      retryCount++;
    }

    if (token != null) {
      final localStorage = GetStorage();
      print("FCM Token: $token");
      localStorage.write('device_token', token);
    } else {
      print("Gagal mendapatkan token FCM setelah 3 percobaan.");
    }
  } else if (settings.authorizationStatus == AuthorizationStatus.denied) {
    print("Izin notifikasi ditolak.");
    showPermissionDeniedDialog();
  } else if (settings.authorizationStatus ==
      AuthorizationStatus.notDetermined) {
    print("Izin notifikasi belum ditentukan.");
  }
}

void showNotification({
  required String title,
  required String body,
  required String channelId,
  required String channelName,
}) {
  flutterLocalNotificationsPlugin.show(
    DateTime.now().millisecondsSinceEpoch.remainder(100000), // Gunakan ID unik
    title,
    body,
    NotificationDetails(
      android: AndroidNotificationDetails(
        channelId,
        channelName,
        importance: Importance.high,
        priority: Priority.high,
      ),
    ),
  );
}

logout() {
  final localStorage = GetStorage();

  localStorage.remove('username');
  localStorage.remove('username_hash');
  localStorage.remove('type_user');
  localStorage.remove('foto_user');
  localStorage.remove('divisi');
  localStorage.write('isLoggedIn', false);
  Get.offAllNamed(Routes.LOGIN);
}

void showPermissionDeniedDialog() {
  Get.defaultDialog(
    title: "Izin Notifikasi Diperlukan",
    middleText:
        "Agar bisa menerima notifikasi, aktifkan izin notifikasi di pengaturan.",
    textConfirm: "Buka Pengaturan",
    textCancel: "Batal",
    confirmTextColor: Colors.white,
    onConfirm: () async {
      await openAppSettings(); // Buka pengaturan aplikasi
    },
  );
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
