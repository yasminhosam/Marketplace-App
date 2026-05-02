import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:marketplace_app/core/services/category_service.dart';
import 'package:marketplace_app/core/services/product_service.dart';
import 'package:marketplace_app/core/services/image_service.dart';
import 'package:marketplace_app/features/add_product/cubit/add_product_cubit.dart';
import 'package:marketplace_app/features/add_product/ui/add_product_screen.dart';
import 'package:marketplace_app/features/vendor_home/home_ui/vendor_profile_screen.dart';
import 'package:marketplace_app/features/vendor_product/ui/vendor_products_screen.dart';
import 'package:marketplace_app/features/vendor_orders/vendor_orders_screen.dart';
import '../cubit/vendor_cubit.dart';

class VendorHome extends StatefulWidget {
  const VendorHome({super.key});

  @override
  State<VendorHome> createState() => _VendorHomeState();
}

class _VendorHomeState extends State<VendorHome> {
  int _currentIndex = 0;

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<VendorCubit, VendorState>(
      builder: (context, state) {
        if (state is VendorLoading) {
          return const Scaffold(
            backgroundColor: Color(0xff101622),
            body: Center(child: CircularProgressIndicator(color: Color(0xff135EF3))),
          );
        }

        if (state is VendorLoaded) {
          final user = state.user;
          final stats = state.stats;
          final List<Widget> pages = [
            DashboardView(userName: user.name, stats: stats),
            const VendorProductsScreen(),
            const VendorOrdersScreen(),
            VendorProfileScreen(user: user),
          ];

          return Scaffold(
            backgroundColor: const Color(0xff101622),
            body: IndexedStack(index: _currentIndex, children: pages),

            floatingActionButton: FloatingActionButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (c) => BlocProvider(
                      create: (context) => AddProductCubit(
                        ProductService(),
                        CloudinaryService(),
                        CategoryService(),
                      ),
                      child: const AddProductScreen(),
                    ),
                  ),
                );
              },
              backgroundColor: const Color(0xff135BEC),
              shape: const CircleBorder(),
              child: const Icon(Icons.add, size: 35, color: Colors.white),
            ),
            floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,

            bottomNavigationBar: BottomAppBar(
              shape: const CircularNotchedRectangle(),
              notchMargin: 8.0,
              color: const Color(0xff0F1628),
              child: BottomNavigationBar(
                currentIndex: _currentIndex,
                onTap: (index) => setState(() => _currentIndex = index),
                type: BottomNavigationBarType.fixed,
                backgroundColor: Colors.transparent,
                elevation: 0,
                selectedItemColor: const Color(0xff135EF3),
                unselectedItemColor: const Color(0xff687484),
                selectedFontSize: 12,
                unselectedFontSize: 12,
                items: const [
                  BottomNavigationBarItem(icon: Icon(FontAwesomeIcons.chartLine, size: 20), label: "Dash"),
                  BottomNavigationBarItem(icon: Icon(FontAwesomeIcons.box, size: 20), label: "Products"),
                  BottomNavigationBarItem(icon: Icon(FontAwesomeIcons.cartShopping, size: 20), label: "Orders"),
                  BottomNavigationBarItem(icon: Icon(FontAwesomeIcons.user, size: 20), label: "Profile"),
                ],
              ),
            ),
          );
        }

        if (state is VendorError) {
          return Scaffold(body: Center(child: Text(state.message, style: const TextStyle(color: Colors.white))));
        }

        return const SizedBox();
      },
    );
  }
}

class DashboardView extends StatelessWidget {
  final String userName;
  final dynamic stats;

  const DashboardView({super.key, required this.userName, required this.stats});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.transparent,
      appBar: AppBar(
        backgroundColor: const Color(0xff101622),
        elevation: 0,
        title: Row(
          children: [
            Container(
              height: 40, width: 40,
              decoration: BoxDecoration(borderRadius: BorderRadius.circular(999), color: const Color(0xff101D36)),
              child: const Icon(FontAwesomeIcons.store, color: Color(0xff135EF3), size: 18),
            ),
            const SizedBox(width: 16),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text("Seller Hub", style: GoogleFonts.poppins(color: const Color(0xffF5F9FD), fontWeight: FontWeight.w600, fontSize: 16)),
                Text("Welcome Back, $userName", style: GoogleFonts.poppins(color: const Color(0xff687484), fontSize: 13)),
              ],
            ),
          ],
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            GridView.count(
              crossAxisCount: 2,
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              mainAxisSpacing: 12,
              crossAxisSpacing: 12,
              childAspectRatio: 1.3,
              children: [
                StatCard(
                  title: "Total Products",
                  value: stats.totalProducts.toString(),
                  icon: FontAwesomeIcons.box,
                  current: stats.totalProducts.toDouble(),
                  previous: stats.lastMonthProducts.toDouble(),
                ),
                StatCard(
                  title: "Total Orders",
                  value: stats.totalOrders.toString(),
                  icon: FontAwesomeIcons.cartShopping,
                  current: stats.totalOrders.toDouble(),
                  previous: stats.lastMonthOrdersCount.toDouble(),
                ),
                StatCard(
                  title: "Total Sales",
                  value: "\$${stats.totalSales.toStringAsFixed(1)}",
                  icon: FontAwesomeIcons.dollarSign,
                  current: stats.currentMonthSales,
                  previous: stats.lastMonthSales,
                ),
              ],
            ),
            const SizedBox(height: 24),
            Text("Performance Overview", style: GoogleFonts.poppins(color: Colors.white, fontSize: 17, fontWeight: FontWeight.w700)),
            const SizedBox(height: 16),
            CustomStatChartCard(
              title: "Inventory Growth",
              amount: "+${stats.totalProducts}",
              spots: stats.inventoryDailySpots,
            ),
            const SizedBox(height: 20),
            CustomStatChartCard(
              title: "Revenue Stream",
              amount: "\$${stats.currentMonthSales.toStringAsFixed(1)}",
              spots: stats.revenueDailySpots,
            ),
            const SizedBox(height: 100),
          ],
        ),
      ),
    );
  }
}
class StatCard extends StatelessWidget {
  final String title, value;
  final IconData icon;
  final double current, previous;

