import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/theme.dart';
import '../../models/restaurant_profile.dart';
import '../../models/restaurant_settings.dart';
import '../../providers/data_provider.dart';

class NetworkView extends ConsumerStatefulWidget {
  const NetworkView({super.key});

  @override
  ConsumerState<NetworkView> createState() => _NetworkViewState();
}

class _NetworkViewState extends ConsumerState<NetworkView> {
  String _searchQuery = '';
  final _sequenceController = TextEditingController();

  @override
  void dispose() {
    _sequenceController.dispose();
    super.dispose();
  }

  void _showOverrideModal(RestaurantProfileModel profile) async {
    // Fetch current sequence number
    final settingsVal = ref.read(sequenceSettingsProvider);
    int currentSeq = 1;
    
    settingsVal.whenData((list) {
      final match = list.firstWhere(
        (x) => x.appUserId == profile.appUserId,
        orElse: () => RestaurantSettingsModel(id: 'global', appUserId: profile.appUserId, billSequence: 1, updatedAt: DateTime.now()),
      );
      currentSeq = match.billSequence;
    });

    _sequenceController.text = currentSeq.toString();

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          backgroundColor: AppTheme.darkSurface,
          title: Text('Override Bill Sequence — ${profile.restaurantName}'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Store Details:', style: Theme.of(context).textTheme.titleMedium),
              const SizedBox(height: 8),
              Text('• Code: ${profile.restaurantCode ?? "N/A"}', style: const TextStyle(fontSize: 13, color: AppTheme.textSecondary)),
              Text('• FSSAI: ${profile.fssaiNumber ?? "N/A"}', style: const TextStyle(fontSize: 13, color: AppTheme.textSecondary)),
              Text('• GST: ${profile.gstNumber ?? "N/A"}', style: const TextStyle(fontSize: 13, color: AppTheme.textSecondary)),
              Text('• UPI ID: ${profile.upiId ?? "N/A"}', style: const TextStyle(fontSize: 13, color: AppTheme.textSecondary)),
              Text('• Address: ${profile.address ?? "No address"}', style: const TextStyle(fontSize: 13, color: AppTheme.textSecondary)),
              const SizedBox(height: 24),
              const Text(
                'WARNING: Adjusting the bill checkout sequence directly updates the register cashier checkouts value. Only proceed if requested by outlet owners.',
                style: TextStyle(fontSize: 11, color: AppTheme.accent, fontWeight: FontWeight.bold, height: 1.4),
              ),
              const SizedBox(height: 20),
              TextField(
                controller: _sequenceController,
                keyboardType: TextInputType.number,
                decoration: const InputDecoration(
                  labelText: 'Active Bill Sequence Number',
                  border: OutlineInputBorder(),
                ),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Cancel'),
            ),
            ElevatedButton(
              onPressed: () => _saveOverride(profile.appUserId),
              child: const Text('Save Sequence Override'),
            ),
          ],
        );
      },
    );
  }

  void _saveOverride(String appUserId) async {
    final newSeq = int.tryParse(_sequenceController.text);
    if (newSeq != null) {
      Navigator.pop(context); // Close modal
      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (context) => const Center(child: CircularProgressIndicator()),
      );

      try {
        await ref.read(sequenceSettingsProvider.notifier).updateSequence(appUserId, newSeq);
        if (mounted) {
          Navigator.pop(context); // Dismiss loading
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Bill sequence overridden successfully!'), backgroundColor: AppTheme.secondary),
          );
        }
      } catch (e) {
        if (mounted) {
          Navigator.pop(context); // Dismiss loading
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Override failed: $e'), backgroundColor: AppTheme.error),
          );
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final outletsVal = ref.watch(outletsProvider);
    final settingsVal = ref.watch(sequenceSettingsProvider);

    return Scaffold(
      body: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Network Audits', style: Theme.of(context).textTheme.headlineMedium),
            const SizedBox(height: 8),
            const Text(
              'Audit outlet sequence configurations and monitor presence pings.',
              style: TextStyle(color: AppTheme.textSecondary),
            ),
            const SizedBox(height: 24),

            TextField(
              onChanged: (val) {
                setState(() {
                  _searchQuery = val.toLowerCase();
                });
              },
              decoration: const InputDecoration(
                hintText: 'Search by store name or code...',
                prefixIcon: Icon(Icons.search),
              ),
            ),
            const SizedBox(height: 24),

            Expanded(
              child: outletsVal.when(
                data: (outlets) {
                  final filtered = outlets.where((p) {
                    final nameMatch = p.restaurantName.toLowerCase().contains(_searchQuery);
                    final codeMatch = p.restaurantCode?.toLowerCase().contains(_searchQuery) ?? false;
                    return nameMatch || codeMatch;
                  }).toList();

                  if (filtered.isEmpty) {
                    return const Center(child: Text('No matching store online.', style: TextStyle(color: AppTheme.textSecondary)));
                  }

                  return ListView.builder(
                    itemCount: filtered.length,
                    itemBuilder: (context, index) {
                      final profile = filtered[index];
                      
                      // Check presence online status (ping within last 6 mins)
                      // For mock/development, we simulate online based on model
                      final isOnline = profile.id != 'res-grill-3'; 
                      
                      // Get corresponding sequence settings
                      int billSeq = 1;
                      settingsVal.whenData((list) {
                        final s = list.firstWhere(
                          (x) => x.appUserId == profile.appUserId,
                          orElse: () => RestaurantSettingsModel(id: 'global', appUserId: profile.appUserId, billSequence: 1, updatedAt: DateTime.now()),
                        );
                        billSeq = s.billSequence;
                      });

                      return Card(
                        margin: const EdgeInsets.only(bottom: 12),
                        color: AppTheme.darkCard,
                        child: ListTile(
                          contentPadding: const EdgeInsets.all(16),
                          leading: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Container(
                                width: 10,
                                height: 10,
                                decoration: BoxDecoration(
                                  color: isOnline ? AppTheme.secondary : AppTheme.textSecondary,
                                  shape: BoxShape.circle,
                                ),
                              ),
                              const SizedBox(width: 12),
                              Container(
                                padding: const EdgeInsets.all(8),
                                decoration: BoxDecoration(
                                  color: AppTheme.primary.withOpacity(0.12),
                                  borderRadius: BorderRadius.circular(6),
                                ),
                                child: const Icon(Icons.wifi_tethering, color: AppTheme.primary),
                              ),
                            ],
                          ),
                          title: Text(profile.restaurantName, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
                          subtitle: Padding(
                            padding: const EdgeInsets.only(top: 4.0),
                            child: Text(
                              'Code: ${profile.restaurantCode ?? "N/A"} • Seq No: $billSeq • Status: ${isOnline ? 'Online' : 'Offline'}',
                              style: const TextStyle(fontSize: 11, color: AppTheme.textSecondary),
                            ),
                          ),
                          trailing: ElevatedButton(
                            onPressed: () => _showOverrideModal(profile),
                            style: ElevatedButton.styleFrom(
                              minimumSize: const Size(100, 36),
                              padding: const EdgeInsets.symmetric(horizontal: 16),
                            ),
                            child: const Text('View & Override', style: TextStyle(fontSize: 12)),
                          ),
                        ),
                      );
                    },
                  );
                },
                error: (e, __) => Center(child: Text('Error: $e', style: const TextStyle(color: AppTheme.error))),
                loading: () => const Center(child: CircularProgressIndicator()),
              ),
            ),
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
