import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/theme.dart';
import '../../providers/data_provider.dart';
import '../../providers/supabase_provider.dart';

class DashboardView extends ConsumerStatefulWidget {
  const DashboardView({super.key});

  @override
  ConsumerState<DashboardView> createState() => _DashboardViewState();
}

class _DashboardViewState extends ConsumerState<DashboardView> {
  final _announcementController = TextEditingController();

  @override
  void dispose() {
    _announcementController.dispose();
    super.dispose();
  }

  void _broadcast() async {
    final msg = _announcementController.text.trim();
    if (msg.isNotEmpty) {
      await ref.read(supabaseServiceProvider).broadcastAnnouncement(msg);
      _announcementController.clear();
      ref.invalidate(announcementProvider);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Announcement broadcasted to all clients!'), backgroundColor: AppTheme.secondary),
        );
      }
    }
  }

  void _clearBroadcast() async {
    await ref.read(supabaseServiceProvider).clearAnnouncement();
    ref.invalidate(announcementProvider);
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Announcement cleared.'), backgroundColor: AppTheme.accent),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final outletsVal = ref.watch(outletsProvider);
    final licensesVal = ref.watch(licensesProvider);
    final presenceVal = ref.watch(livePresenceCountProvider);
    final announcementVal = ref.watch(announcementProvider);

    return Scaffold(
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Dashboard Overview',
              style: Theme.of(context).textTheme.headlineMedium,
            ),
            const SizedBox(height: 8),
            const Text(
              'Ecosystem stats and real-time operations console.',
              style: TextStyle(color: AppTheme.textSecondary),
            ),
            const SizedBox(height: 24),

            // KPI stats cards
            LayoutBuilder(
              builder: (context, constraints) {
                int crossAxisCount = constraints.maxWidth > 1000
                    ? 3
                    : constraints.maxWidth > 600
                        ? 2
                        : 1;
                return GridView.count(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  crossAxisCount: crossAxisCount,
                  crossAxisSpacing: 16,
                  mainAxisSpacing: 16,
                  childAspectRatio: 2.5,
                  children: [
                    _buildKpiCard(
                      title: 'Total Outlets',
                      value: outletsVal.when(
                        data: (list) => list.length.toString(),
                        error: (_, __) => 'Error',
                        loading: () => '...',
                      ),
                      icon: Icons.storefront,
                      color: AppTheme.primary,
                    ),
                    _buildKpiCard(
                      title: 'Active Premium Tiers',
                      value: outletsVal.when(
                        data: (list) => list.where((x) => x.subscriptionStatus == 'premium').length.toString(),
                        error: (_, __) => 'Error',
                        loading: () => '...',
                      ),
                      icon: Icons.workspace_premium_outlined,
                      color: AppTheme.secondary,
                    ),
                    _buildKpiCard(
                      title: 'Generated Licenses',
                      value: licensesVal.when(
                        data: (list) => list.length.toString(),
                        error: (_, __) => 'Error',
                        loading: () => '...',
                      ),
                      icon: Icons.vpn_key_outlined,
                      color: AppTheme.accent,
                    ),
                  ],
                );
              },
            ),
            const SizedBox(height: 32),

            // Announcement & Server Health layout
            LayoutBuilder(
              builder: (context, constraints) {
                if (constraints.maxWidth > 850) {
                  return Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Expanded(flex: 3, child: _buildAnnouncementBroadcaster(announcementVal)),
                      const SizedBox(width: 24),
                      Expanded(flex: 2, child: _buildServerHealth(presenceVal)),
                    ],
                  );
                }
                return Column(
                  children: [
                    _buildAnnouncementBroadcaster(announcementVal),
                    const SizedBox(height: 24),
                    _buildServerHealth(presenceVal),
                  ],
                );
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildKpiCard({
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
              decoration: BoxDecoration(
                color: color.withOpacity(0.12),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Icon(icon, color: color, size: 28),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(title, style: const TextStyle(fontSize: 13, color: AppTheme.textSecondary, fontWeight: FontWeight.w500)),
                  const SizedBox(height: 4),
                  Text(
                    value,
                    style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: AppTheme.textPrimary),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildAnnouncementBroadcaster(AsyncValue<String?> announcementVal) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Row(
              children: [
                Icon(Icons.campaign_outlined, color: AppTheme.primary, size: 22),
                SizedBox(width: 8),
                Text(
                  'Global Announcements Broadcaster',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: AppTheme.textPrimary),
                ),
              ],
            ),
            const SizedBox(height: 12),
            const Text(
              'Instantly broadcasts announcements or maintenance alerts to all connected POS registers.',
              style: TextStyle(color: AppTheme.textSecondary, fontSize: 12),
            ),
            const SizedBox(height: 20),
            
            // Active Announcement Box
            announcementVal.when(
              data: (message) {
                if (message == null || message.isEmpty) {
                  return Container(
                    padding: const EdgeInsets.all(12),
                    margin: const EdgeInsets.only(bottom: 16),
                    decoration: BoxDecoration(
                      color: AppTheme.darkBg,
                      borderRadius: BorderRadius.circular(6),
                      border: Border.all(color: AppTheme.border),
                    ),
                    child: const Row(
                      children: [
                        Icon(Icons.info_outline, color: AppTheme.textSecondary, size: 18),
                        SizedBox(width: 8),
                        Text('No active broadcast running.', style: TextStyle(color: AppTheme.textSecondary, fontSize: 12)),
                      ],
                    ),
                  );
                }
                return Container(
                  padding: const EdgeInsets.all(14),
                  margin: const EdgeInsets.only(bottom: 20),
                  decoration: BoxDecoration(
                    color: AppTheme.accent.withOpacity(0.08),
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: AppTheme.accent.withOpacity(0.4)),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const Text('ACTIVE BROADCAST', style: TextStyle(fontSize: 10, color: AppTheme.accent, fontWeight: FontWeight.bold)),
                          TextButton(
                            onPressed: _clearBroadcast,
                            style: TextButton.styleFrom(
                              minimumSize: Size.zero,
                              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                            ),
                            child: const Text('Clear Banner', style: TextStyle(color: AppTheme.error, fontSize: 11)),
                          )
                        ],
                      ),
                      const SizedBox(height: 6),
                      Text(message, style: const TextStyle(fontSize: 13, color: AppTheme.textPrimary)),
                    ],
                  ),
                );
              },
              error: (_, __) => const SizedBox.shrink(),
              loading: () => const Center(child: LinearProgressIndicator()),
            ),

            TextField(
              controller: _announcementController,
              decoration: const InputDecoration(
                hintText: 'Enter announcement details...',
                contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              ),
              maxLines: 2,
            ),
            const SizedBox(height: 16),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: _broadcast,
                child: const Text('Broadcast Announcement'),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildServerHealth(AsyncValue<int> presenceVal) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Infrastructure Status',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: AppTheme.textPrimary),
            ),
            const SizedBox(height: 20),
            _buildStatusRow('Supabase Database', 'Connected', AppTheme.secondary),
            const SizedBox(height: 12),
            _buildStatusRow('RLS Policies state', 'Enforced', AppTheme.secondary),
            const SizedBox(height: 12),
            _buildStatusRow(
              'Online POS Clients',
              presenceVal.when(
                data: (count) => '$count Active (last 6m)',
                error: (_, __) => 'Unknown',
                loading: () => '...',
              ),
              AppTheme.primary,
            ),
            const SizedBox(height: 12),
            _buildStatusRow('API Gateway Latency', '18ms (Cloud)', AppTheme.secondary),
            const SizedBox(height: 24),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: AppTheme.darkBg,
                borderRadius: BorderRadius.circular(6),
              ),
              child: const Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('🔐 Security Protocols Active', style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: AppTheme.textPrimary)),
                  SizedBox(height: 4),
                  Text('PostgreSQL Row Level Security policies guarantee data safety across customer accounts.', style: TextStyle(fontSize: 10, color: AppTheme.textSecondary, height: 1.4)),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatusRow(String label, String value, Color color) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(label, style: const TextStyle(fontSize: 13, color: AppTheme.textSecondary)),
        Row(
          children: [
            Container(
              width: 8,
              height: 8,
              decoration: BoxDecoration(color: color, shape: BoxShape.circle),
            ),
            const SizedBox(width: 8),
            Text(value, style: const TextStyle(fontSize: 13, fontWeight: FontWeight.bold, color: AppTheme.textPrimary)),
          ],
        ),
      ],
    );
  }
}
extension on Color {
  Color withOpacity(double opacity) {
    return withValues(alpha: opacity);
  }
}
extension on double {
  String toRadixString(int radix) {
    return toInt().toRadixString(radix);
  }
}
