import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/theme.dart';
import '../../models/violation.dart';
import '../../providers/data_provider.dart';
import '../../providers/supabase_provider.dart';

class ViolationsView extends ConsumerWidget {
  const ViolationsView({super.key});

  void _unblock(BuildContext context, WidgetRef ref, String userId) async {
    // Show confirmation dialog or immediate loading spinner
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => const Center(child: CircularProgressIndicator()),
    );

    try {
      await ref.read(supabaseServiceProvider).unblockUser(userId);
      if (context.mounted) {
        Navigator.pop(context); // Dismiss loading
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('User database insertion block lifted successfully.'),
            backgroundColor: AppTheme.secondary,
          ),
        );
      }
    } catch (e) {
      if (context.mounted) {
        Navigator.pop(context); // Dismiss loading
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to unblock: $e'),
            backgroundColor: AppTheme.error,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final violationsVal = ref.watch(violationsStreamProvider);

    return Scaffold(
      body: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Anti-Abuse & Rate Audits',
              style: Theme.of(context).textTheme.headlineMedium,
            ),
            const SizedBox(height: 8),
            const Text(
              'Audit active blocks on outlets exceeding the rate-limits (20 bills/minute). Lift blocks instantly via RPC commands.',
              style: TextStyle(color: AppTheme.textSecondary),
            ),
            const SizedBox(height: 24),

            Expanded(
              child: violationsVal.when(
                data: (violations) {
                  final activeBlocks = violations.where((v) => v.isCurrentlyBlocked).toList();
                  final historyBlocks = violations.where((v) => !v.isCurrentlyBlocked).toList();

                  if (violations.isEmpty) {
                    return const Center(
                      child: Text('No rate-limiting violations recorded in the database.', style: TextStyle(color: AppTheme.textSecondary)),
                    );
                  }

                  return ListView(
                    children: [
                      // Active Blocks Section
                      if (activeBlocks.isNotEmpty) ...[
                        Row(
                          children: [
                            Container(width: 8, height: 8, decoration: const BoxDecoration(color: AppTheme.error, shape: BoxShape.circle)),
                            const SizedBox(width: 8),
                            Text('Active Insertion Locks', style: Theme.of(context).textTheme.titleMedium?.copyWith(color: AppTheme.error)),
                          ],
                        ),
                        const SizedBox(height: 12),
                        ...activeBlocks.map((v) => _buildViolationCard(context, ref, v, true)),
                        const SizedBox(height: 32),
                      ],

                      // History Warnings Section
                      if (historyBlocks.isNotEmpty) ...[
                        Row(
                          children: [
                            Container(width: 8, height: 8, decoration: const BoxDecoration(color: AppTheme.accent, shape: BoxShape.circle)),
                            const SizedBox(width: 8),
                            Text('Warnings Log (Active Restored)', style: Theme.of(context).textTheme.titleMedium?.copyWith(color: AppTheme.accent)),
                          ],
                        ),
                        const SizedBox(height: 12),
                        ...historyBlocks.map((v) => _buildViolationCard(context, ref, v, false)),
                      ],
                    ],
                  );
                },
                error: (e, __) => Center(
                  child: Text('Error loading violations: $e', style: const TextStyle(color: AppTheme.error)),
                ),
                loading: () => const Center(child: CircularProgressIndicator()),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildViolationCard(BuildContext context, WidgetRef ref, ViolationModel v, bool isBlocked) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      color: AppTheme.darkCard,
      child: Padding(
        padding: const EdgeInsets.all(16.0),
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
                      SelectableText(
                        'User ID: ${v.userId}',
                        style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13, fontFamily: 'monospace'),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        'Warning Count: ${v.warningCount} • Date: ${v.warningDate}',
                        style: const TextStyle(color: AppTheme.textSecondary, fontSize: 11),
                      ),
                    ],
                  ),
                ),
                if (isBlocked)
                  ElevatedButton(
                    onPressed: () => _unblock(context, ref, v.userId),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppTheme.secondary,
                      minimumSize: const Size(100, 36),
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                    ),
                    child: const Row(
                      children: [
                        Icon(Icons.lock_open, size: 14),
                        SizedBox(width: 6),
                        Text('Lift Block', style: TextStyle(fontSize: 12)),
                      ],
                    ),
                  )
                else
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: AppTheme.secondary.withOpacity(0.12),
                      borderRadius: BorderRadius.circular(4),
                    ),
                    child: const Text(
                      'RESTORED',
                      style: TextStyle(fontSize: 10, color: AppTheme.secondary, fontWeight: FontWeight.bold),
                    ),
                  ),
              ],
            ),
            if (isBlocked && v.blockedReason != null) ...[
              const SizedBox(height: 12),
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: AppTheme.error.withOpacity(0.08),
                  borderRadius: BorderRadius.circular(6),
                  border: Border.all(color: AppTheme.error.withOpacity(0.2)),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text('Reason for Block:', style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: AppTheme.error)),
                    const SizedBox(height: 4),
                    Text(v.blockedReason!, style: const TextStyle(fontSize: 12, color: AppTheme.textPrimary)),
                    const SizedBox(height: 6),
                    Text(
                      'Locked until: ${v.blockedUntil?.day}/${v.blockedUntil?.month} at ${v.blockedUntil?.hour}:${v.blockedUntil?.minute.toString().padLeft(2, "0")}',
                      style: const TextStyle(fontSize: 10, color: AppTheme.textSecondary),
                    ),
                  ],
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
