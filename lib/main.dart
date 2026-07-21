import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'core/routes/app_routes.dart';
import 'features/auth/presentation/pages/login_screen.dart';
import 'features/auth/presentation/pages/splash_screen.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
    DeviceOrientation.portraitDown,
  ]);

  SystemChrome.setSystemUIOverlayStyle(
    const SystemUiOverlayStyle(
      statusBarColor: Colors.transparent,
      statusBarIconBrightness: Brightness.dark,
      statusBarBrightness: Brightness.light,
      systemNavigationBarColor: Colors.white,
      systemNavigationBarIconBrightness: Brightness.dark,
    ),
  );

  runApp(const AtPharmaApp());
}

class AtPharmaApp extends StatelessWidget {
  const AtPharmaApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'AT Pharma',
      debugShowCheckedModeBanner: false,
      initialRoute: AppRoutes.splash,
      theme: ThemeData(
        useMaterial3: true,
        scaffoldBackgroundColor: Colors.white,
        fontFamily: 'Poppins',
        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color(0xFF128644),
          brightness: Brightness.light,
        ),
      ),
      routes: {
        AppRoutes.splash: (context) =>
            const SplashScreen(nextRoute: AppRoutes.login),
        AppRoutes.login: (context) => const LoginScreen(),
      },
    );
  }
}
