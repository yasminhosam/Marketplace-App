import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

class LoginPage extends StatelessWidget {
  const LoginPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color(0xff0A1F2F),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // store icon
            Container(
              padding: EdgeInsets.all(18),
              decoration: BoxDecoration(
                color: Colors.blueGrey,
                borderRadius: BorderRadius.circular(16),
              ),
              child: Icon(Icons.store, size: 40, color: Colors.white),
            ),

            SizedBox(height: 20),

            Text(
              "Welcome Back",
              style: TextStyle(
                color: Colors.white,
                fontSize: 28,
                fontWeight: FontWeight.bold,
              ),
            ),

            SizedBox(height: 30),

            // Email
            TextField(
              decoration: InputDecoration(
                hintText: "yourname@university.edu",
                prefixIcon: Icon(Icons.email),
                filled: true,
                fillColor: Colors.black26,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
            ),

            SizedBox(height: 20),

            // Password
            TextField(
              obscureText: true,
              decoration: InputDecoration(
                hintText: "Password",
                prefixIcon: Icon(Icons.lock),
                suffixIcon: Icon(Icons.visibility),
                filled: true,
                fillColor: Colors.black26,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
            ),

            SizedBox(height: 25),

            // Login button
            SizedBox(
              width: double.infinity,
              height: 50,
              child: ElevatedButton.icon(
                icon: Icon(Icons.login),
                label: Text("Log In"),
                onPressed: () {},
              ),
            ),

            SizedBox(height: 25),

            Text("OR", style: TextStyle(color: Colors.white70)),

            SizedBox(height: 20),

            // Google & Apple
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                ElevatedButton.icon(
                  icon: Icon(FontAwesomeIcons.google),
                  label: Text("Google"),
                  onPressed: () {},
                ),

                ElevatedButton.icon(
                  icon: Icon(FontAwesomeIcons.apple),
                  label: Text("Apple"),
                  onPressed: () {},
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
