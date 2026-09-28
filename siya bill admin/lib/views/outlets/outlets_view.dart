import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/theme.dart';
import '../../models/restaurant_profile.dart';
import '../../providers/data_provider.dart';

class OutletsView extends ConsumerStatefulWidget {
  const OutletsView({super.key});

  @override
  ConsumerState<OutletsView> createState() => _OutletsViewState();
}

class _OutletsViewState extends ConsumerState<OutletsView> {
  String _searchQuery = '';
  String _filterPlan = 'all';

  String _normalizePlanCode(String plan, String status) {
    if (status == 'expired') {
      return 'EXP';
    }
    final p = plan.toUpperCase().trim();
    if (p == 'FREE-TRIAL' || p == 'FREE' || p == 'EXP') {
      return 'EXP';
    }
    if (p == 'M01' || p == 'MONTHLY' || p == 'MONTHLY-PREMIUM') {
      return 'M01';
    }
    if (p == 'M06' || p == 'HALF-YEARLY' || p == 'HALF_YEARLY') {
      return 'M06';
    }
    if (p == 'Y01' || p == 'YEARLY' || p == 'YEARLY-PREMIUM') {
      return 'Y01';
    }
    if (p == 'LIF' || p == 'LIFETIME') {
      return 'LIF';
    }
    return 'EXP'; // Fallback
  }

