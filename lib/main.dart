import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'core/di/injection_container.dart';
import 'core/network/backend_smoke_tester.dart';
import 'core/routes/app_routes.dart';
import 'features/auth/presentation/pages/cart_screen.dart';
import 'features/auth/presentation/pages/explore_screen.dart';
import 'features/auth/presentation/pages/home_screen.dart';
import 'features/auth/presentation/pages/login_screen.dart';
import 'features/auth/presentation/pages/prescription_screen.dart';
import 'features/auth/presentation/pages/register_screen.dart';
import 'features/auth/presentation/pages/screen_product_details.dart';
import 'features/auth/presentation/pages/search_screen.dart';
import 'features/auth/presentation/pages/splash_screen.dart';
import 'features/auth/presentation/pages/start_page.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await configureDependencies();

  /// Runs only in debug mode because assert statements are removed
  /// automatically from profile and release builds.
  assert(() {
    unawaited(BackendSmokeTester.run());
    return true;
  }());

  await SystemChrome.setPreferredOrientations(<DeviceOrientation>[
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
      routes: <String, WidgetBuilder>{
        AppRoutes.splash: (BuildContext context) {
          return const SplashScreen(nextRoute: AppRoutes.startpage);
        },

        AppRoutes.startpage: (BuildContext context) {
          return StartPage(
            onSignInTap: () {
              Navigator.of(context).pushNamed(AppRoutes.login);
            },
            onGuestTap: () {
              Navigator.of(context).pushReplacementNamed(AppRoutes.home);
            },
            onSignUpTap: () {
              Navigator.of(context).pushNamed(AppRoutes.register);
            },
          );
        },

        AppRoutes.home: (BuildContext context) {
          return const HomeScreen();
        },

        AppRoutes.explore: (BuildContext context) {
          return const ExploreScreen();
        },

        AppRoutes.prescription: (BuildContext context) {
          return const PrescriptionScreen();
        },

        AppRoutes.search: (BuildContext context) {
          return const SearchScreen();
        },

        AppRoutes.cart: (BuildContext context) {
          return const CartScreen();
        },

        AppRoutes.productDetails: (BuildContext context) {
          return const ScreenProductDetails(
            product: ProductDetailsData(
              name: 'ORS Oral Saline Sachet',
              image: 'assets/images/product_3_opt.jpg',
            ),
          );
        },

        AppRoutes.login: (BuildContext context) {
          return LoginScreen(
            onSignUpTap: () {
              Navigator.of(context).pushNamed(AppRoutes.register);
            },
          );
        },

        AppRoutes.register: (BuildContext context) {
          return RegisterScreen(
            onSignInTap: () {
              Navigator.of(context).pushNamed(AppRoutes.login);
            },
            onGuestTap: () {
              Navigator.of(context).pushReplacementNamed(AppRoutes.home);
            },
          );
        },
      },
    );
  }
}
