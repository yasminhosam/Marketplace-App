import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_fonts/google_fonts.dart';

import '../cubit/main_cart_cubit.dart';
import '../cubit/main_cart_state.dart';

import 'package:marketplace_app/core/routing/app_router.dart';

class Checkout extends StatelessWidget {
  final String clientId;
  final String clientName;

  const Checkout({
    super.key,
    required this.clientId,
    required this.clientName,
  });

  @override
  Widget build(BuildContext context) {
    final cubit = context.read<CartCubit>();

    return BlocListener<CartCubit, CartState>(
      listener: (context, state) {
        if (state is CartLoaded && state.items.isEmpty) {
        }
      },
      child: BlocBuilder<CartCubit, CartState>(
        builder: (context, state) {
          if (state is! CartLoaded) return const SizedBox();

          return SafeArea(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Card(
                color: const Color(0xFF1E212B),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        "Order Summary",
                        style: GoogleFonts.montserrat(
                          fontSize: 18,
                          color: Colors.white,
                          fontWeight: FontWeight.w600,
                        ),
                      ),

                      const SizedBox(height: 15),

                      _row("Subtotal", state.subtotal),
                      _row("Delivery Fee", state.deliveryFee),

                      const Divider(color: Colors.white24),

                      _row("Total", state.total, bold: true),

                      const SizedBox(height: 20),

                      SizedBox(
                        width: double.infinity,
                        height: 55,
                        child: ElevatedButton(
                          onPressed: state.items.isEmpty
                              ? null
                              : () async {
                            await cubit.checkout(
                              clientId: clientId,
                              clientName: clientName,
                            );
                            if (context.mounted) {
                              Navigator.pushNamed(context, AppRouter.clientOrders);
                            }
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xFF1A65FF),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(16),
                            ),
                          ),
                          child: const Text(
                            "Order Now",
                            style: TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                              fontSize: 16,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _row(String title, double value, {bool bold = false}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            title,
            style: TextStyle(
              color: Colors.white,
              fontWeight: bold ? FontWeight.bold : FontWeight.normal,
            ),
          ),
          Text(
            "\$${value.toStringAsFixed(2)}",
            style: TextStyle(
              color: Colors.white,
              fontWeight: bold ? FontWeight.bold : FontWeight.normal,
            ),
          ),
        ],
      ),
    );
  }
}