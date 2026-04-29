import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../client_home/ui/client_home_screen.dart';

class EmptyCart extends StatelessWidget {
  const EmptyCart({super.key});

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery
        .of(context)
        .size;
    final width = size.width;

    return Center(
      child: SingleChildScrollView(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: width * 0.5,
              height: width * 0.5,
              decoration: BoxDecoration(
                boxShadow: [
                  BoxShadow(
                    color: Colors.purpleAccent.withOpacity(0.3),
                    blurRadius: 20,
                  ),
                ],
                color: const Color(0xff201043),
                borderRadius: BorderRadius.circular(999),
              ),
              child: Icon(
                Icons.remove_shopping_cart,
                size: width * 0.2,
                color: const Color(0xff5B13EC),
              ),
            ),
            SizedBox(height: size.height * 0.04),
            Text(
              "Your Cart is feeling a bit light",
              textAlign: TextAlign.center,
              style: GoogleFonts.poppins(
                fontWeight: FontWeight.bold,
                fontSize: width * 0.05,
                color: Colors.white,
              ),
            ),
            SizedBox(height: size.height * 0.02),
            Padding(
              padding: EdgeInsets.symmetric(horizontal: width * 0.1),
              child: Text(
                "Looks like you haven't added anything to your cart yet. Explore our curated collections to get started.",
                textAlign: TextAlign.center,
                style: GoogleFonts.poppins(
                  color: Colors.white70,
                  fontSize: width * 0.035,
                ),
              ),
            ),
            SizedBox(height: size.height * 0.04),
            _buildButton(
              text: "Start Shopping",
              width: width,
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                      builder: (context) => const ClientHomeScreen()),
                );
              },
            ),
            const SizedBox(height: 12),
            _buildButton(
              text: "View My Wishist",
              width: width,
              onTap: () {},
            ),
          ],
        ),
      ),
    );
  }
};


  Widget _buildButton({
    required String text,
    required double width,
    required VoidCallback onTap,
  }) {
    return SizedBox(
      width: width * 0.7,
      height: 50,
      child: ElevatedButton(
        onPressed: onTap,
        style: ElevatedButton.styleFrom(
          backgroundColor: const Color(0xff4E12C7),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        ),
        child: Text(
          text,
          style: GoogleFonts.poppins(
            color: Colors.white,
            fontSize: 16,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
    );
  }