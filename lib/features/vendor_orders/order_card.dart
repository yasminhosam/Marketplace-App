import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:marketplace_app/features/vendor_orders/cubit/vendor_orders_cubit.dart';
// استوردنا الموديل الحقيقي
import 'package:marketplace_app/core/models/order_model.dart';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:marketplace_app/core/models/product_model.dart';
import 'package:marketplace_app/core/services/auth_service.dart';
import 'package:marketplace_app/features/client_home/ui/product_details_screen.dart';

class OrderCard extends StatelessWidget {
  final OrderModel order; // غيرناها للموديل الحقيقي

  const OrderCard({super.key, required this.order});

  @override
  Widget build(BuildContext context) {
    // تحويل التاريخ من DateTime لشكل مقروء8
    final dateString =
        "${order.orderDate.day}/${order.orderDate.month}/${order.orderDate.year}";

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFF141D2B),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFF1E2A3A)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                '#${order.id.substring(0, 6)}', // بناخد أول 6 حروف من الـ ID بتاع الفايربيز
                style: const TextStyle(
                  color: Color(0xFF4A90E2),
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                ),
              ),
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 6,
                    ),
                    decoration: BoxDecoration(
                      color: Colors.green.withOpacity(0.15),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: const Text(
                      "Ordered",
                      style: TextStyle(
                        color: Colors.green,
                        fontWeight: FontWeight.w600,
                        fontSize: 12,
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  IconButton(
                    onPressed: () async {
                      try {
                        await context.read<VendorOrdersCubit>().deleteOrder(order.id);
                        if (context.mounted) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(content: Text("Order deleted successfully")),
                          );
                        }
                      } catch (e) {
                        if (context.mounted) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(content: Text(e.toString())),
                          );
                        }
                      }
                    },
                    icon: const Icon(Icons.delete_outline, color: Colors.redAccent, size: 20),
                    constraints: const BoxConstraints(),
                    padding: EdgeInsets.zero,
                  ),
                ],
              ),
            ],
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              const Icon(
                Icons.person_outline,
                color: Color(0xFF8B9CB6),
                size: 18,
              ),
              const SizedBox(width: 8),
              Text(
                order.clientName, // من الموديل الحقيقي
                style: const TextStyle(color: Colors.white, fontSize: 14),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              const Icon(
                Icons.calendar_today_outlined,
                color: Color(0xFF8B9CB6),
                size: 16,
              ),
              const SizedBox(width: 8),
              Text(
                dateString, // التاريخ بعد التحويل
                style: const TextStyle(color: Color(0xFF8B9CB6), fontSize: 13),
              ),
            ],
          ),
          const Padding(
            padding: EdgeInsets.symmetric(vertical: 12),
            child: Divider(color: Color(0xFF1E2A3A), thickness: 1),
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                '\$${order.totalAmount.toStringAsFixed(2)}', // السعر من الموديل الحقيقي
                style: const TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                  fontSize: 18,
                ),
              ),
              InkWell(
                onTap: () async {
                  if (order.items.isNotEmpty) {
                    final productId = order.items.first.productId;
                    final productDoc = await FirebaseFirestore.instance.collection('products').doc(productId).get();
                    if (productDoc.exists && context.mounted) {
                      final product = ProductModel.fromMap(productDoc.data()!, productDoc.id);
                      final currentUser = FirebaseAuth.instance.currentUser;
                      if (currentUser != null) {
                        final userModel = await AuthService().getUser(currentUser.uid);
                        if (userModel != null && context.mounted) {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => ProductDetailsScreen(
                                product: product,
                                user: userModel,
                              ),
                            ),
                          );
                        }
                      }
                    }
                  }
                },
                child: Row(
                  children: const [
                    Text(
                      'View Details',
                      style: TextStyle(color: Color(0xFF8B9CB6), fontSize: 13),
                    ),
                    SizedBox(width: 4),
                    Icon(Icons.arrow_forward, color: Color(0xFF8B9CB6), size: 16),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
