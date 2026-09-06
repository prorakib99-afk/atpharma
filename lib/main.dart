import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'core/di/injection_container.dart';
import 'core/network/backend_smoke_tester.dart';
import 'core/routes/app_routes.dart';
import 'core/session/session_manager.dart';
import 'core/storage/app_database.dart';
import 'core/storage/local_storage_service.dart';
import 'features/auth/presentation/pages/cart_screen.dart';
import 'features/auth/presentation/pages/checkout_screen.dart';
import 'features/auth/presentation/pages/completed_order_screen.dart';
import 'features/auth/presentation/pages/contact_support_screen.dart';
import 'features/auth/presentation/pages/explore_screen.dart';
import 'features/auth/presentation/pages/favorite_store.dart';
import 'features/auth/presentation/pages/home_screen.dart';
import 'features/auth/presentation/pages/login_screen.dart';
import 'features/auth/presentation/pages/otp_screen.dart';
import 'features/auth/presentation/pages/prescription_screen.dart';
import 'features/auth/presentation/pages/profile_screen.dart';
import 'features/auth/presentation/pages/recovery_screen.dart';
import 'features/auth/presentation/pages/register_screen.dart';
import 'features/auth/presentation/pages/reset_pass_screen.dart';
import 'features/auth/presentation/pages/review_order_screen.dart';
import 'features/auth/presentation/pages/screen_product_details.dart';
import 'features/auth/presentation/pages/search_screen.dart';
import 'features/auth/presentation/pages/splash_screen.dart';
import 'features/auth/presentation/pages/start_page.dart';
import 'features/auth/presentation/pages/stripe_payment_nav_screen.dart';
import 'features/auth/presentation/pages/success_reset_pass_screen.dart';
import 'features/auth/presentation/bloc/login/login_bloc.dart';
import 'features/auth/presentation/bloc/login/login_event.dart';
import 'features/auth/presentation/bloc/login/login_state.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await configureDependencies();
  final AppDatabase database = sl<AppDatabase>();
  await ProductCart.instance.initialize(database);
  await FavoriteStore.instance.initialize(sl<LocalStorageService>());

  /// Runs only in debug mode because assert statements are removed
  /// automatically from profile and release builds.
  assert(() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Future<void>.delayed(const Duration(seconds: 3), () {
        unawaited(BackendSmokeTester.run());
      });
    });
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
          return SplashScreen(
            nextRoute: sl<SessionManager>().canAccessStore
                ? AppRoutes.home
                : AppRoutes.startpage,
          );
        },

        AppRoutes.startpage: (BuildContext context) {
          return StartPage(
            onSignInTap: () {
              Navigator.of(context).pushNamed(AppRoutes.login);
            },
            onGuestTap: () async {
              await sl<SessionManager>().startGuestSession();
              if (context.mounted) {
                Navigator.of(context).pushReplacementNamed(AppRoutes.home);
              }
            },
            onSignUpTap: () {
              Navigator.of(context).pushNamed(AppRoutes.register);
            },
          );
        },

        AppRoutes.home: (BuildContext context) {
          if (!sl<SessionManager>().canAccessStore) {
            return StartPage(
              onSignInTap: () {
                Navigator.of(context).pushReplacementNamed(AppRoutes.login);
              },
              onSignUpTap: () {
                Navigator.of(context).pushReplacementNamed(AppRoutes.register);
              },
            );
          }

          return const HomeScreen();
        },

        AppRoutes.profile: (BuildContext context) {
          return const ProfileScreen();
        },

        AppRoutes.explore: (BuildContext context) {
          final Object? arguments = ModalRoute.settingsOf(context)?.arguments;
          final Map<Object?, Object?> values = arguments is Map
              ? arguments
              : const <Object?, Object?>{};
          final List<String> categoryIds = values['categoryIds'] is List
              ? (values['categoryIds'] as List)
                    .map((dynamic id) => id.toString())
                    .toList(growable: false)
              : const <String>[];
          return ExploreScreen(
            initialCategoryId: values['categoryId'] as String?,
            initialCategoryIds: categoryIds,
            initialCategoryName: values['categoryName'] as String?,
          );
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

        AppRoutes.checkout: (BuildContext context) {
          final Object? arguments = ModalRoute.settingsOf(context)?.arguments;
          return CheckoutScreen(
            purchaseItems: arguments is List<ProductCartItem>
                ? arguments
                : null,
          );
        },
        AppRoutes.stripePayment: (BuildContext context) {
          final Object? arguments = ModalRoute.settingsOf(context)?.arguments;
          return StripePaymentNavScreen(
            purchaseItems: arguments is List<ProductCartItem>
                ? arguments
                : null,
          );
        },
        AppRoutes.reviewOrder: (BuildContext context) {
          final Object? arguments = ModalRoute.settingsOf(context)?.arguments;
          final ReviewOrderArguments? reviewArguments =
              arguments is ReviewOrderArguments ? arguments : null;
          return ReviewOrderScreen(
            purchaseItems:
                reviewArguments?.purchaseItems ??
                (arguments is List<ProductCartItem> ? arguments : null),
            paymentMethod: reviewArguments?.paymentMethod ?? 'Stripe',
          );
        },
        AppRoutes.completedOrder: (BuildContext context) {
          return const CompletedOrderScreen();
        },
        AppRoutes.contactSupport: (BuildContext context) {
          return const ContactSupportScreen();
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
          return BlocProvider<LoginBloc>(
            create: (_) => sl<LoginBloc>(),
            child: BlocConsumer<LoginBloc, LoginState>(
              listener: (BuildContext context, LoginState state) {
                if (state.status == LoginStatus.success) {
                  Navigator.of(context).pushNamedAndRemoveUntil(
                    AppRoutes.home,
                    (Route<dynamic> route) => false,
                  );
                  return;
                }
                if (state.status == LoginStatus.failure ||
                    state.status == LoginStatus.twoFactorRequired) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text(
                        state.message ??
                            (state.status == LoginStatus.twoFactorRequired
                                ? 'Two-factor verification is required.'
                                : 'Unable to sign in.'),
                      ),
                    ),
                  );
                }
              },
              builder: (BuildContext context, LoginState state) {
                final SessionManager session = sl<SessionManager>();
                return LoginScreen(
                  initialIdentifier: session.rememberedIdentifier,
                  initialRememberMe: session.rememberMe,
                  isLoading: state.isLoading,
                  onSignIn: (identifier, password, rememberMe) {
                    context.read<LoginBloc>().add(
                      LoginSubmitted(
                        identifier: identifier,
                        password: password,
                        rememberMe: rememberMe,
                      ),
                    );
                  },
                  onForgetPassword: () {
                    Navigator.of(context).pushNamed(AppRoutes.recovery);
                  },
                  onSignUpTap: () {
                    Navigator.of(context).pushNamed(AppRoutes.register);
                  },
                );
              },
            ),
          );
        },

        AppRoutes.recovery: (BuildContext context) {
          return const RecoveryScreen();
        },

        AppRoutes.otp: (BuildContext context) {
          final destination =
              ModalRoute.settingsOf(context)?.arguments as String?;
          return OtpScreen(destination: destination ?? '+880123-56*****');
        },

        AppRoutes.resetPassword: (BuildContext context) {
          return const ResetPassScreen();
        },

        AppRoutes.resetPasswordSuccess: (BuildContext context) {
          return const SuccessResetPassScreen();
        },

        AppRoutes.register: (BuildContext context) {
          return RegisterScreen(
            onSignInTap: () {
              Navigator.of(context).pushNamed(AppRoutes.login);
            },
            onGuestTap: () async {
              await sl<SessionManager>().startGuestSession();
              if (context.mounted) {
                Navigator.of(context).pushReplacementNamed(AppRoutes.home);
              }
            },
          );
        },
      },
    );
  }
}
