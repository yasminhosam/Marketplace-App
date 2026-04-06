import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:google_fonts/google_fonts.dart';
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
            const ComingSoonScreen(featureName: "Products"),
            const ComingSoonScreen(featureName: "Orders"),
            const ComingSoonScreen(featureName: "Profile"),
          ];

          return Scaffold(
            backgroundColor: const Color(0xff101622),
            body: IndexedStack(index: _currentIndex, children: pages),
            floatingActionButton: FloatingActionButton(
              onPressed: () {
                Navigator.push(context, MaterialPageRoute(builder: (c) => const ComingSoonScreen(featureName: "Add Product")));
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
        bottom: const PreferredSize(
          preferredSize: Size.fromHeight(1),
          child: Divider(color: Color(0xff1B2535), thickness: 2),
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
                  current: stats.totalProducts.toDouble(),
                  previous: stats.lastMonthProducts.toDouble(),
                ),
                StatCard(
                  title: "Total Sales",
                  value: "\$${stats.totalSales.toStringAsFixed(1)}",
                  current: stats.currentMonthSales,
                  previous: stats.lastMonthSales,
                ),
              ],
            ),
            const SizedBox(height: 24),
            _buildSectionHeader(context, "Performance Overview"),
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

  Widget _buildSectionHeader(BuildContext context, String title) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(title, style: GoogleFonts.poppins(color: Colors.white, fontSize: 17, fontWeight: FontWeight.w700)),
        GestureDetector(
          onTap: () => Navigator.push(context, MaterialPageRoute(builder: (c) => const ComingSoonScreen(featureName: "Details"))),
          child: Text("Details", style: GoogleFonts.poppins(color: const Color(0xff135EF3), fontWeight: FontWeight.w600)),
        ),
      ],
    );
  }
}

class StatCard extends StatelessWidget {
  final String title, value;
  final double current, previous;

  const StatCard({super.key, required this.title, required this.value, required this.current, required this.previous});

  @override
  Widget build(BuildContext context) {
    double percent = (previous > 0) ? ((current - previous) / previous) * 100 : (current > 0 ? 100.0 : 0.0);
    bool isPos = percent >= 0;
    Color trendColor = isPos ? const Color(0xff10b981) : Colors.redAccent;

    return Card(
      elevation: 0.5,
      color: const Color(0xff101D36),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(25)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(title, style: const TextStyle(fontSize: 14, color: Color(0xff9cabc1))),
            const SizedBox(height: 4),
            FittedBox(
              fit: BoxFit.scaleDown,
              child: Text(value, style: GoogleFonts.poppins(fontWeight: FontWeight.w600, fontSize: 24, color: Colors.white)),
            ),
            const SizedBox(height: 4),
            Row(
              children: [
                Icon(isPos ? FontAwesomeIcons.arrowTrendUp : FontAwesomeIcons.arrowTrendDown, color: trendColor, size: 12),
                const SizedBox(width: 6),
                Text("${isPos ? '+' : ''}${percent.toStringAsFixed(1)}%", style: TextStyle(color: trendColor, fontWeight: FontWeight.w500, fontSize: 12)),
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

  String _calculateGrowth() {
    if (spots.length < 2) return "0.0%";
    double last = spots.last.y;
    double prev = spots[spots.length - 2].y;
    double diff = (prev > 0) ? ((last - prev) / prev) * 100 : (last > 0 ? 100.0 : 0.0);
    return "${diff >= 0 ? '+' : ''}${diff.toStringAsFixed(1)}%";
  }

  @override
  Widget build(BuildContext context) {
    String growth = _calculateGrowth();
    bool isPos = !growth.contains('-');

    return Card(
      color: const Color(0xff101D36),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(25)),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(title, style: GoogleFonts.poppins(color: const Color(0xff768294), fontSize: 15, fontWeight: FontWeight.w500)),
            const SizedBox(height: 8),
            Row(
              children: [
                Text(amount, style: GoogleFonts.poppins(fontWeight: FontWeight.w600, fontSize: 26, color: Colors.white)),
                const SizedBox(width: 12),
                Text("$growth Today", style: TextStyle(color: isPos ? const Color(0xff10b981) : Colors.redAccent, fontWeight: FontWeight.w500)),
              ],
            ),
            const SizedBox(height: 20),
            SizedBox(
              height: 140,
              child: LineChart(LineChartData(
                gridData: const FlGridData(show: false),
                borderData: FlBorderData(show: false),
                titlesData: FlTitlesData(
                  topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                  rightTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                  leftTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                  bottomTitles: AxisTitles(
                    sideTitles: SideTitles(
                      showTitles: true,
                      getTitlesWidget: (val, meta) {
                        const days = ['SAT', 'SUN', 'MON', 'TUE', 'WED', 'THU', 'FRI'];
                        return (val >= 0 && val < 7) ? Text(days[val.toInt()], style: const TextStyle(color: Colors.white30, fontSize: 10)) : const SizedBox();
                      },
                    ),
                  ),
                ),
                lineBarsData: [
                  LineChartBarData(
                    spots: spots,
                    isCurved: true,
                    color: const Color(0xff1255db),
                    barWidth: 3,
                    dotData: const FlDotData(show: false),
                    belowBarData: BarAreaData(show: true, color: const Color(0xff1255db).withValues(alpha: 0.15)),
                  ),
                ],
              )),
            ),
          ],
        ),
      ),
    );
  }
}

class ComingSoonScreen extends StatelessWidget {
  final String featureName;
  const ComingSoonScreen({super.key, required this.featureName});
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xff101622),
      appBar: AppBar(backgroundColor: Colors.transparent, iconTheme: const IconThemeData(color: Colors.white)),
      body: Center(child: Text("$featureName Coming Soon!", style: const TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.bold))),
    );
  }
}