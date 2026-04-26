import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:marketplace_app/core/routing/app_router.dart';
import 'package:marketplace_app/core/theme/app_colors.dart';
import 'package:marketplace_app/features/auth/cubit/auth_cubit.dart';
import 'package:marketplace_app/features/auth/cubit/auth_state.dart';

import '../../../core/widgets/custom_text_field.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  bool _obscurePassword = true;

  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  void _showSnackBar(String message, {Color color = Colors.red}) {
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(
        SnackBar(
          content: Text(message),
          backgroundColor: color,
          behavior: SnackBarBehavior.floating,
        ),
      );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0D1117),
      appBar: AppBar(
        backgroundColor: const Color(0xFF0D1117),
        elevation: 0,
        centerTitle: true,
        title: const Text(
          'Log In',
          style: TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.w600,
            fontSize: 18,
          ),
        ),
      ),
      body: BlocConsumer<AuthCubit, AuthState>(
        // listenWhen prevents re-firing when the state object is the same reference,
        listenWhen: (previous, current) =>
            current is AuthError ||
            current is AuthEmailNotVerified ||
            current is AuthPasswordResetSent ||
            current is AuthenticatedClient ||
            current is AuthenticatedVendor,
        listener: (context, state) {
          if (state is AuthError) {
            _showSnackBar(state.message, color: Colors.red);
          } else if (state is AuthEmailNotVerified) {
            _showSnackBar(
              'Please verify your email before logging in.',
              color: Colors.orange,
            );
          }else if(state is AuthPasswordResetSent){
            _showSnackBar(
              'Password reset link sent to your email.',
                color: Colors.green
            );
          }
          else if (state is AuthenticatedClient) {
            _showSnackBar('Welcome to Tijara', color: Colors.green);
            Navigator.pushReplacementNamed(context, AppRouter.clientHome);
          } else if (state is AuthenticatedVendor) {
            _showSnackBar('Welcome to Tijara', color: Colors.green);
            Navigator.pushReplacementNamed(context, AppRouter.vendorHome);
          }
        },
        builder: (context, state) {
          return SafeArea(
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SizedBox(height: 24),
                  Center(
                    child: Container(
                      width: 72,
                      height: 72,
                      decoration: BoxDecoration(
                        color: const Color(0xFF1A2535),
                        borderRadius: BorderRadius.circular(18),
                      ),
                      child: const Icon(
                        Icons.storefront_outlined,
                        color: AppColors.primaryBlue,
                        size: 36,
                      ),
                    ),
                  ),
                  const SizedBox(height: 20),
                  const Center(
                    child: Text(
                      'Welcome Back',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 26,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  const SizedBox(height: 8),
                  const Center(
                    child: Text(
                      'Log in',
                      style: TextStyle(color: Color(0xFF8B9CB6), fontSize: 14),
                    ),
                  ),
                  const SizedBox(height: 40),
                  CustomTextField(
                    label: "Email Address",
                    hint: "yourname@email.com",
                    icon: Icons.email_outlined,
                    controller: _emailController,
                    keyboardType: TextInputType.emailAddress,
                  ),
                  const SizedBox(height: 20),
                  CustomTextField(
                      label: "Password",
                      hint: "••••••••",
                      icon: Icons.lock_outline,
                    isPassword: _obscurePassword,
                    controller: _passwordController,
                    suffix: IconButton(
                        onPressed: (){
                          setState(() {
                            _obscurePassword=!_obscurePassword;
                          });
                        },
                        icon: Icon(
                          _obscurePassword
                          ? Icons.visibility_off_outlined
                              :Icons.visibility_outlined,
                          color: AppColors.hintText,
                          size: 20,
                        )
                    ),
                  ),
                  const SizedBox(height: 12),
                  Align(
                    alignment: Alignment.centerRight,
                    child: TextButton(
                      onPressed: state is AuthLoading
                          ? null
                          : () {
                              final email =_emailController.text.trim();
                              if(email.isEmpty){
                                _showSnackBar(
                                  'Please enter your email address to reset your password.',
                                  color: Colors.orange,
                                );
                                return ;
                              }
                              context.read<AuthCubit>().resetPassword(
                                email: email,
                              );
                            },
                      style: TextButton.styleFrom(
                        padding: EdgeInsets.zero,
                        minimumSize: Size.zero,
                        tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                      ),
                      child: const Text(
                        'Forgot Password?',
                        style: TextStyle(
                          color: AppColors.primaryBlue,
                          fontSize: 13,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 28),
                  SizedBox(
                    width: double.infinity,
                    height: 52,
                    child: ElevatedButton(
                      onPressed: state is AuthLoading
                          ? null
                          : () {
                              context.read<AuthCubit>().login(
                                email: _emailController.text.trim(),
                                password: _passwordController.text.trim(),
                              );
                            },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.primaryBlue,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(14),
                        ),
                        elevation: 0,
                      ),
                      child: state is AuthLoading
                          ? const CircularProgressIndicator(color: Colors.white)
                          : const Text(
                              'Log In',
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 16,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                    ),
                  ),
                  const SizedBox(height: 25),
                  Center(
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Text(
                          "Don't have an account? ",
                          style: TextStyle(
                            color: AppColors.secondaryText ,
                            fontSize: 14,
                          ),
                        ),
                        GestureDetector(
                          onTap: () {
                            Navigator.pushNamed(context, AppRouter.register);
                          },
                          child: const Text(
                            'Sign Up',
                            style: TextStyle(
                              color: AppColors.primaryBlue,
                              fontSize: 13,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 24),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}
