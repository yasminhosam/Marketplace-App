import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:marketplace_app/core/models/order_model.dart';
import 'vendor_orders_state.dart';

class VendorOrdersCubit extends Cubit<VendorOrdersState> {
  VendorOrdersCubit() : super(VendorOrdersInitial());

  Future<void> fetchVendorOrders(String vendorId) async {
    emit(VendorOrdersLoading());

    try {
      final snapshot = await FirebaseFirestore.instance
          .collection('orders')
          .where('vendorId', isEqualTo: vendorId)
          .get();

      final orders = snapshot.docs.map((doc) {
        return OrderModel.fromMap(doc.data(), doc.id);
      }).toList();

      emit(VendorOrdersLoaded(orders));
    } catch (e) {
      emit(VendorOrdersError(e.toString()));
    }
  }
}
