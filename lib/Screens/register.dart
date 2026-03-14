import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';

void main() {
  runApp(const StudentMarketplaceApp());
}

class StudentMarketplaceApp extends StatelessWidget {
  const StudentMarketplaceApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        brightness: Brightness.dark,
        fontFamily: 'sans-serif',
      ),
      home: const SignUpScreen(),
    );
  }
}


class LoginScreen extends StatelessWidget {
  const LoginScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0F1117),
      appBar: AppBar(backgroundColor: Colors.transparent, elevation: 0),
      body: const Center(
        child: Text("Welcome to Login Screen", style: TextStyle(color: Colors.white, fontSize: 20)),
      ),
    );
  }
}

class SignUpScreen extends StatefulWidget {
  const SignUpScreen({super.key});

  @override
  _SignUpScreenState createState() => _SignUpScreenState();
}

class _SignUpScreenState extends State<SignUpScreen> {
  bool isClient = true;
  bool _obscureText = true;

  final Color backgroundColor = const Color(0xFF0F1117);
  final Color inputFillColor = const Color(0xFF1B1E26);
  final Color primaryBlue = const Color(0xFF2D82FF);
  final Color hintColor = Colors.white38;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: backgroundColor,
      body: SafeArea(
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
                      child: Text("Create Account", style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: Colors.white)),
                    ),
                  ),
                  const SizedBox(width: 45),
                ],
              ),

              const SizedBox(height: 40),

              Container(
                height: 60,
                padding: const EdgeInsets.all(6),
                decoration: BoxDecoration(color: inputFillColor, borderRadius: BorderRadius.circular(20)),
                child: Row(
                  children: [
                    Expanded(child: _buildToggleOption("Client", isClient, () => setState(() => isClient = true))),
                    Expanded(child: _buildToggleOption("Seller", !isClient, () => setState(() => isClient = false))),
                  ],
                ),
              ),

              const SizedBox(height: 35),
              _buildLabel("Full Name"),
              _buildTextField(hint: "Enter your full name", icon: Icons.person_outline),
              const SizedBox(height: 20),
              _buildLabel("Email Address"),
              _buildTextField(hint: "name@university.edu", icon: Icons.email_outlined),
              const SizedBox(height: 20),

              if (!isClient) ...[
                _buildLabel("Business Type"),
                _buildTextField(hint: "Graphic Design, Tutoring, etc.", icon: Icons.work_outline),
                const SizedBox(height: 20),
                _buildLabel("Short Bio / Experience"),
                _buildTextField(hint: "Briefly describe what you offer...", icon: Icons.description_outlined, maxLength: 200),
                const SizedBox(height: 20),
              ],

              _buildLabel("Password"),
              _buildTextField(
                hint: "Create a password",
                icon: Icons.lock_outline,
                isPassword: true,
                suffix: IconButton(
                  icon: Icon(_obscureText ? Icons.visibility_off_outlined : Icons.visibility_outlined, color: hintColor),
                  onPressed: () => setState(() => _obscureText = !_obscureText),
                ),
              ),

              const SizedBox(height: 40),

              SizedBox(
                width: double.infinity,
                height: 60,
                child: ElevatedButton(
                  onPressed: () {},
                  style: ElevatedButton.styleFrom(
                    backgroundColor: primaryBlue,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(25)),
                  ),
                  child: const Text("Sign Up", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.white)),
                ),
              ),

              const SizedBox(height: 25),

              Center(
                child: RichText(
                  text: TextSpan(
                    text: "Already have an account? ",
                    style: const TextStyle(color: Colors.white54, fontSize: 14),
                    children: [
                      TextSpan(
                        text: "Log In",
                        style: TextStyle(color: primaryBlue, fontWeight: FontWeight.bold),
                        recognizer: TapGestureRecognizer()
                          ..onTap = () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(builder: (context) => const LoginScreen()),
                            );
                          },
                      ),
                    ],
                  ),
                ),
              ),

              const SizedBox(height: 40),
              const Center(child: Text("STUDENT MARKETPLACE APP", style: TextStyle(color: Colors.white12, fontSize: 12, letterSpacing: 1.5, fontWeight: FontWeight.bold))),
              const SizedBox(height: 20),
            ],
          ),
        ),
      ),
    );
  }
  Widget _buildLabel(String text) => Padding(padding: const EdgeInsets.only(bottom: 10, left: 4), child: Text(text, style: const TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.w500)));

  Widget _buildTextField({required String hint, required IconData icon, bool isPassword = false, Widget? suffix, int? maxLength}) {
    return TextField(
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
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(20), borderSide: BorderSide.none),
        contentPadding: const EdgeInsets.symmetric(vertical: 20),
      ),
    );
  }

  Widget _buildToggleOption(String title, bool isActive, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 250),
        decoration: BoxDecoration(color: isActive ? primaryBlue : Colors.transparent, borderRadius: BorderRadius.circular(15)),
        alignment: Alignment.center,
        child: Text(title, style: TextStyle(color: isActive ? Colors.white : hintColor, fontWeight: FontWeight.bold, fontSize: 16)),
      ),
    );
  }

  Widget _buildCircleBackButton() => Container(
    decoration: BoxDecoration(color: inputFillColor, shape: BoxShape.circle),
    child: IconButton(icon: const Icon(Icons.arrow_back_ios_new, color: Colors.white, size: 18), onPressed: () {}),
  );
}