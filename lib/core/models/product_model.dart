import 'package:cloud_firestore/cloud_firestore.dart';

class ProductModel {
  final String id; // Firestore document ID
  final String vendorId;
  final String storeName;
  final String name;
  final String categoryId;
  final String imageUrl;
  final double price;
  final int quantity;
  final String description;
  final dynamic createdAt;

  ProductModel({
    required this.id,
    required this.vendorId,
    required this.storeName,
    required this.name,
    required this.categoryId,
    required this.imageUrl,
    required this.price,
    required this.quantity,
    required this.description,
    this.createdAt,
  });

  factory ProductModel.fromMap(Map<String, dynamic> map, String documentId) {
    return ProductModel(
      id: documentId,
      vendorId: map['vendorId'] ?? '',
      storeName: map['storeName'] ?? 'Unknown Store',
      name: map['name'] ?? '',
      categoryId: map['categoryId'] ?? '',
      imageUrl: map['imageUrl'] ?? '',
      price: (map['price'] ?? 0.0).toDouble(),
      quantity: map['quantity'] ?? 0,
      description: map['description'] ?? '',
      createdAt: map['createdAt'],
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'vendorId': vendorId,
      'storeName': storeName,
      'name': name,
      'categoryId': categoryId,
      'imageUrl': imageUrl,
      'price': price,
      'quantity': quantity,
      'description': description,
      'createdAt': createdAt ?? FieldValue.serverTimestamp(),
    };
  }
}