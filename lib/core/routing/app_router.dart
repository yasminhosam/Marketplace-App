import 'package:flutter/material.dart';
import 'package:marketplace_app/features/auth/login/login_screen.dart';
import 'package:marketplace_app/features/splash/splash_screen.dart';
import 'package:marketplace_app/features/onboarding/onboarding_screen.dart';
import 'package:marketplace_app/features/auth/register/register_screen.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../features/vendor_home/cubit/vendor_cubit.dart';
import '../../features/vendor_home/home_ui/vendor_home.dart';
class AppRouter {
  static const String splash = '/';
  static const String onboarding = '/onboarding';
  static const String login = '/login';
  static const String register = '/register';
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
      case vendorHome:
        return MaterialPageRoute(
          builder: (_) => BlocProvider(
            create: (context) => VendorCubit()..loadVendorHome(),
            child: const VendorHome(),
          ),
        );
      default:
        return MaterialPageRoute(
          builder: (_) => Scaffold(
            appBar: AppBar(title: const Text('Error')),
            body: Center(child: Text('No route defined for ${settings.name}')),
          ),
        );
    }
  }
}
