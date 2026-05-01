import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:marketplace_app/core/models/cart_model.dart';
import 'package:marketplace_app/core/models/product_model.dart';
import 'package:marketplace_app/core/models/user_model.dart';

class CartService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  Future<void> addToCart({
    required String clientId,
    required ProductModel product,
    required int quantity,
  }) async {
    try {
      final cartItemRef = _firestore
          .collection('carts')
          .doc(clientId)
          .collection('items')
          .doc(product.id);

      final doc = await cartItemRef.get();

      if (doc.exists) {
        // Update quantity if already in cart
        await cartItemRef.update({
          'selectedQuantity': FieldValue.increment(quantity),
        });
      } else {
        // Add new item
        final cartItem = {
          'productId': product.id,
          'selectedQuantity': quantity,
          // We don't store full product info here as per CartCubit's fetchCart logic
          // which fetches it from products collection.
          // Wait, CartCubit.fetchCart expects:
          // 'productId'
          // and then it fetches the rest.
        };
        await cartItemRef.set(cartItem);
      }
    } catch (e) {
      throw Exception("Failed to add to cart: $e");
    }
  }

  Future<void> placeOrderDirectly({
    required UserModel client,
    required ProductModel product,
    required int quantity,
  }) async {
    try {
      final batch = _firestore.batch();
      final String orderId = _firestore.collection('orders').doc().id;
      final String orderDate = DateTime.now().toIso8601String();

      // Get vendor info
      final vendorDoc = await _firestore.collection('users').doc(product.vendorId).get();
      final vendorName = vendorDoc.data()?['name'] ?? 'Unknown Vendor';

      final cartItem = CartItemModel(
        productId: product.id,
        vendorId: product.vendorId,
        storeName: vendorName,
        name: product.name,
        description: product.description,
        imageUrl: product.imageUrl,
        price: product.price,
        selectedQuantity: quantity,
      );

      final totalAmount = (product.price * quantity) + 25;

      final orderData = {
        'orderId': orderId,
        'clientId': client.uid,
        'clientName': client.name,
        'vendorId': product.vendorId,
        'vendorName': vendorName,
        'items': [cartItem.toMap()],
        'totalAmount': totalAmount,
        'status': 'processing',
        'orderDate': orderDate,
      };

      // 1. General orders collection
      batch.set(_firestore.collection('orders').doc(orderId), orderData);

      // 2. Client orders collection
      batch.set(
        _firestore.collection('client_orders').doc(client.uid).collection('orders').doc(orderId),
        orderData,
      );

      // 3. Vendor orders collection
      batch.set(
        _firestore.collection('vendor_orders').doc(product.vendorId).collection('orders').doc(orderId),
        orderData,
      );

      // 4. Update stock
      batch.update(
        _firestore.collection('products').doc(product.id),
        {'quantity': FieldValue.increment(-quantity)},
      );

      await batch.commit();
    } catch (e) {
      throw Exception("Failed to place order: $e");
    }
  }

  Future<void> deleteOrder({
    required String orderId,
    required String clientId,
    required String vendorId,
  }) async {
    try {
      final batch = _firestore.batch();

      // 1. Delete from general orders
      batch.delete(_firestore.collection('orders').doc(orderId));

      // 2. Delete from client orders
      batch.delete(
        _firestore.collection('client_orders').doc(clientId).collection('orders').doc(orderId),
      );

      // 3. Delete from vendor orders
      batch.delete(
        _firestore.collection('vendor_orders').doc(vendorId).collection('orders').doc(orderId),
      );

      await batch.commit();
    } catch (e) {
      throw Exception("Failed to delete order: $e");
    }
  }
}
