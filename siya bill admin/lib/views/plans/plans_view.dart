import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/theme.dart';
import '../../models/plan.dart';
import '../../providers/data_provider.dart';

class PlansView extends ConsumerStatefulWidget {
  const PlansView({super.key});

  @override
  ConsumerState<PlansView> createState() => _PlansViewState();
}

class _PlansViewState extends ConsumerState<PlansView> {
  final _formKey = GlobalKey<FormState>();
  final _idController = TextEditingController();
  final _nameController = TextEditingController();
  final _priceController = TextEditingController();
  final _durationController = TextEditingController();
  final _featuresController = TextEditingController();
  bool _isPlanActive = true;

  String _generateUUIDv4() {
    final random = math.Random.secure();
    final List<int> bytes = List<int>.generate(16, (_) => random.nextInt(256));
    bytes[6] = (bytes[6] & 0x0f) | 0x40;
    bytes[8] = (bytes[8] & 0x3f) | 0x80;
    
    final buffer = StringBuffer();
    for (int i = 0; i < bytes.length; i++) {
      if (i == 4 || i == 6 || i == 8 || i == 10) {
        buffer.write('-');
      }
      buffer.write(bytes[i].toRadixString(16).padLeft(2, '0'));
    }
    return buffer.toString().toLowerCase();
  }

  @override
  void dispose() {
    _idController.dispose();
    _nameController.dispose();
    _priceController.dispose();
    _durationController.dispose();
    _featuresController.dispose();
    super.dispose();
  }

