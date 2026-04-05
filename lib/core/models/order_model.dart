import 'cart_model.dart';

class OrderModel {
  final String id;
  final String clientId;
  final String clientName;
  final String vendorId;
  final String status;
  final List<CartItemModel> items;
  final double totalAmount;
  final DateTime orderDate;

  OrderModel({
    required this.id,
    required this.clientId,
    this.clientName = 'Unknown Client',
    required this.vendorId,
    this.status = 'New',
    required this.items,
    required this.totalAmount,
    required this.orderDate,
  });

  factory OrderModel.fromMap(Map<String, dynamic> map, String documentId) {
    return OrderModel(
      id: documentId,
      clientId: map['clientId'] ?? '',
      clientName: map['clientName'] ?? 'Unknown Client',
      vendorId: map['vendorId'] ?? '',
      status: map['status'] ?? 'New',
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
      'clientName': clientName,
      'vendorId': vendorId,
      'status': status,
      'items': items.map((item) => item.toMap()).toList(),
      'totalAmount': totalAmount,
      'orderDate': orderDate.toIso8601String(),
    };
  }
}
