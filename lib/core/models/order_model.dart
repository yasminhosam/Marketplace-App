import 'cart_model.dart';

class OrderModel {
  final String id;
  final String clientId;
  final String vendorId;
  final List<CartItemModel> items;
  final double totalAmount;
  final DateTime orderDate;

  OrderModel({
    required this.id,
    required this.clientId,
    required this.vendorId,
    required this.items,
    required this.totalAmount,
    required this.orderDate,
  });

  factory OrderModel.fromMap(Map<String, dynamic> map, String documentId) {
    return OrderModel(
      id: documentId,
      clientId: map['clientId'] ?? '',
      vendorId: map['vendorId'] ?? '',
      // Map the list of cart item maps back into CartItemModel objects
      items: List<CartItemModel>.from(
        (map['items'] ?? []).map((item) => CartItemModel.fromMap(item)),
      ),
      totalAmount: (map['totalAmount'] ?? 0.0).toDouble(),
      orderDate: map['orderDate'] != null
          ? DateTime.parse(map['orderDate'])
          : DateTime.now(),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'clientId': clientId,
      'vendorId': vendorId,
      // Convert the objects back into standard maps for Firestore
      'items': items.map((item) => item.toMap()).toList(),
      'totalAmount': totalAmount,

      'orderDate': orderDate.toIso8601String(),
    };
  }
}