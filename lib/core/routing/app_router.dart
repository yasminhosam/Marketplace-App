import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:marketplace_app/features/auth/login/login_screen.dart';
import 'package:marketplace_app/features/splash/splash_screen.dart';
import 'package:marketplace_app/features/onboarding/onboarding_screen.dart';
import 'package:marketplace_app/features/auth/register/register_screen.dart';
import 'package:marketplace_app/features/vendor_product/cubit/vendor_products_cubit.dart';
import 'package:marketplace_app/features/vendor_product/ui/vendor_products_screen.dart';

import '../../features/add_product/cubit/add_product_cubit.dart';
import '../../features/add_product/ui/add_product_screen.dart';
import '../services/image_service.dart';
import '../services/product_service.dart';

import '../../features/vendor_home/cubit/vendor_cubit.dart';
import '../../features/vendor_home/home_ui/vendor_home.dart';
class AppRouter {
  static const String splash = '/';
  static const String onboarding = '/onboarding';
  static const String login = '/login';
  static const String register = '/register';
  static const String addProduct = '/add-product';
  static const String vendorProducts = '/vendor-products';

  static const String vendorHome = '/vendor_home';
  static Route<dynamic> generateRoute(RouteSettings settings) {
    switch (settings.name) {
      case splash:
        return MaterialPageRoute(builder: (_) => const SplashScreen());
      case onboarding:
        return MaterialPageRoute(builder: (_) => const OnboardingScreen());
      case login:
        return MaterialPageRoute(builder: (_) => const LoginScreen());
      case register:
        return MaterialPageRoute(builder: (_) => const RegisterScreen());
      case addProduct:
        return MaterialPageRoute(
          builder: (_) =>
              BlocProvider(
                create: (context) =>
                    AddProductCubit(
                      ProductService(),
                      CloudinaryService(),
                    ),
                child: const AddProductScreen(),
              ),
        );
      case vendorProducts:
        return MaterialPageRoute(
            builder: (_) =>
                BlocProvider(
                    create: (context) => VendorProductsCubit(ProductService()),
                  child: const VendorProductsScreen(),
                ),
        );

      case vendorHome:
        return MaterialPageRoute(
          builder: (_) => BlocProvider(
            create: (context) => VendorCubit()..loadVendorHome(),
            child: const VendorHome(),
          ),
        );
      default:
        return MaterialPageRoute(
          builder: (_) =>
              Scaffold(
                appBar: AppBar(title: const Text('Error')),
                body: Center(
                    child: Text('No route defined for ${settings.name}')),
              ),
        );
    }
  }
}