  const StatCard({super.key, required this.title, required this.value, required this.icon, required this.current, required this.previous});

  @override
  Widget build(BuildContext context) {
    double percent = (previous > 0) ? ((current - previous) / previous) * 100 : (current > 0 ? 100.0 : 0.0);
    bool isPos = percent >= 0;
    Color trendColor = isPos ? const Color(0xff10b981) : Colors.redAccent;

    return Card(
      elevation: 0,
      color: const Color(0xff101D36),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(title, style: const TextStyle(fontSize: 11, color: Color(0xff9cabc1))),
                Icon(icon, size: 12, color: const Color(0xff135EF3)),
              ],
            ),
            const SizedBox(height: 4),
            FittedBox(
              fit: BoxFit.scaleDown,
              child: Text(value, style: GoogleFonts.poppins(fontWeight: FontWeight.w600, fontSize: 20, color: Colors.white)),
            ),
            const SizedBox(height: 4),
            Row(
              children: [
                Icon(isPos ? FontAwesomeIcons.arrowTrendUp : FontAwesomeIcons.arrowTrendDown, color: trendColor, size: 10),
                const SizedBox(width: 4),
                Text("${isPos ? '+' : ''}${percent.toStringAsFixed(1)}%", style: TextStyle(color: trendColor, fontWeight: FontWeight.w500, fontSize: 10)),
              ],
            ),
          ],
        ),
      ),
    );
  }
}


class CustomStatChartCard extends StatelessWidget {
  final String title, amount;
  final List<FlSpot> spots;

  const CustomStatChartCard({super.key, required this.title, required this.amount, required this.spots});

  @override
  Widget build(BuildContext context) {
    return Card(
      color: const Color(0xff101D36),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(25)),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(title, style: GoogleFonts.poppins(color: const Color(0xff768294), fontSize: 14)),
            const SizedBox(height: 8),
            Text(amount, style: GoogleFonts.poppins(fontWeight: FontWeight.w600, fontSize: 24, color: Colors.white)),
            const SizedBox(height: 20),
            SizedBox(
              height: 150,
              child: LineChart(
                LineChartData(
                  lineTouchData: LineTouchData(
                    handleBuiltInTouches: true,
                    touchTooltipData: LineTouchTooltipData(
                      getTooltipColor: (spot) => const Color(0xff1A2535),
                      getTooltipItems: (touchedSpots) => touchedSpots.map((s) => LineTooltipItem(
                        s.y.toStringAsFixed(1),
                        const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
                      )).toList(),
                    ),
                  ),
                  gridData: const FlGridData(show: false),
                  borderData: FlBorderData(show: false),
                  minX: 0, maxX: 6, minY: 0,
                  titlesData: FlTitlesData(
                    topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                    rightTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                    leftTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                    bottomTitles: AxisTitles(
                      sideTitles: SideTitles(
                        showTitles: true,
                        getTitlesWidget: (val, meta) {
                          const days = ['SAT', 'SUN', 'MON', 'TUE', 'WED', 'THU', 'FRI'];
                          return (val >= 0 && val < 7)
                              ? Padding(
                            padding: const EdgeInsets.only(top: 8.0),
                            child: Text(days[val.toInt()], style: const TextStyle(color: Colors.white30, fontSize: 10)),
                          )
                              : const SizedBox();
                        },
                      ),
                    ),
                  ),
                  lineBarsData: [
                    LineChartBarData(
                      spots: spots,
                      isCurved: false,
                      color: const Color(0xff1255db),
                      barWidth: 3,
                      dotData: const FlDotData(show: true),
                      belowBarData: BarAreaData(show: true, color: const Color(0xff1255db).withOpacity(0.1)),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}