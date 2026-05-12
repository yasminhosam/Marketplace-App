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

      final productRef = _firestore.collection('products').doc(product.id);

      // Use a transaction to safely check live stock and current cart contents

      await _firestore.runTransaction((transaction) async {

        final productSnapshot = await transaction.get(productRef);
        if (!productSnapshot.exists) {
          throw Exception("Product no longer exists.");
        }
        final int actualStock = productSnapshot.data()?['quantity'] ?? 0;

        final cartSnapshot = await transaction.get(cartItemRef);
        int currentCartQuantity = 0;

        if (cartSnapshot.exists) {
          currentCartQuantity = cartSnapshot.data()?['selectedQuantity'] ?? 0;
        }

        final int newTotalQuantity = currentCartQuantity + quantity;

        if (newTotalQuantity > actualStock) {
          throw Exception(
              "Cannot add $quantity. You already have $currentCartQuantity in your cart, and only $actualStock are available."
          );
        }

        if (cartSnapshot.exists) {
          transaction.update(cartItemRef, {
            'selectedQuantity': newTotalQuantity,
          });
        } else {
          transaction.set(cartItemRef, {
            'productId': product.id,
            'selectedQuantity': newTotalQuantity,
          });
        }
      });
    } catch (e) {
      throw Exception(e.toString().replaceAll("Exception: ", ""));
    }
  }

  Future<void> placeOrderDirectly({
    required UserModel client,
    required ProductModel product,
    required int quantity,
  }) async {
    try {
      final productRef = _firestore.collection('products').doc(product.id);
      final vendorRef = _firestore.collection('users').doc(product.vendorId);

      final String orderId = _firestore.collection('orders').doc().id;
      final String orderDate = DateTime.now().toIso8601String();

      await _firestore.runTransaction((transaction) async {
        final productSnapshot = await transaction.get(productRef);
        if(!productSnapshot.exists){
          throw Exception("This product is not available anymore");
        }
        final int currentStock = productSnapshot.data()?['quantity'] ?? 0;
        if(currentStock < quantity){
          throw Exception("Sorry, we're out of stock! Only $currentStock is currently available.");
        }
        final vendorSnapshot =await transaction.get(vendorRef);
        final vendorName = vendorSnapshot.data()?['name'] ?? 'Unknown Vendor' ;
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

        final orderRef = _firestore.collection('orders').doc(orderId);
        final clientOrderRef = _firestore.collection('client_orders').doc(client.uid).collection('orders').doc(orderId);
        final vendorOrderRef = _firestore.collection('vendor_orders').doc(product.vendorId).collection('orders').doc(orderId);
        transaction.set(orderRef,orderData);
        transaction.set(clientOrderRef,orderData);
        transaction.set(vendorOrderRef,orderData);
        transaction.update(productRef, {
          'quantity': currentStock - quantity,
        });
      });

    } catch (e) {
      throw Exception(e.toString().replaceAll("Exception: ", ""));
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
  Future<void> removeFromCart({
    required String clientId,
    required String productId,
  }) async {
    try {
      await _firestore
          .collection('carts')
          .doc(clientId)
          .collection('items')
          .doc(productId)
          .delete();
    } catch (e) {
      throw Exception("Failed to remove from cart: $e");
    }
  }
  Future<bool> isProductInCart({
    required String clientId,
    required String productId,
  }) async {
    try {
      final doc = await _firestore
          .collection('carts')
          .doc(clientId)
          .collection('items')
          .doc(productId)
          .get();
      return doc.exists;
    } catch (e) {
      return false;
    }
  }

}
