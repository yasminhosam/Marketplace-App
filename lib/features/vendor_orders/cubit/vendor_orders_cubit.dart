import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:marketplace_app/core/models/order_model.dart';
import 'vendor_orders_state.dart';

class VendorOrdersCubit extends Cubit<VendorOrdersState> {
  VendorOrdersCubit() : super(VendorOrdersInitial());

  // الدالة دي هتروح للفايربيز وتجيب الطلبات الخاصة بالـ Vendor ده بس
  Future<void> fetchVendorOrders(String vendorId) async {
    emit(VendorOrdersLoading()); // بنقول للشاشة تعرض Loading

    try {
      // بنروح للفايربيز ندور في الـ orders على الطلبات اللي الـ vendorId بتاعها بيساوي الـ ID بتاعنا
      final snapshot = await FirebaseFirestore.instance
          .collection('orders')
          .where('vendorId', isEqualTo: vendorId)
          .get();

      // بنحول الداتا اللي راجعة من الفايربيز لـ List of OrderModel
      final orders = snapshot.docs.map((doc) {
        return OrderModel.fromMap(doc.data(), doc.id);
      }).toList();

      emit(VendorOrdersLoaded(orders)); // بنبعت الطلبات للشاشة عشان تتعرض
    } catch (e) {
      emit(VendorOrdersError(e.toString())); // لو حصل مشكلة بنبعت الـ Error
    }
  }
}
