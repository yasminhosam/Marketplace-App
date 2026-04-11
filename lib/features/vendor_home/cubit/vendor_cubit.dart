import 'dart:async';
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
  
  StreamSubscription? _userSub;
  StreamSubscription? _productsSub;
  StreamSubscription? _ordersSub;

  UserModel? _currentUser;
  List<QueryDocumentSnapshot>? _lastProducts;
  List<QueryDocumentSnapshot>? _lastOrders;

  void loadVendorHome() {
    emit(VendorLoading());
    final user = _auth.currentUser;
    if (user == null) {
      emit(VendorError("User not logged in"));
      return;
    }

    _cancelSubs();

    // Listen to User
    _userSub = _firestore.collection('users').doc(user.uid).snapshots().listen((userSnap) {
      if (!userSnap.exists) return;
      _currentUser = UserModel.fromMap(userSnap.data()!);
      _updateStatsIfReady();
    }, onError: (e) => emit(VendorError(e.toString())));

    // Listen to Products
    _productsSub = _firestore.collection('products').where('vendorId', isEqualTo: user.uid).snapshots().listen((snap) {
      _lastProducts = snap.docs;
      _updateStatsIfReady();
    }, onError: (e) => emit(VendorError(e.toString())));

    // Listen to Orders
    _ordersSub = _firestore.collection('orders').where('vendorId', isEqualTo: user.uid).snapshots().listen((snap) {
      _lastOrders = snap.docs;
      _updateStatsIfReady();
    }, onError: (e) => emit(VendorError(e.toString())));
  }

  void _updateStatsIfReady() {
    if (_currentUser != null && _lastProducts != null && _lastOrders != null) {
      final stats = _calculateStats(_lastProducts!, _lastOrders!);
      emit(VendorLoaded(user: _currentUser!, stats: stats));
    }
  }

  VendorStatsModel _calculateStats(List<QueryDocumentSnapshot> products, List<QueryDocumentSnapshot> orders) {
    final now = DateTime.now();
    final firstDayCurrent = DateTime(now.year, now.month, 1);
    final firstDayLast = DateTime(now.year, now.month - 1, 1);

    final currentOrders = orders.where((d) {
      final date = (d.data() as Map<String, dynamic>)['createdAt'] is Timestamp 
          ? ((d.data() as Map<String, dynamic>)['createdAt'] as Timestamp).toDate() 
          : now;
      return date.isAfter(firstDayCurrent);
    }).toList();

    final lastMonthOrders = orders.where((d) {
      final date = (d.data() as Map<String, dynamic>)['createdAt'] is Timestamp 
          ? ((d.data() as Map<String, dynamic>)['createdAt'] as Timestamp).toDate() 
          : now;
      return date.isAfter(firstDayLast) && date.isBefore(firstDayCurrent);
    }).toList();

    double sumSales(List<QueryDocumentSnapshot> docs) => 
        docs.fold(0.0, (acc, d) => acc + ((d.data() as Map<String, dynamic>)['totalPrice'] ?? 0.0).toDouble());

    return VendorStatsModel.fromCalculatedData(
      totalSales: sumSales(orders),
      currentMonthSales: sumSales(currentOrders),
      lastMonthSales: sumSales(lastMonthOrders),
      totalProducts: products.length,
      lastMonthProducts: products.where((d) {
        final date = (d.data() as Map<String, dynamic>)['createdAt'] is Timestamp 
            ? ((d.data() as Map<String, dynamic>)['createdAt'] as Timestamp).toDate() 
            : now;
        return date.isBefore(firstDayCurrent);
      }).length,
      totalOrders: orders.length,
      lastMonthOrdersCount: lastMonthOrders.length,
      revenueSpots: _generateDailySpots(currentOrders),
      inventorySpots: _generateDailySpots(products),
    );
  }

  List<FlSpot> _generateDailySpots(List<QueryDocumentSnapshot> docs) {
    if (docs.isEmpty) return [const FlSpot(0, 0), const FlSpot(6, 0)];
    return [const FlSpot(0, 2), const FlSpot(2, 5), const FlSpot(4, 3), const FlSpot(6, 8)];
  }

  void _cancelSubs() {
    _userSub?.cancel();
    _productsSub?.cancel();
    _ordersSub?.cancel();
  }

  @override
  Future<void> close() {
    _cancelSubs();
    return super.close();
  }
}
