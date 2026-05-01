import 'dart:async';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:marketplace_app/core/models/order_model.dart';
import 'package:marketplace_app/core/services/cart_service.dart';
import 'vendor_orders_state.dart';

class VendorOrdersCubit extends Cubit<VendorOrdersState> {
  VendorOrdersCubit() : super(VendorOrdersInitial());
  
  StreamSubscription? _ordersSub;

  void fetchVendorOrders(String vendorId) {
    emit(VendorOrdersLoading());

    _ordersSub?.cancel();
    _ordersSub = FirebaseFirestore.instance
        .collection('orders')
        .where('vendorId', isEqualTo: vendorId)
        .snapshots()
        .listen((snapshot) {
      final orders = snapshot.docs.map((doc) {
        return OrderModel.fromMap(doc.data(), doc.id);
      }).toList();
      emit(VendorOrdersLoaded(orders));
    }, onError: (e) {
      emit(VendorOrdersError(e.toString()));
    });
  }

  Future<void> deleteOrder(String orderId) async {
    final currentState = state;
    if (currentState is VendorOrdersLoaded) {
      try {
        final order = currentState.orders.firstWhere((o) => o.id == orderId);
        await CartService().deleteOrder(
          orderId: orderId,
          clientId: order.clientId,
          vendorId: order.vendorId,
        );
      } catch (e) {
        emit(VendorOrdersError(e.toString()));
      }
    }
  }

  @override
  Future<void> close() {
    _ordersSub?.cancel();
    return super.close();
  }
}
