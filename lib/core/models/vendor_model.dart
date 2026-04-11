import 'package:fl_chart/fl_chart.dart';

class VendorStatsModel {
  final double totalSales;
  final int totalProducts;
  final int totalOrders;
  final double currentMonthSales;
  final double lastMonthSales;
  final int lastMonthProducts;
  final int lastMonthOrdersCount;
  final List<FlSpot> revenueDailySpots;
  final List<FlSpot> inventoryDailySpots;

  VendorStatsModel({
    required this.totalSales,
    required this.totalProducts,
    required this.totalOrders,
    required this.currentMonthSales,
    required this.lastMonthSales,
    required this.lastMonthProducts,
    required this.lastMonthOrdersCount,
    required this.revenueDailySpots,
    required this.inventoryDailySpots,
  });

  factory VendorStatsModel.fromCalculatedData({
    required double totalSales,
    required double currentMonthSales,
    required double lastMonthSales,
    required int totalProducts,
    required int lastMonthProducts,
    required int totalOrders,
    required int lastMonthOrdersCount,
    required List<FlSpot> revenueSpots,
    required List<FlSpot> inventorySpots,
  }) {
    return VendorStatsModel(
      totalSales: totalSales,
      totalProducts: totalProducts,
      totalOrders: totalOrders,
      currentMonthSales: currentMonthSales,
      lastMonthSales: lastMonthSales,
      lastMonthProducts: lastMonthProducts,
      lastMonthOrdersCount: lastMonthOrdersCount,
      revenueDailySpots: revenueSpots,
      inventoryDailySpots: inventorySpots,
    );
  }
}
