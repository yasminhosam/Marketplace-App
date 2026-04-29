import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:marketplace_app/features/cart/main_cart/cubit/main_cart_cubit.dart';
import 'package:marketplace_app/features/cart/main_cart/cubit/main_cart_state.dart';
import 'package:marketplace_app/features/cart/main_cart/ui/item_card.dart';

import '../../empty_cart/empty_cart.dart';
import 'checkout.dart';

class MainCart extends StatelessWidget {
  const MainCart({super.key});

  @override
  Widget build(BuildContext context) {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return const Scaffold(body: Center(child: Text("Not logged in")));

    return BlocProvider(
      create: (_) => CartCubit()..fetchCart(user.uid),
      child: Scaffold(
        backgroundColor: const Color(0xff161023),
        appBar:AppBar(
          backgroundColor: const Color(0xff161022),
          elevation: 0,
          centerTitle: true,
          title: const Text(
            "My Cart",
            style: TextStyle(color: Colors.white, fontSize: 20),
          ),
          leading: Padding(
            padding: const EdgeInsets.all(8.0),
            child: Container(
              decoration: const BoxDecoration(
                color: Color(0xff1B0F36),
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.arrow_back_ios_new,
                color: Colors.white,
                size: 22,
              ),
            ),
          ),
        ),
        body: BlocBuilder<CartCubit, CartState>(
          builder: (context, state) {
            if (state is CartLoading) return const Center(child: CircularProgressIndicator());
            if (state is CartLoaded) {
              if (state.items.isEmpty) return const EmptyCart();
              return Column(
                children: [
                  Expanded(
                    child: ListView.builder(
                      itemCount: state.items.length,
                      itemBuilder: (_, i) => ItemCard(item: state.items[i], clientId: user.uid),
                    ),
                  ),
                  Checkout(clientId: user.uid, clientName: user.displayName ?? "Client"),
                ],
              );
            }
            return const EmptyCart();
          },
        ),
      ),
    );
  }
}