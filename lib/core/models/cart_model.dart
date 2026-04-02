class CartItemModel {
  final String productId;
  final String vendorId;
  final String storeName;
  final String name;
  final String imageUrl;
  final double price;
  int selectedQuantity;

  CartItemModel({
    required this.productId,
    required this.vendorId,
    required this.storeName,
    required this.name,
    required this.imageUrl,
    required this.price,
    required this.selectedQuantity,
  });

  factory CartItemModel.fromMap(Map<String, dynamic> map) {
    return CartItemModel(
      productId: map['productId'] ?? '',
      vendorId: map['vendorId'] ?? '',
      storeName: map['storeName'] ?? 'Unknown Store',
      name: map['name'] ?? '',
      imageUrl: map['imageUrl'] ?? '',
      price: (map['price'] ?? 0.0).toDouble(),
      selectedQuantity: map['selectedQuantity'] ?? 1,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'productId': productId,
      'vendorId': vendorId,
      'storeName': storeName,
      'name': name,
      'imageUrl': imageUrl,
      'price': price,
      'selectedQuantity': selectedQuantity,
    };
  }
}