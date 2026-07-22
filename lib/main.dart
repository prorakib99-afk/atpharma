import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'core/routes/app_routes.dart';
import 'features/auth/presentation/pages/login_screen.dart';
import 'features/auth/presentation/pages/register_screen.dart';
import 'features/auth/presentation/pages/home_screen.dart';
import 'features/auth/presentation/pages/explore_screen.dart';
import 'features/auth/presentation/pages/prescription_screen.dart';
import 'features/auth/presentation/pages/search_screen.dart';
import 'features/auth/presentation/pages/cart_screen.dart';
import 'features/auth/presentation/pages/splash_screen.dart';
import 'features/auth/presentation/pages/start_page.dart';

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
      title: 'AT Pharma App',
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
            const SplashScreen(nextRoute: AppRoutes.startpage),

        AppRoutes.startpage: (context) => StartPage(
          onSignInTap: () => Navigator.of(context).pushNamed(AppRoutes.login),
          onGuestTap: () =>
              Navigator.of(context).pushReplacementNamed(AppRoutes.home),
          onSignUpTap: () => Navigator.of(context).pushNamed(AppRoutes.register),
        ),

        AppRoutes.home: (context) => const HomeScreen(),
        AppRoutes.explore: (context) => const ExploreScreen(),
        AppRoutes.prescription: (context) => const PrescriptionScreen(),
        AppRoutes.search: (context) => const SearchScreen(),
        AppRoutes.cart: (context) => const CartScreen(),

        AppRoutes.login: (context) => LoginScreen(
          onSignUpTap: () => Navigator.of(context).pushNamed(AppRoutes.register),
        ),

        AppRoutes.register: (context) => RegisterScreen(
          onSignInTap: () => Navigator.of(context).pushNamed(AppRoutes.login),
        ),
      },
    );
  }
}
