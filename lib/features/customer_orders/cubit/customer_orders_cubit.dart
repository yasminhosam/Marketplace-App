import 'dart:async';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:marketplace_app/core/models/order_model.dart';
import 'package:marketplace_app/core/services/cart_service.dart';
import 'customer_orders_state.dart';

class CustomerOrdersCubit
    extends Cubit<CustomerOrdersState> {
  CustomerOrdersCubit()
    : super(CustomerOrdersInitial());

  StreamSubscription? _ordersSub;

  void fetchClientOrders(
    String clientId,
  ) {
    emit(CustomerOrdersLoading());

    _ordersSub?.cancel();
    _ordersSub = FirebaseFirestore
        .instance
        .collection('client_orders')
        .doc(clientId)
    .collection('orders')
        .snapshots()
        .listen(
          (snapshot) {
            final orders = snapshot.docs
                .map((doc) {
                  return OrderModel.fromMap(
                    doc.data(),
                    doc.id,
                  );
                })
                .toList();
            emit(
              CustomerOrdersLoaded(
                orders,
              ),
            );
          },
          onError: (e) {
            emit(
              CustomerOrdersError(
                e.toString(),
              ),
            );
          },
        );
  }

  Future<void> deleteOrder(String orderId) async {
    final currentState = state;
    if (currentState is CustomerOrdersLoaded) {
      try {
        final order = currentState.orders.firstWhere((o) => o.id == orderId);
        await CartService().deleteOrder(
          orderId: orderId,
          clientId: order.clientId,
          vendorId: order.vendorId,
        );
      } catch (e) {
        emit(CustomerOrdersError(e.toString()));
      }
    }
  }

  @override
  Future<void> close() {
    _ordersSub?.cancel();
    return super.close();
  }
}
