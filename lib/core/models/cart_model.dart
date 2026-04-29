class CartItemModel {
  final String? docId;
  final String productId;
  final String vendorId;
  final String storeName;
  final String name;
  final String description;
  final String imageUrl;
  final double price;
  final int selectedQuantity;

  CartItemModel({
    this.docId,
    required this.productId,
    required this.vendorId,
    required this.storeName,
    required this.name,
    required this.description,
    required this.imageUrl,
    required this.price,
    required this.selectedQuantity,
  });

  factory CartItemModel.fromMap(Map<String, dynamic> map, {String? documentId}) {
    return CartItemModel(
      docId: documentId,
      productId: map['productId'] ?? '',
      vendorId: map['vendorId'] ?? map['venndorId'] ?? '',
      storeName: map['storeName'] ?? '',
      name: map['name'] ?? '',
      description: map['description'] ?? '',
      imageUrl: map['imageUrl'] ?? '',
      price: (map['price'] ?? 0).toDouble(),
      selectedQuantity: (map['selectedQuantity'] ?? 1).toInt(),
    );
  }

  Map<String, dynamic> toMap() => {
    'productId': productId,
    'vendorId': vendorId,
    'storeName': storeName,
    'name': name,
    'description': description,
    'imageUrl': imageUrl,
    'price': price,
    'selectedQuantity': selectedQuantity,
  };

  CartItemModel copyWith({int? selectedQuantity}) => CartItemModel(
    docId: docId,
    productId: productId,
    vendorId: vendorId,
    storeName: storeName,
    name: name,
    description: description,
    imageUrl: imageUrl,
    price: price,
    selectedQuantity: selectedQuantity ?? this.selectedQuantity,
  );
}