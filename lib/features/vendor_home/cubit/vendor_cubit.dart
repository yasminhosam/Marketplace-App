import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:fl_chart/fl_chart.dart';
import '../../../../core/models/user_model.dart';
import '../../../../core/models/vendor_model.dart';

part 'vendor_state.dart';

class VendorCubit extends Cubit<VendorState> {
  VendorCubit() : super(VendorInitial());

  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  void loadVendorHome() {
    emit(VendorLoading());
    final user = _auth.currentUser;
    if (user == null) return;

    _firestore.collection('users').doc(user.uid).snapshots().listen((userSnap) async {
      if (!userSnap.exists) return;
      final userModel = UserModel.fromMap(userSnap.data()!);
      try {
        final stats = await _calculateAllStats(user.uid);
        if (!isClosed) emit(VendorLoaded(user: userModel, stats: stats));
      } catch (e) {
        if (!isClosed) emit(VendorError(e.toString()));
      }
    });
  }

  Future<VendorStatsModel> _calculateAllStats(String vendorId) async {
    final now = DateTime.now();
    final firstDayCurrent = DateTime(now.year, now.month, 1);
    final firstDayLast = DateTime(now.year, now.month - 1, 1);

    final allOrdersQuery = await _firestore.collection('orders').where('vendorId', isEqualTo: vendorId).get();
    final allProductsQuery = await _firestore.collection('products').where('vendorId', isEqualTo: vendorId).get();

    final currentOrders = allOrdersQuery.docs.where((d) => (d['createdAt'] as Timestamp).toDate().isAfter(firstDayCurrent)).toList();
    final lastMonthOrders = allOrdersQuery.docs.where((d) {
      final date = (d['createdAt'] as Timestamp).toDate();
      return date.isAfter(firstDayLast) && date.isBefore(firstDayCurrent);
    }).toList();

    double sumSales(List<QueryDocumentSnapshot> docs) => docs.fold(0.0, (acc, d) => acc + (d['totalPrice'] ?? 0.0).toDouble());

    return VendorStatsModel.fromCalculatedData(
      totalSales: sumSales(allOrdersQuery.docs),
      currentMonthSales: sumSales(currentOrders),
      lastMonthSales: sumSales(lastMonthOrders),
      totalProducts: allProductsQuery.docs.length,
      lastMonthProducts: allProductsQuery.docs.where((d) => (d['createdAt'] as Timestamp).toDate().isBefore(firstDayCurrent)).length,
      revenueSpots: _generateDailySpots(currentOrders),
      inventorySpots: _generateDailySpots(allProductsQuery.docs),
    );
  }

  List<FlSpot> _generateDailySpots(List<QueryDocumentSnapshot> docs) {
    if (docs.isEmpty) return [const FlSpot(0, 0), const FlSpot(6, 0)];

    return [const FlSpot(0, 2), const FlSpot(2, 5), const FlSpot(4, 3), const FlSpot(6, 8)];
  }
}