import 'package:fl_chart/fl_chart.dart';

class VendorStatsModel {
  final double totalSales;
  final int totalProducts;
  final double currentMonthSales;
  final double lastMonthSales;
  final int lastMonthProducts;
  final List<FlSpot> revenueDailySpots;
  final List<FlSpot> inventoryDailySpots;

  VendorStatsModel({
    required this.totalSales,
    required this.totalProducts,
    required this.currentMonthSales,
    required this.lastMonthSales,
    required this.lastMonthProducts,
    required this.revenueDailySpots,
    required this.inventoryDailySpots,
  });

  factory VendorStatsModel.fromCalculatedData({
    required double totalSales,
    required double currentMonthSales,
    required double lastMonthSales,
    required int totalProducts,
    required int lastMonthProducts,
    required List<FlSpot> revenueSpots,
    required List<FlSpot> inventorySpots,
  }) {
    return VendorStatsModel(
      totalSales: totalSales,
      totalProducts: totalProducts,
      currentMonthSales: currentMonthSales,
      lastMonthSales: lastMonthSales,
      lastMonthProducts: lastMonthProducts,
      revenueDailySpots: revenueSpots,
      inventoryDailySpots: inventorySpots,
    );
  }
}