  void _extendTrial(RestaurantProfileModel outlet, int days) async {
    try {
      await ref.read(outletsProvider.notifier).extendTrial(
        outletId: outlet.id,
        appUserId: outlet.appUserId,
        days: days,
        currentExpiry: outlet.subscriptionExpiry,
      );
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Subscription extended by $days days for ${outlet.restaurantName}.'), backgroundColor: AppTheme.secondary),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to extend trial: $e'), backgroundColor: AppTheme.error),
        );
      }
    }
  }

  void _suspend(RestaurantProfileModel outlet) async {
    try {
      await ref.read(outletsProvider.notifier).suspend(
        outletId: outlet.id,
        appUserId: outlet.appUserId,
      );
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Outlet suspended: ${outlet.restaurantName}'), backgroundColor: AppTheme.error),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to suspend: $e'), backgroundColor: AppTheme.error),
        );
      }
    }
  }

  void _changeTier(RestaurantProfileModel outlet, String plan) async {
    String status = 'premium';
    double expiry = DateTime.now().add(const Duration(days: 30)).millisecondsSinceEpoch.toDouble();

    if (plan == 'LIF') {
      expiry = DateTime.now().add(const Duration(days: 9999)).millisecondsSinceEpoch.toDouble();
    } else if (plan == 'M06') {
      expiry = DateTime.now().add(const Duration(days: 180)).millisecondsSinceEpoch.toDouble();
    } else if (plan == 'Y01') {
      expiry = DateTime.now().add(const Duration(days: 365)).millisecondsSinceEpoch.toDouble();
    } else if (plan == 'EXP') {
      status = 'expired';
      expiry = DateTime.now().subtract(const Duration(days: 1)).millisecondsSinceEpoch.toDouble();
    }

    try {
      await ref.read(outletsProvider.notifier).changeTier(
        outletId: outlet.id,
        appUserId: outlet.appUserId,
        status: status,
        planName: plan == 'EXP' ? 'free-trial' : plan,
        expiry: expiry,
      );
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Tier changed for ${outlet.restaurantName}'), backgroundColor: AppTheme.secondary),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to change tier: $e'), backgroundColor: AppTheme.error),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final outletsVal = ref.watch(outletsProvider);

    return Scaffold(
      body: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Outlets Directory', style: Theme.of(context).textTheme.headlineMedium),
            const SizedBox(height: 8),
            const Text(
              'Audit outlet trials, suspend database checkouts, or update subscription tiers.',
              style: TextStyle(color: AppTheme.textSecondary),
            ),
            const SizedBox(height: 24),

            // Search Bar & Filter
            Row(
              children: [
                Expanded(
                  child: TextField(
                    onChanged: (val) {
                      setState(() {
                        _searchQuery = val.toLowerCase();
                      });
                    },
                    decoration: const InputDecoration(
                      hintText: 'Search by name, phone, email, or code...',
                      prefixIcon: Icon(Icons.search),
                      contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                    ),
                  ),
                ),
                const SizedBox(width: 16),
                DropdownButtonHideUnderline(
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12),
                    decoration: BoxDecoration(
                      color: AppTheme.darkSurface,
                      border: Border.all(color: AppTheme.border),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: DropdownButton<String>(
                      value: _filterPlan,
                      dropdownColor: AppTheme.darkSurface,
                      items: const [
                        DropdownMenuItem(value: 'all', child: Text('All Plans')),
                        DropdownMenuItem(value: 'premium', child: Text('Premium Only')),
                        DropdownMenuItem(value: 'trial', child: Text('Trial Only')),
                        DropdownMenuItem(value: 'expired', child: Text('Expired Only')),
                        DropdownMenuItem(value: 'suspended', child: Text('Suspended Only')),
                      ],
                      onChanged: (val) {
                        if (val != null) {
                          setState(() {
                            _filterPlan = val;
                          });
                        }
                      },
                    ),
                  ),
                )
              ],
            ),
            const SizedBox(height: 24),

            // Outlets Table / List
            Expanded(
              child: outletsVal.when(
                data: (list) {
                  final filtered = list.where((item) {
                    final matchesSearch = item.restaurantName.toLowerCase().contains(_searchQuery) ||
                        (item.phone?.toLowerCase().contains(_searchQuery) ?? false) ||
                        (item.restaurantCode?.toLowerCase().contains(_searchQuery) ?? false);
                    final matchesFilter = _filterPlan == 'all' || item.subscriptionStatus == _filterPlan;
                    return matchesSearch && matchesFilter;
                  }).toList();

                  if (filtered.isEmpty) {
                    return const Center(child: Text('No outlets found.', style: TextStyle(color: AppTheme.textSecondary)));
                  }

                  return LayoutBuilder(
                    builder: (context, constraints) {
                      if (constraints.maxWidth > 950) {
                        return _buildOutletsTable(filtered);
                      }
                      return ListView.builder(
                        itemCount: filtered.length,
                        itemBuilder: (context, idx) => _buildOutletCard(filtered[idx]),
                      );
                    },
                  );
                },
                error: (e, __) => Center(child: Text('Error: $e', style: const TextStyle(color: AppTheme.error))),
                loading: () => const Center(child: CircularProgressIndicator()),
              ),
            )
          ],
        ),
      ),
    );
  }

  Widget _buildOutletsTable(List<RestaurantProfileModel> outlets) {
    return Card(
      child: SingleChildScrollView(
        scrollDirection: Axis.vertical,
        child: DataTable(
          headingRowColor: WidgetStateProperty.all(AppTheme.darkSurface),
          columns: const [
            DataColumn(label: Text('Outlet Info', style: TextStyle(fontWeight: FontWeight.bold))),
            DataColumn(label: Text('Compliance', style: TextStyle(fontWeight: FontWeight.bold))),
            DataColumn(label: Text('Active Plan', style: TextStyle(fontWeight: FontWeight.bold))),
            DataColumn(label: Text('Status & Expiry', style: TextStyle(fontWeight: FontWeight.bold))),
            DataColumn(label: Text('Manage Trial', style: TextStyle(fontWeight: FontWeight.bold))),
            DataColumn(label: Text('Action', style: TextStyle(fontWeight: FontWeight.bold))),
          ],
          rows: outlets.map((outlet) {
            final expDate = DateTime.fromMillisecondsSinceEpoch(outlet.subscriptionExpiry.toInt());
            
            return DataRow(
              cells: [
                DataCell(
                  Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(outlet.restaurantName, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13)),
                      Text(outlet.phone ?? 'No phone', style: const TextStyle(color: AppTheme.textSecondary, fontSize: 11)),
                    ],
                  ),
                ),
                DataCell(
                  Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('GST: ${outlet.gstNumber ?? 'N/A'}', style: const TextStyle(fontSize: 11)),
                      Text('FSSAI: ${outlet.fssaiNumber ?? 'N/A'}', style: const TextStyle(fontSize: 10, color: AppTheme.textSecondary)),
                    ],
                  ),
                ),
                DataCell(
                  DropdownButton<String>(
                    value: _normalizePlanCode(outlet.subscriptionPlan, outlet.subscriptionStatus),
                    dropdownColor: AppTheme.darkSurface,
                    style: const TextStyle(color: AppTheme.primary, fontSize: 12, fontWeight: FontWeight.bold),
                    items: const [
                      DropdownMenuItem(value: 'EXP', child: Text('EXP / Free')),
                      DropdownMenuItem(value: 'M01', child: Text('M01 (30d)')),
                      DropdownMenuItem(value: 'M06', child: Text('M06 (180d)')),
                      DropdownMenuItem(value: 'Y01', child: Text('Y01 (365d)')),
                      DropdownMenuItem(value: 'LIF', child: Text('LIF (Lifetime)')),
                    ],
                    onChanged: (val) {
                      if (val != null) {
                        _changeTier(outlet, val);
                      }
                    },
                  ),
                ),
                DataCell(
                  Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _buildStatusLabel(outlet.subscriptionStatus),
                      const SizedBox(height: 2),
                      Text(
                        'Exp: ${expDate.day}/${expDate.month}/${expDate.year}',
                        style: const TextStyle(fontSize: 10, color: AppTheme.textSecondary),
                      ),
                    ],
                  ),
                ),
                DataCell(
                  Row(
                    children: [
                      TextButton(
                        onPressed: () => _extendTrial(outlet, 3),
                        style: TextButton.styleFrom(minimumSize: const Size(44, 32), padding: EdgeInsets.zero),
                        child: const Text('+3d', style: TextStyle(fontSize: 11)),
                      ),
                      TextButton(
                        onPressed: () => _extendTrial(outlet, 7),
                        style: TextButton.styleFrom(minimumSize: const Size(44, 32), padding: EdgeInsets.zero),
                        child: const Text('+7d', style: TextStyle(fontSize: 11, color: AppTheme.secondary)),
                      ),
                    ],
                  ),
                ),
                DataCell(
                  outlet.subscriptionStatus == 'suspended'
                      ? const Text('SUSPENDED', style: TextStyle(color: AppTheme.error, fontSize: 11, fontWeight: FontWeight.bold))
                      : ElevatedButton(
                          onPressed: () => _suspend(outlet),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: AppTheme.error.withOpacity(0.12),
                            foregroundColor: AppTheme.error,
                            minimumSize: const Size(80, 32),
                            padding: const EdgeInsets.symmetric(horizontal: 12),
                          ),
                          child: const Text('Suspend', style: TextStyle(fontSize: 11)),
                        ),
                ),
              ],
            );
          }).toList(),
        ),
      ),
    );
  }

  Widget _buildOutletCard(RestaurantProfileModel outlet) {
    final expDate = DateTime.fromMillisecondsSinceEpoch(outlet.subscriptionExpiry.toInt());
    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(child: Text(outlet.restaurantName, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15))),
                _buildStatusLabel(outlet.subscriptionStatus),
              ],
            ),
            const SizedBox(height: 6),
            Text(outlet.address ?? 'No address', style: const TextStyle(color: AppTheme.textSecondary, fontSize: 12)),
            const Divider(),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text('FSSAI/GST:', style: TextStyle(color: AppTheme.textSecondary, fontSize: 12)),
                Text('${outlet.fssaiNumber ?? 'N/A'} / ${outlet.gstNumber ?? 'N/A'}', style: const TextStyle(fontSize: 12)),
              ],
            ),
            const SizedBox(height: 8),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text('Expiry Date:', style: TextStyle(color: AppTheme.textSecondary, fontSize: 12)),
                Text('${expDate.day}/${expDate.month}/${expDate.year}', style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold)),
              ],
            ),
            const SizedBox(height: 12),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    ElevatedButton(
                      onPressed: () => _extendTrial(outlet, 3),
                      style: ElevatedButton.styleFrom(minimumSize: const Size(54, 32), padding: const EdgeInsets.symmetric(horizontal: 8)),
                      child: const Text('+3 Days', style: TextStyle(fontSize: 11)),
                    ),
                    const SizedBox(width: 8),
                    ElevatedButton(
                      onPressed: () => _extendTrial(outlet, 7),
                      style: ElevatedButton.styleFrom(backgroundColor: AppTheme.secondary, minimumSize: const Size(54, 32), padding: const EdgeInsets.symmetric(horizontal: 8)),
                      child: const Text('+7 Days', style: TextStyle(fontSize: 11)),
                    ),
                  ],
                ),
                if (outlet.subscriptionStatus != 'suspended')
                  TextButton(
                    onPressed: () => _suspend(outlet),
                    style: TextButton.styleFrom(foregroundColor: AppTheme.error, minimumSize: const Size(54, 32)),
                    child: const Text('Suspend', style: TextStyle(fontSize: 11)),
                  ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatusLabel(String status) {
    Color badgeColor;
    switch (status) {
      case 'premium':
        badgeColor = AppTheme.secondary;
        break;
      case 'trial':
        badgeColor = AppTheme.primary;
        break;
      case 'suspended':
        badgeColor = AppTheme.error;
        break;
      default:
        badgeColor = AppTheme.accent;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: badgeColor.withOpacity(0.12),
        borderRadius: BorderRadius.circular(4),
      ),
      child: Text(
        status.toUpperCase(),
        style: TextStyle(color: badgeColor, fontSize: 10, fontWeight: FontWeight.bold),
      ),
    );
  }
}
extension on Color {
  Color withOpacity(double opacity) {
    return withValues(alpha: opacity);
  }
}
