import 'package:flutter/material.dart';
// استوردنا الموديل الحقيقي
import 'package:marketplace_app/core/models/order_model.dart';

class OrderCard extends StatelessWidget {
  final OrderModel order; // غيرناها للموديل الحقيقي

  const OrderCard({super.key, required this.order});

  Color _getStatusColor(String status) {
    switch (status.toLowerCase()) {
      case 'new':
        return Colors.green;
      case 'processing':
        return Colors.orange;
      case 'delivered':
        return const Color(0xFF8B9CB6);
      default:
        return const Color(0xFF4A90E2);
    }
  }

  @override
  Widget build(BuildContext context) {
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
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 6,
                ),
                decoration: BoxDecoration(
                  color: _getStatusColor(order.status).withOpacity(0.15),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  order.status,
                  style: TextStyle(
                    color: _getStatusColor(order.status),
                    fontWeight: FontWeight.w600,
                    fontSize: 12,
                  ),
                ),
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
                order.vendorName,
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
              Row(
                children: const [
                  Text(
                    'View Details',
                    style: TextStyle(color: Color(0xFF8B9CB6), fontSize: 13),
                  ),
                  SizedBox(width: 4),
                  Icon(Icons.arrow_forward, color: Color(0xFF8B9CB6), size: 16),
                ],
              ),
            ],
          ),
        ],
      ),
    );
  }
}