  void _showPlanDialog([PlanModel? plan]) {
    final isEdit = plan != null;
    
    if (isEdit) {
      _idController.text = plan.id;
      _nameController.text = plan.name;
      _priceController.text = plan.price.toString();
      _durationController.text = plan.durationDays.toString();
      _featuresController.text = plan.features.join('\n');
      _isPlanActive = plan.isActive;
    } else {
      _idController.clear();
      _nameController.clear();
      _priceController.clear();
      _durationController.clear();
      _featuresController.clear();
      _isPlanActive = true;
    }

    showDialog(
      context: context,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setDialogState) {
            return AlertDialog(
              backgroundColor: AppTheme.darkSurface,
              title: Text(isEdit ? 'Edit Pricing Plan' : 'Create New Plan'),
              content: SingleChildScrollView(
                child: Form(
                  key: _formKey,
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      if (isEdit) ...[
                        TextFormField(
                          controller: _idController,
                          enabled: false,
                          decoration: const InputDecoration(labelText: 'Plan ID (Read Only)'),
                        ),
                        const SizedBox(height: 12),
                      ],
                      TextFormField(
                        controller: _nameController,
                        decoration: const InputDecoration(labelText: 'Plan Name'),
                        validator: (v) => v == null || v.isEmpty ? 'Required' : null,
                      ),
                      const SizedBox(height: 12),
                      TextFormField(
                        controller: _priceController,
                        keyboardType: TextInputType.number,
                        decoration: const InputDecoration(labelText: 'Price (INR)'),
                        validator: (v) => v == null || double.tryParse(v) == null ? 'Invalid Price' : null,
                      ),
                      const SizedBox(height: 12),
                      TextFormField(
                        controller: _durationController,
                        keyboardType: TextInputType.number,
                        decoration: const InputDecoration(labelText: 'Duration (Days)'),
                        validator: (v) => v == null || int.tryParse(v) == null ? 'Invalid Days' : null,
                      ),
                      const SizedBox(height: 12),
                      TextFormField(
                        controller: _featuresController,
                        maxLines: 4,
                        decoration: const InputDecoration(
                          labelText: 'Features (One per line)',
                          hintText: 'Billing\nSales Reports\nUnlimited Devices',
                        ),
                      ),
                      const SizedBox(height: 12),
                      SwitchListTile(
                        title: const Text('Is Active'),
                        value: _isPlanActive,
                        onChanged: (val) {
                          setDialogState(() {
                            _isPlanActive = val;
                          });
                        },
                      ),
                    ],
                  ),
                ),
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(context),
                  child: const Text('Cancel'),
                ),
                ElevatedButton(
                  onPressed: () => _savePlan(isEdit),
                  child: const Text('Save Plan'),
                ),
              ],
            );
          },
        );
      },
    );
  }

  void _savePlan(bool isEdit) async {
    if (_formKey.currentState!.validate()) {
      final features = _featuresController.text
          .split('\n')
          .map((f) => f.trim())
          .where((f) => f.isNotEmpty)
          .toList();

      final planId = isEdit ? _idController.text.trim() : _generateUUIDv4();

      final plan = PlanModel(
        id: planId,
        name: _nameController.text.trim(),
        price: double.parse(_priceController.text),
        durationDays: int.parse(_durationController.text),
        features: features,
        isActive: _isPlanActive,
      );

      Navigator.pop(context); // Close dialog
      
      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (context) => const Center(child: CircularProgressIndicator()),
      );

      try {
        await ref.read(plansProvider.notifier).savePlan(plan);
        if (mounted) {
          Navigator.pop(context); // Close loader
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Plan upserted and synchronized successfully!'), backgroundColor: AppTheme.secondary),
          );
        }
      } catch (e) {
        if (mounted) {
          Navigator.pop(context); // Close loader
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Failed to save plan: $e'), backgroundColor: AppTheme.error),
          );
        }
      }
    }
  }

  void _deletePlan(String planId) async {
    final corePlans = ['m01', 'm06', 'y01', 'lif'];
    if (corePlans.contains(planId)) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Delete Denied: Core ecosystem plans cannot be removed.'), backgroundColor: AppTheme.error),
      );
      return;
    }

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => const Center(child: CircularProgressIndicator()),
    );

    try {
      await ref.read(plansProvider.notifier).removePlan(planId);
      if (mounted) {
        Navigator.pop(context);
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Plan deleted successfully.'), backgroundColor: AppTheme.error),
        );
      }
    } catch (e) {
      if (mounted) {
        Navigator.pop(context);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to delete plan: $e'), backgroundColor: AppTheme.error),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final plansVal = ref.watch(plansProvider);

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
                      Text('Dynamic Packages CRUD', style: Theme.of(context).textTheme.headlineMedium),
                      const SizedBox(height: 8),
                      const Text(
                        'Create, toggle status, and edit subscription pricing plans sync\'d across POS registers.',
                        style: TextStyle(color: AppTheme.textSecondary),
                      ),
                    ],
                  ),
                ),
                ElevatedButton(
                  onPressed: () => _showPlanDialog(),
                  child: const Row(
                    children: [
                      Icon(Icons.add, size: 18),
                      SizedBox(width: 8),
                      Text('Create New Plan'),
                    ],
                  ),
                )
              ],
            ),
            const SizedBox(height: 24),

            Expanded(
              child: plansVal.when(
                data: (plans) {
                  return LayoutBuilder(
                    builder: (context, constraints) {
                      int crossAxisCount = constraints.maxWidth > 900 ? 3 : constraints.maxWidth > 600 ? 2 : 1;
                      return GridView.builder(
                        itemCount: plans.length,
                        gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                          crossAxisCount: crossAxisCount,
                          crossAxisSpacing: 16,
                          mainAxisSpacing: 16,
                          childAspectRatio: 0.95,
                        ),
                        itemBuilder: (context, index) {
                          final plan = plans[index];
                          return Card(
                            color: AppTheme.darkCard,
                            child: Padding(
                              padding: const EdgeInsets.all(16.0),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Row(
                                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                    children: [
                                      Container(
                                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                                        decoration: BoxDecoration(
                                          color: AppTheme.primary.withOpacity(0.12),
                                          borderRadius: BorderRadius.circular(4),
                                        ),
                                        child: Text(plan.id.toUpperCase(), style: const TextStyle(fontSize: 10, color: AppTheme.primary, fontWeight: FontWeight.bold)),
                                      ),
                                      Switch(
                                        value: plan.isActive,
                                        onChanged: (val) {
                                          ref.read(plansProvider.notifier).toggleActive(plan.id, val);
                                        },
                                      ),
                                    ],
                                  ),
                                  const SizedBox(height: 12),
                                  Text(plan.name, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                                  const SizedBox(height: 4),
                                  Text('₹${plan.price.toStringAsFixed(0)} / ${plan.durationDays} Days', style: const TextStyle(fontSize: 14, color: AppTheme.secondary, fontWeight: FontWeight.bold)),
                                  const SizedBox(height: 12),
                                  const Text('Features Included:', style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: AppTheme.textSecondary)),
                                  const SizedBox(height: 4),
                                  Expanded(
                                    child: ListView(
                                      children: plan.features.map((f) => Row(
                                        children: [
                                          const Icon(Icons.check, size: 12, color: AppTheme.secondary),
                                          const SizedBox(width: 6),
                                          Expanded(child: Text(f, style: const TextStyle(fontSize: 11, color: AppTheme.textSecondary))),
                                        ],
                                      )).toList(),
                                    ),
                                  ),
                                  const Divider(),
                                  Row(
                                    mainAxisAlignment: MainAxisAlignment.end,
                                    children: [
                                      IconButton(
                                        icon: const Icon(Icons.edit, size: 18, color: AppTheme.accent),
                                        onPressed: () => _showPlanDialog(plan),
                                      ),
                                      IconButton(
                                        icon: const Icon(Icons.delete, size: 18, color: AppTheme.error),
                                        onPressed: () => _deletePlan(plan.id),
                                      ),
                                    ],
                                  )
                                ],
                              ),
                            ),
                          );
                        },
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
