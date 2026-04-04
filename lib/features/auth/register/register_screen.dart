import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:marketplace_app/features/auth/cubit/auth_cubit.dart';
import 'package:marketplace_app/features/auth/cubit/auth_state.dart';

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key});

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  bool isClient = true;
  bool _obscureText = true;

  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();

  final TextEditingController _storeNameController=TextEditingController();
  final TextEditingController _storeDescController=TextEditingController();
  final Color backgroundColor = const Color(0xFF0F1117);
  final Color inputFillColor = const Color(0xFF1B1E26);
  final Color primaryBlue = const Color(0xFF2D82FF);
  final Color hintColor = Colors.white38;

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    _storeNameController.dispose();
    _storeDescController.dispose();
    super.dispose();
  }

  void _showSnackBar(String message, {Color color = Colors.red}) {
    // Dismiss any existing snackbar before showing a new one to prevent stacking.
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
      backgroundColor: backgroundColor,
      body: BlocConsumer<AuthCubit, AuthState>(
        listenWhen: (previous, current) =>
        current is AuthError || current is AuthEmailNotVerified,
        listener: (context, state) {
          if (state is AuthError) {
            _showSnackBar(state.message, color: Colors.red);
          } else if (state is AuthEmailNotVerified) {
            _showSnackBar(
              'Account created! Check your email to verify before logging in.',
              color: Colors.green,
            );
            Navigator.pop(context); // back to login
          }
        },
        builder: (context, state) {
          return SafeArea(
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 24.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SizedBox(height: 20),
                  Row(
                    children: [
                      _buildCircleBackButton(),
                      const Expanded(
                        child: Center(
                          child: Text(
                            "Create Account",
                            style: TextStyle(
                                fontSize: 22,
                                fontWeight: FontWeight.bold,
                                color: Colors.white),
                          ),
                        ),
                      ),
                      const SizedBox(width: 45),
                    ],
                  ),

                  const SizedBox(height: 40),

                  Container(
                    height: 60,
                    padding: const EdgeInsets.all(6),
                    decoration: BoxDecoration(
                        color: inputFillColor,
                        borderRadius: BorderRadius.circular(20)),
                    child: Row(
                      children: [
                        Expanded(
                            child: _buildToggleOption("Client", isClient,
                                    () => setState(() => isClient = true))),
                        Expanded(
                            child: _buildToggleOption("Seller", !isClient,
                                    () => setState(() => isClient = false))),
                      ],
                    ),
                  ),

                  const SizedBox(height: 35),
                  _buildLabel("Full Name"),
                  _buildTextField(
                      hint: "Enter your full name",
                      icon: Icons.person_outline,
                      controller: _nameController),
                  const SizedBox(height: 20),
                  _buildLabel("Email Address"),
                  _buildTextField(
                      hint: "name@university.edu",
                      icon: Icons.email_outlined,
                      controller: _emailController),
                  const SizedBox(height: 20),

                  if (!isClient) ...[
                    _buildLabel("Store Name"),
                    _buildTextField(
                        hint: "",
                        icon: Icons.work_outline,
                        controller: _storeNameController
                    ),

                    const SizedBox(height: 20),
                    _buildLabel("Short Bio / Description"),
                    _buildTextField(
                        hint: "Briefly describe what you offer...",
                        icon: Icons.description_outlined,
                        controller: _storeDescController,
                        maxLength: 200),
                    const SizedBox(height: 20),
                  ],

                  _buildLabel("Password"),
                  _buildTextField(
                    controller: _passwordController,
                    hint: "Create a password",
                    icon: Icons.lock_outline,
                    isPassword: true,
                    suffix: IconButton(
                      icon: Icon(
                          _obscureText
                              ? Icons.visibility_off_outlined
                              : Icons.visibility_outlined,
                          color: hintColor),
                      onPressed: () =>
                          setState(() => _obscureText = !_obscureText),
                    ),
                  ),

                  const SizedBox(height: 40),

                  SizedBox(
                    width: double.infinity,
                    height: 60,
                    child: ElevatedButton(
                      onPressed: state is AuthLoading
                          ? null
                          : () {
                        context.read<AuthCubit>().register(
                          username: _nameController.text.trim(),
                          email: _emailController.text.trim(),
                          password: _passwordController.text.trim(),
                          role: isClient ? 'client' : 'vendor',
                          storeName:  _storeNameController.text.trim(),
                          storeDescription: _storeDescController.text.trim()
                        );
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: primaryBlue,
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(25)),
                      ),
                      child: state is AuthLoading
                          ? const CircularProgressIndicator(color: Colors.white)
                          : const Text(
                        "Sign Up",
                        style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: Colors.white),
                      ),
                    ),
                  ),

                  const SizedBox(height: 25),

                  Center(
                    child: RichText(
                      text: TextSpan(
                        text: "Already have an account? ",
                        style: const TextStyle(
                            color: Colors.white54, fontSize: 14),
                        children: [
                          TextSpan(
                            text: "Log In",
                            style: TextStyle(
                                color: primaryBlue,
                                fontWeight: FontWeight.bold),
                            recognizer: TapGestureRecognizer()
                              ..onTap = () {
                                Navigator.pop(context);
                              },
                          ),
                        ],
                      ),
                    ),
                  ),

                  const SizedBox(height: 40),
                  const Center(
                    child: Text(
                      "STUDENT MARKETPLACE APP",
                      style: TextStyle(
                          color: Colors.white12,
                          fontSize: 12,
                          letterSpacing: 1.5,
                          fontWeight: FontWeight.bold),
                    ),
                  ),
                  const SizedBox(height: 20),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildLabel(String text) => Padding(
      padding: const EdgeInsets.only(bottom: 10, left: 4),
      child: Text(text,
          style: const TextStyle(
              color: Colors.white,
              fontSize: 16,
              fontWeight: FontWeight.w500)));

  Widget _buildTextField({
    required String hint,
    required IconData icon,
    bool isPassword = false,
    Widget? suffix,
    int? maxLength,
    TextEditingController? controller,
  }) {
    return TextField(
      controller: controller,
      obscureText: isPassword ? _obscureText : false,
      maxLength: maxLength,
      style: const TextStyle(color: Colors.white),
      decoration: InputDecoration(
        hintText: hint,
        hintStyle: TextStyle(color: hintColor, fontSize: 14),
        prefixIcon: Icon(icon, color: hintColor, size: 22),
        suffixIcon: suffix,
        counterText: "",
        filled: true,
        fillColor: inputFillColor,
        border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(20),
            borderSide: BorderSide.none),
        contentPadding: const EdgeInsets.symmetric(vertical: 20),
      ),
    );
  }

  Widget _buildToggleOption(
      String title, bool isActive, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 250),
        decoration: BoxDecoration(
            color: isActive ? primaryBlue : Colors.transparent,
            borderRadius: BorderRadius.circular(15)),
        alignment: Alignment.center,
        child: Text(title,
            style: TextStyle(
                color: isActive ? Colors.white : hintColor,
                fontWeight: FontWeight.bold,
                fontSize: 16)),
      ),
    );
  }

  Widget _buildCircleBackButton() => Container(
    decoration:
    BoxDecoration(color: inputFillColor, shape: BoxShape.circle),
    child: IconButton(
        icon: const Icon(Icons.arrow_back_ios_new,
            color: Colors.white, size: 18),
        onPressed: () => Navigator.pop(context)),
  );
}