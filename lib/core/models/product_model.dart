class ProductModel {
  final String id; // Firestore document ID
  final String vendorId;// Links the product to the vendor who created it
  final String storeName;
  final String name;
  final String categoryId;
  final String imageUrl;
  final double price;
  final int quantity;
  final String description;

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
      description:map['description'] ?? '',
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
      'description' :description
    };
  }
}