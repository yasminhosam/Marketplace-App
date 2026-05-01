import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:marketplace_app/core/services/category_service.dart';
import 'package:marketplace_app/features/auth/login/login_screen.dart';
import 'package:marketplace_app/features/client_home/ui/client_home_screen.dart';
import 'package:marketplace_app/features/favorites/ui/favorites_screen.dart';
import 'package:marketplace_app/features/splash/splash_screen.dart';
import 'package:marketplace_app/features/onboarding/onboarding_screen.dart';
import 'package:marketplace_app/features/auth/register/register_screen.dart';
import 'package:marketplace_app/features/vendor_product/cubit/vendor_products_cubit.dart';
import 'package:marketplace_app/features/vendor_product/ui/vendor_products_screen.dart';
import '../../features/add_product/ui/add_product_screen.dart';
import '../../features/customer_orders/UI/customer_orders_screen.dart';
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
  static const String clientHome = '/client_home';
  static const String clientFavorite='/client_favorite';
  static const String clientOrders='/client_orders';
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
          builder: (_) =>   const AddProductScreen(),
        );
      case vendorProducts:
        return MaterialPageRoute(
            builder: (_) =>
                BlocProvider(
                    create: (context) => VendorProductsCubit(ProductService(),CategoryService()),
                  child: const VendorProductsScreen(),
                ),
        );

      case clientHome :
        return MaterialPageRoute(
            builder: (_) => const ClientHomeScreen()
        );
      case vendorHome:
        return MaterialPageRoute(
          builder: (_) => BlocProvider(
            create: (context) => VendorCubit()..loadVendorHome(),
            child: const VendorHome(),
          ),
        );
      case clientFavorite:
        return MaterialPageRoute(
            builder: (_)=> const FavoritesScreen());
      case clientOrders:
        return MaterialPageRoute(
            builder: (_) => const CustomerOrdersScreen()
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
