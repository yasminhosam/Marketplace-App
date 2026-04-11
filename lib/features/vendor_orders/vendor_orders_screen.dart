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
  final List<String> _tabs = ['All', 'New', 'Processing', 'Delivered'];
  String _selectedTab = 'All';

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
            'Orders',
            style: TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.w600,
              fontSize: 18,
            ),
          ),
        ),
        body: Column(
          children: [
            Container(
              height: 50,
              decoration: const BoxDecoration(
                border: Border(
                  bottom: BorderSide(color: Color(0xFF1E2A3A), width: 1),
                ),
              ),
              child: ListView.builder(
                scrollDirection: Axis.horizontal,
                itemCount: _tabs.length,
                itemBuilder: (context, index) {
                  final tab = _tabs[index];
                  final isSelected = tab == _selectedTab;
                  return GestureDetector(
                    onTap: () => setState(() => _selectedTab = tab),
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 20),
                      alignment: Alignment.center,
                      decoration: BoxDecoration(
                        border: Border(
                          bottom: BorderSide(
                            color: isSelected ? const Color(0xff135EF3) : Colors.transparent,
                            width: 2,
                          ),
                        ),
                      ),
                      child: Text(
                        tab,
                        style: TextStyle(
                          color: isSelected ? Colors.white : const Color(0xFF8B9CB6),
                          fontWeight: isSelected ? FontWeight.w600 : FontWeight.w400,
                        ),
                      ),
                    ),
                  );
                },
              ),
            ),
            Expanded(
              child: BlocBuilder<VendorOrdersCubit, VendorOrdersState>(
                builder: (context, state) {
                  if (state is VendorOrdersLoading) {
                    return const Center(child: CircularProgressIndicator(color: Color(0xff135EF3)));
                  } else if (state is VendorOrdersError) {
                    return Center(child: Text(state.errorMessage, style: const TextStyle(color: Colors.red)));
                  } else if (state is VendorOrdersLoaded) {
                    final filteredOrders = _selectedTab == 'All'
                        ? state.orders
                        : state.orders.where((o) => o.status.toLowerCase() == _selectedTab.toLowerCase()).toList();

                    if (filteredOrders.isEmpty) {
                      return const Center(child: Text("No orders found", style: TextStyle(color: Color(0xFF8B9CB6))));
                    }

                    return ListView.separated(
                      padding: const EdgeInsets.all(16),
                      itemCount: filteredOrders.length,
                      separatorBuilder: (_, _) => const SizedBox(height: 16),
                      itemBuilder: (context, index) => OrderCard(order: filteredOrders[index]),
                    );
                  }
                  return const SizedBox.shrink();
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
