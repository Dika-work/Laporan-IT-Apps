import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:laporan/providers/auth_provider.dart';
import 'package:laporan/utils/routes/routes.dart';
import 'package:laporan/utils/theme/theme.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(const ProviderScope(child: MyApp()));
}

class MyApp extends ConsumerWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final router = ref.watch(routerProvider);

    ref.listen(authProvider, (previous, next) {
      if (next.isLoggedIn) {
        router.go('/home'); // Pindahkan ke home jika login
      } else {
        router.go('/login'); // Pindahkan ke login jika logout
      }
    });
    return MaterialApp.router(
      debugShowCheckedModeBanner: false,
      title: 'Data Viewer',
      theme: AppTheme.lightTheme,
      localizationsDelegates: const [
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      routerConfig: router,
    );
  }
}
