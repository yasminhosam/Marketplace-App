import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../core/models/cart_model.dart';
import 'main_cart_state.dart';

class CartCubit extends Cubit<CartState> {
  CartCubit() : super(CartInitial());
  List<CartItemModel> _items = [];

  Future<void> fetchCart(String clientId) async {
    try {
      emit(CartLoading());

      final cartSnap = await FirebaseFirestore.instance
          .collection('carts')
          .doc(clientId)
          .collection('items')
          .get();

      List<CartItemModel> tempItems = [];

      for (var doc in cartSnap.docs) {
        var cartData = doc.data();
        String productId = cartData['productId'];

        final prodDoc = await FirebaseFirestore.instance.collection('products').doc(productId).get();
        final prodData = prodDoc.data() ?? {};

        final vendorDoc = await FirebaseFirestore.instance.collection('users').doc(prodData['vendorId']).get();
        final vendorName = vendorDoc.data()?['name'] ?? 'Unknown Vendor';

        tempItems.add(CartItemModel.fromMap(
          {
            ...cartData,
            'name': prodData['name'] ?? 'Unknown Product',
            'description': prodData['description'] ?? 'No description available',
            'imageUrl': prodData['imageUrl'] ?? '',
            'price': prodData['price'] ?? 0.0,
            'storeName': vendorName,
            'vendorId': prodData['vendorId'] ?? '',
          },
          documentId: doc.id,
        ));
      }

      _items = tempItems;
      emit(CartLoaded(List.from(_items)));
    } catch (e) {
      emit(CartError("Failed to load cart: $e"));
    }
  }

  Future<void> updateQuantity(String clientId, String productId, bool isIncrement) async {
    final index = _items.indexWhere((e) => e.productId == productId);
    if (index == -1) return;

    try {
      final currentItem = _items[index];

      final prodDoc = await FirebaseFirestore.instance.collection('products').doc(productId).get();
      final int stock = (prodDoc.data()?['quantity'] ?? 0) as int;

      if (isIncrement && currentItem.selectedQuantity >= stock) {
        emit(CartError("Stock limit reached! Only $stock available."));
        emit(CartLoaded(List.from(_items)));
        return;
      }

      int newQty = isIncrement ? currentItem.selectedQuantity + 1 : currentItem.selectedQuantity - 1;
      if (newQty < 1) return;

      await FirebaseFirestore.instance
          .collection('carts')
          .doc(clientId)
          .collection('items')
          .doc(currentItem.docId!)
          .update({'selectedQuantity': newQty});

      _items[index] = currentItem.copyWith(selectedQuantity: newQty);
      emit(CartLoaded(List.from(_items)));
    } catch (e) {
      emit(CartError("Update failed: $e"));
    }
  }

  Future<void> removeItem(String clientId, String productId) async {
    try {
      final item = _items.firstWhere((e) => e.productId == productId);
      await FirebaseFirestore.instance
          .collection('carts')
          .doc(clientId)
          .collection('items')
          .doc(item.docId!)
          .delete();

      fetchCart(clientId);
    } catch (e) {
      emit(CartError("Removal failed: $e"));
    }
  }

 Future<void> checkout({required String clientId, required String clientName}) async {
    if (_items.isEmpty) return;
    try {
      emit(CartLoading());
      final batch = FirebaseFirestore.instance.batch();

      final String orderId = FirebaseFirestore.instance.collection('orders').doc().id;
      final String orderDate = DateTime.now().toIso8601String();
      Map<String, List<CartItemModel>> groupedItems = {};
      for (var item in _items) {
        groupedItems.putIfAbsent(item.vendorId, () => []).add(item);
      }

      for (var vendorId in groupedItems.keys) {
        final vendorItems = groupedItems[vendorId]!;
        double vendorTotal = vendorItems.fold(0.0, (s, e) => s + (e.price * e.selectedQuantity));

        final vOrderRef = FirebaseFirestore.instance
            .collection('vendor_orders')
            .doc(vendorId)
            .collection('orders')
            .doc(orderId);

        batch.set(vOrderRef, {
          'orderId': orderId,
          'clientId': clientId,
          'clientName': clientName,
          'items': vendorItems.map((e) => e.toMap()).toList(),
          'totalAmount': vendorTotal,
          'status': 'processing',
          'orderDate': orderDate,
        });
      }

      final cOrderRef = FirebaseFirestore.instance
          .collection('client_orders')
          .doc(clientId)
          .collection('orders')
          .doc(orderId);

      batch.set(cOrderRef, {
        'orderId': orderId,
        'items': _items.map((e) => e.toMap()).toList(),
        'totalAmount': _items.fold(0.0, (s, e) => s + (e.price * e.selectedQuantity)) + 25,
        'status': 'processing',
        'orderDate': orderDate,
      });

      final gOrderRef = FirebaseFirestore.instance.collection('orders').doc(orderId);
      batch.set(gOrderRef, {
        'clientId': clientId,
        'clientName': clientName,
        'items': _items.map((e) => e.toMap()).toList(),
        'totalAmount': _items.fold(0.0, (s, e) => s + (e.price * e.selectedQuantity)) + 25,
        'status': 'processing',
        'orderDate': orderDate,
        'vendorId': _items.first.vendorId,
      });
      for (var item in _items) {
        batch.update(FirebaseFirestore.instance.collection('products').doc(item.productId),
            {'quantity': FieldValue.increment(-item.selectedQuantity)});

        batch.delete(FirebaseFirestore.instance.collection('carts').doc(clientId).collection('items').doc(item.docId!));
      }

      await batch.commit();
      _items.clear();
      emit(CartLoaded([]));

    } catch (e) {
      emit(CartError("Checkout failed: $e"));
      fetchCart(clientId);
    }
  }
}
