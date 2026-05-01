import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:marketplace_app/features/vendor_orders/cubit/vendor_orders_cubit.dart';
import 'package:marketplace_app/features/vendor_orders/cubit/vendor_orders_state.dart';
import 'package:marketplace_app/features/vendor_orders/order_card.dart';

class VendorOrdersScreen extends StatefulWidget {
  const VendorOrdersScreen({super.key});

  @override
  State<VendorOrdersScreen> createState() => _VendorOrdersScreenState();
}

class _VendorOrdersScreenState extends State<VendorOrdersScreen> {
  @override
  Widget build(BuildContext context) {
    final vendorId = FirebaseAuth.instance.currentUser?.uid ?? "";
    
    return BlocProvider(
      create: (context) => VendorOrdersCubit()..fetchVendorOrders(vendorId),
      child: Scaffold(
        backgroundColor: const Color(0xFF101622),
        appBar: AppBar(
          backgroundColor: const Color(0xFF101622),
          elevation: 0,
          centerTitle: true,
          title: const Text(
            'Product Orders',
            style: TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.w600,
              fontSize: 18,
            ),
          ),
        ),
        body: BlocBuilder<VendorOrdersCubit, VendorOrdersState>(
                builder: (context, state) {
                  if (state is VendorOrdersLoading) {
                    return const Center(child: CircularProgressIndicator(color: Color(0xff135EF3)));
                  } else if (state is VendorOrdersError) {
                    return Center(child: Text(state.errorMessage, style: const TextStyle(color: Colors.red)));
                  } else if (state is VendorOrdersLoaded) {
                    final orders = state.orders;

                    if (orders.isEmpty) {
                      return const Center(child: Text("No orders found", style: TextStyle(color: Color(0xFF8B9CB6))));
                    }

                    return ListView.separated(
                      padding: const EdgeInsets.all(16),
                      itemCount: orders.length,
                      separatorBuilder: (_, _) => const SizedBox(height: 16),
                      itemBuilder: (context, index) => OrderCard(order: orders[index]),
                    );
                  }
                  return const SizedBox.shrink();
                },
              ),
      ),
    );
  }
}
