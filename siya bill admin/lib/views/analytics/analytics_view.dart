import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:fl_chart/fl_chart.dart';
import '../../core/theme.dart';
import '../../models/bill.dart';
import '../../models/restaurant_profile.dart';
import '../../providers/data_provider.dart';

class AnalyticsView extends ConsumerWidget {
  const AnalyticsView({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final period = ref.watch(analyticsPeriodProvider);
    final billsVal = ref.watch(billsProvider);
    final outletsVal = ref.watch(outletsProvider);

    return Scaffold(
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('Ecosystem Analytics', style: Theme.of(context).textTheme.headlineMedium),
                      const SizedBox(height: 8),
                      const Text(
                        'Financial summaries, transaction counts, and store checkout leaderboards.',
                        style: TextStyle(color: AppTheme.textSecondary),
                      ),
                    ],
                  ),
                ),
                // Period Filters
                DropdownButton<String>(
                  value: period,
                  dropdownColor: AppTheme.darkSurface,
                  items: const [
                    DropdownMenuItem(value: 'Today', child: Text('Today')),
                    DropdownMenuItem(value: 'Last 30 Days', child: Text('Last 30 Days')),
                    DropdownMenuItem(value: 'All Time', child: Text('All Time')),
                  ],
                  onChanged: (val) {
                    if (val != null) {
                      ref.read(analyticsPeriodProvider.notifier).state = val;
                    }
                  },
                )
              ],
            ),
            const SizedBox(height: 24),

            billsVal.when(
              data: (bills) {
                // Filter bills based on selected period
                final now = DateTime.now();
                final filteredBills = bills.where((b) {
                  if (period == 'Today') {
                    return b.timestamp.year == now.year &&
                        b.timestamp.month == now.month &&
                        b.timestamp.day == now.day;
                  } else if (period == 'Last 30 Days') {
                    return now.difference(b.timestamp).inDays <= 30;
                  }
                  return true;
                }).toList();

                // Compute metrics totals
                final totalRevenue = filteredBills.fold<double>(0, (sum, b) => sum + b.totalAmount);
                final totalTransactions = filteredBills.length;
                final avgCheckoutCost = totalTransactions > 0 ? totalRevenue / totalTransactions : 0.0;

                // Group stats per appUserId
                final Map<String, double> outletRevenue = {};
                final Map<String, int> outletTransactions = {};

                for (var b in filteredBills) {
                  outletRevenue[b.appUserId] = (outletRevenue[b.appUserId] ?? 0.0) + b.totalAmount;
                  outletTransactions[b.appUserId] = (outletTransactions[b.appUserId] ?? 0) + 1;
                }

                return Column(
                  children: [
                    // Metrics Cards Row
                    LayoutBuilder(
                      builder: (context, constraints) {
                        int crossAxisCount = constraints.maxWidth > 900 ? 3 : 1;
                        return GridView.count(
                          shrinkWrap: true,
                          physics: const NeverScrollableScrollPhysics(),
                          crossAxisCount: crossAxisCount,
                          crossAxisSpacing: 16,
                          mainAxisSpacing: 16,
                          childAspectRatio: 2.8,
                          children: [
                            _buildMetricCard(
                              title: 'Ecosystem Revenue',
                              value: '₹${totalRevenue.toStringAsFixed(0)}',
                              icon: Icons.currency_rupee,
                              color: AppTheme.secondary,
                            ),
                            _buildMetricCard(
                              title: 'Total Transactions',
                              value: totalTransactions.toString(),
                              icon: Icons.receipt_long,
                              color: AppTheme.primary,
                            ),
                            _buildMetricCard(
                              title: 'Average Checkout',
                              value: '₹${avgCheckoutCost.toStringAsFixed(1)}',
                              icon: Icons.analytics_outlined,
                              color: AppTheme.accent,
                            ),
                          ],
                        );
                      },
                    ),
                    const SizedBox(height: 32),

                    // Trends Graph & Leaderboard split panel
                    LayoutBuilder(
                      builder: (context, constraints) {
                        if (constraints.maxWidth > 900) {
                          return Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Expanded(flex: 3, child: _buildTrendsChart(filteredBills)),
                              const SizedBox(width: 24),
                              Expanded(
                                flex: 2,
                                child: outletsVal.when(
                                  data: (outlets) => _buildLeaderboard(outlets, outletRevenue, outletTransactions),
                                  error: (_, __) => const Card(child: Center(child: Text('Error loading profiles'))),
                                  loading: () => const Center(child: CircularProgressIndicator()),
                                ),
                              ),
                            ],
                          );
                        }
                        return Column(
                          children: [
                            _buildTrendsChart(filteredBills),
                            const SizedBox(height: 24),
                            outletsVal.when(
                              data: (outlets) => _buildLeaderboard(outlets, outletRevenue, outletTransactions),
                              error: (_, __) => const Card(child: Center(child: Text('Error loading profiles'))),
                              loading: () => const Center(child: CircularProgressIndicator()),
                            ),
                          ],
                        );
                      },
                    )
                  ],
                );
              },
              error: (e, __) => Center(child: Text('Error: $e', style: const TextStyle(color: AppTheme.error))),
              loading: () => const Center(child: CircularProgressIndicator()),
            )
          ],
        ),
      ),
    );
  }

  Widget _buildMetricCard({
    required String title,
    required String value,
    required IconData icon,
    required Color color,
  }) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(color: color.withOpacity(0.12), borderRadius: BorderRadius.circular(8)),
              child: Icon(icon, color: color, size: 24),
            ),
            const SizedBox(width: 16),
            Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title, style: const TextStyle(fontSize: 12, color: AppTheme.textSecondary, fontWeight: FontWeight.w500)),
                const SizedBox(height: 4),
                Text(value, style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: AppTheme.textPrimary)),
              ],
            )
          ],
        ),
      ),
    );
  }

  Widget _buildTrendsChart(List<BillModel> bills) {
    // Group totals by weekday (Mon-Sun)
    final List<double> weekdayTotals = List.filled(7, 0.0);
    for (var b in bills) {
      final idx = b.timestamp.weekday - 1; // 0 to 6
      if (idx >= 0 && idx < 7) {
        weekdayTotals[idx] += b.totalAmount;
      }
    }

    final double maxVal = weekdayTotals.reduce((a, b) => a > b ? a : b);
    final double limit = maxVal > 0 ? maxVal * 1.2 : 100.0;

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('Ecosystem Sales Trends', style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold, color: AppTheme.textPrimary)),
            const SizedBox(height: 24),
            SizedBox(
              height: 220,
              child: BarChart(
                BarChartData(
                  alignment: BarChartAlignment.spaceAround,
                  maxY: limit,
                  barTouchData: BarTouchData(enabled: true),
                  titlesData: FlTitlesData(
                    show: true,
                    bottomTitles: AxisTitles(
                      sideTitles: SideTitles(
                        showTitles: true,
                        getTitlesWidget: (value, meta) {
                          const days = ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'];
                          if (value.toInt() >= 0 && value.toInt() < days.length) {
                            return Padding(
                              padding: const EdgeInsets.only(top: 8),
                              child: Text(days[value.toInt()], style: const TextStyle(fontSize: 10, color: AppTheme.textSecondary)),
                            );
                          }
                          return const Text('');
                        },
                      ),
                    ),
                    leftTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                    rightTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                    topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                  ),
                  gridData: const FlGridData(show: false),
                  borderData: FlBorderData(show: false),
                  barGroups: List.generate(7, (i) {
                    return BarChartGroupData(
                      x: i,
                      barRods: [
                        BarChartRodData(
                          toY: weekdayTotals[i],
                          color: AppTheme.primary,
                          width: 14,
                          borderRadius: BorderRadius.circular(4),
                        )
                      ],
                    );
                  }),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildLeaderboard(
    List<RestaurantProfileModel> outlets,
    Map<String, double> revenue,
    Map<String, int> transactions,
  ) {
    // Sort outlets based on cumulative revenue
    final ranked = List<RestaurantProfileModel>.from(outlets);
    ranked.sort((a, b) => (revenue[b.appUserId] ?? 0.0).compareTo(revenue[a.appUserId] ?? 0.0));

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('Outlet Sales Leaderboard', style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold, color: AppTheme.textPrimary)),
            const SizedBox(height: 16),
            ListView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: ranked.length > 5 ? 5 : ranked.length,
              itemBuilder: (context, index) {
                final store = ranked[index];
                final storeRev = revenue[store.appUserId] ?? 0.0;
                final storeTx = transactions[store.appUserId] ?? 0;
                
                return Padding(
                  padding: const EdgeInsets.symmetric(vertical: 8.0),
                  child: Row(
                    children: [
                      Container(
                        width: 24,
                        height: 24,
                        decoration: BoxDecoration(
                          color: index == 0 
                              ? AppTheme.accent 
                              : index == 1 
                                  ? AppTheme.textSecondary 
                                  : AppTheme.border,
                          shape: BoxShape.circle,
                        ),
                        child: Center(
                          child: Text(
                            '${index + 1}',
                            style: const TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: Colors.white),
                          ),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(store.restaurantName, style: const TextStyle(fontSize: 13, fontWeight: FontWeight.bold)),
                            Text('$storeTx checkouts', style: const TextStyle(fontSize: 11, color: AppTheme.textSecondary)),
                          ],
                        ),
                      ),
                      Text('₹${storeRev.toStringAsFixed(0)}', style: const TextStyle(fontSize: 13, fontWeight: FontWeight.bold, color: AppTheme.secondary)),
                    ],
                  ),
                );
              },
            )
          ],
        ),
      ),
    );
  }
}
extension on Color {
  Color withOpacity(double opacity) {
    return withValues(alpha: opacity);
  }
}
