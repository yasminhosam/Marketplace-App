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
    if (user == null) return;

    _cancelSubs();

    _userSub = _firestore.collection('users').doc(user.uid).snapshots().listen((userSnap) {
      if (!userSnap.exists) return;
      _currentUser = UserModel.fromMap(userSnap.data()!);
      _updateStatsIfReady();
    });

    _productsSub = _firestore.collection('products').where('vendorId', isEqualTo: user.uid).snapshots().listen((snap) {
      _lastProducts = snap.docs;
      _updateStatsIfReady();
    });

    _ordersSub = _firestore.collection('orders').where('vendorId', isEqualTo: user.uid).snapshots().listen((snap) {
      _lastOrders = snap.docs;
      _updateStatsIfReady();
    });
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

    double sumSales(List<QueryDocumentSnapshot> docs) {
      return docs.fold(0.0, (acc, d) {
        final data = d.data() as Map<String, dynamic>;
        return acc + (data['totalAmount'] ?? 0.0).toDouble();
      });
    }

    final currentMonthOrders = orders.where((d) {
      final data = d.data() as Map<String, dynamic>;
      final date = data['orderDate'] != null ? DateTime.parse(data['orderDate']) : now;
      return date.isAfter(firstDayCurrent);
    }).toList();

    final lastMonthOrders = orders.where((d) {
      final data = d.data() as Map<String, dynamic>;
      final date = data['orderDate'] != null ? DateTime.parse(data['orderDate']) : now;
      return date.isAfter(firstDayLast) && date.isBefore(firstDayCurrent);
    }).toList();

    return VendorStatsModel.fromCalculatedData(
      totalSales: sumSales(orders),
      currentMonthSales: sumSales(currentMonthOrders),
      lastMonthSales: sumSales(lastMonthOrders),
      totalProducts: products.length,
      lastMonthProducts: products.where((d) {
        final data = d.data() as Map<String, dynamic>;
        final date = (data['createdAt'] as Timestamp?)?.toDate() ?? now;
        return date.isBefore(firstDayCurrent);
      }).length,
      totalOrders: orders.length,
      lastMonthOrdersCount: lastMonthOrders.length,
      revenueSpots: _generateDailySpots(currentMonthOrders, isRevenue: true),
      inventorySpots: _generateDailySpots(products, isRevenue: false),
    );
  }

  List<FlSpot> _generateDailySpots(List<QueryDocumentSnapshot> docs, {required bool isRevenue}) {
    Map<int, double> dailyValues = {for (var i = 0; i < 7; i++) i: 0.0};
    final now = DateTime.now();

    for (var doc in docs) {
      final data = doc.data() as Map<String, dynamic>;
      DateTime? date;
      if (isRevenue) {
        date = data['orderDate'] != null ? DateTime.parse(data['orderDate']) : null;
      } else {
        date = (data['createdAt'] as Timestamp?)?.toDate();
      }

      if (date == null) continue;
      int dayIndex = (date.weekday + 1) % 7; // SAT = 0
      double val = isRevenue ? (data['totalAmount'] ?? 0.0).toDouble() : 1.0;
      dailyValues[dayIndex] = (dailyValues[dayIndex] ?? 0.0) + val;
    }
    return dailyValues.entries.map((e) => FlSpot(e.key.toDouble(), e.value)).toList();
  }

  void _cancelSubs() { _userSub?.cancel(); _productsSub?.cancel(); _ordersSub?.cancel(); }
}