import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/theme.dart';
import '../../providers/data_provider.dart';

class BackupsView extends ConsumerStatefulWidget {
  const BackupsView({super.key});

  @override
  ConsumerState<BackupsView> createState() => _BackupsViewState();
}

class _BackupsViewState extends ConsumerState<BackupsView> {
  final _restorePayloadController = TextEditingController();

  @override
  void dispose() {
    _restorePayloadController.dispose();
    super.dispose();
  }

  void _triggerBackup() async {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => const Center(child: CircularProgressIndicator()),
    );

    try {
      await ref.read(backupsProvider.notifier).triggerNewSnapshot();
      if (mounted) {
        Navigator.pop(context); // Close loader
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('JSON backup compiled and logged successfully!'), backgroundColor: AppTheme.secondary),
        );
      }
    } catch (e) {
      if (mounted) {
        Navigator.pop(context); // Close loader
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Backup compilation failed: $e'), backgroundColor: AppTheme.error),
        );
      }
    }
  }

  void _showRestoreDialog() {
    _restorePayloadController.clear();
    
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          backgroundColor: AppTheme.darkSurface,
          title: const Row(
            children: [
              Icon(Icons.warning_amber_outlined, color: AppTheme.error),
              SizedBox(width: 8),
              Text('Restore Database JSON'),
            ],
          ),
          content: SizedBox(
            width: 500,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'CAUTION: Performing database restoration executes cascading overwrites across all configuration tables. Existing active records will be overwritten.',
                  style: TextStyle(fontSize: 12, color: AppTheme.error, fontWeight: FontWeight.bold, height: 1.4),
                ),
                const SizedBox(height: 16),
                const Text(
                  'Paste the compiled backup JSON payload in the text area below:',
                  style: TextStyle(fontSize: 11, color: AppTheme.textSecondary),
                ),
                const SizedBox(height: 8),
                TextField(
                  controller: _restorePayloadController,
                  maxLines: 8,
                  decoration: const InputDecoration(
                    hintText: '{"licenses": [...], "restaurant_profile": [...]}',
                    border: OutlineInputBorder(),
                  ),
                  style: const TextStyle(fontSize: 11, fontFamily: 'monospace'),
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Cancel'),
            ),
            ElevatedButton(
              onPressed: () => _confirmRestore(),
              style: ElevatedButton.styleFrom(backgroundColor: AppTheme.error),
              child: const Text('Confirm Restore'),
            ),
          ],
        );
      },
    );
  }

  void _confirmRestore() async {
    final rawText = _restorePayloadController.text.trim();
    if (rawText.isEmpty) return;

    try {
      final jsonPayload = jsonDecode(rawText) as Map<String, dynamic>;
      
      Navigator.pop(context); // Close inputs dialog
      
      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (context) => const Center(child: CircularProgressIndicator()),
      );

      // Execute 3-Phase cascading restoration sequence compiler
      await ref.read(backupsProvider.notifier).restoreSnapshot(jsonPayload);
      
      if (mounted) {
        Navigator.pop(context); // Close loader
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('3-Phase sequential restoration completed successfully!'), backgroundColor: AppTheme.secondary),
        );
      }
    } catch (e) {
      if (mounted) {
        Navigator.pop(context); // Close loader
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Restoration failed: Invalid JSON or key constraints violation. details: $e'), backgroundColor: AppTheme.error),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final backupsVal = ref.watch(backupsProvider);

    return Scaffold(
      body: Padding(
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
                      Text('Database backups', style: Theme.of(context).textTheme.headlineMedium),
                      const SizedBox(height: 8),
                      const Text(
                        'Compile full ecosystem records backups or run 3-phase cascading restorations.',
                        style: TextStyle(color: AppTheme.textSecondary),
                      ),
                    ],
                  ),
                ),
                Row(
                  children: [
                    TextButton(
                      onPressed: _showRestoreDialog,
                      style: TextButton.styleFrom(foregroundColor: AppTheme.error),
                      child: const Row(
                        children: [
                          Icon(Icons.upload_file, size: 18),
                          SizedBox(width: 8),
                          Text('Upload & Restore'),
                        ],
                      ),
                    ),
                    const SizedBox(width: 12),
                    ElevatedButton(
                      onPressed: _triggerBackup,
                      child: const Row(
                        children: [
                          Icon(Icons.download, size: 18),
                          SizedBox(width: 8),
                          Text('Trigger Backup Snapshot'),
                        ],
                      ),
                    ),
                  ],
                )
              ],
            ),
            const SizedBox(height: 24),

            Expanded(
              child: backupsVal.when(
                data: (backups) {
                  if (backups.isEmpty) {
                    return const Center(
                      child: Text('No backup logs recorded yet.', style: TextStyle(color: AppTheme.textSecondary)),
                    );
                  }

                  return ListView.builder(
                    itemCount: backups.length,
                    itemBuilder: (context, index) {
                      final backup = backups[index];
                      return Card(
                        margin: const EdgeInsets.only(bottom: 12),
                        color: AppTheme.darkCard,
                        child: ListTile(
                          contentPadding: const EdgeInsets.all(12),
                          leading: Container(
                            padding: const EdgeInsets.all(8),
                            decoration: BoxDecoration(color: AppTheme.primary.withOpacity(0.12), borderRadius: BorderRadius.circular(8)),
                            child: const Icon(Icons.settings_backup_restore, color: AppTheme.primary),
                          ),
                          title: Text(backup.name, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13)),
                          subtitle: Padding(
                            padding: const EdgeInsets.only(top: 4.0),
                            child: Text(
                              'Size: ${backup.sizeFormatted} • Created: ${backup.createdAt.day}/${backup.createdAt.month}/${backup.createdAt.year} at ${backup.createdAt.hour}:${backup.createdAt.minute.toString().padLeft(2, '0')}',
                              style: const TextStyle(fontSize: 11, color: AppTheme.textSecondary),
                            ),
                          ),
                          trailing: IconButton(
                            icon: const Icon(Icons.download, color: AppTheme.secondary),
                            onPressed: () {
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(content: Text('Downloading backup payload: ${backup.name}...')),
                              );
                            },
                          ),
                        ),
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
}
extension on Color {
  Color withOpacity(double opacity) {
    return withValues(alpha: opacity);
  }
}
