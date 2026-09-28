import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../core/theme.dart';
import '../../models/license.dart';
import '../../providers/data_provider.dart';

class LicensesView extends ConsumerStatefulWidget {
  const LicensesView({super.key});

  @override
  ConsumerState<LicensesView> createState() => _LicensesViewState();
}

class _LicensesViewState extends ConsumerState<LicensesView> {
  final _formKey = GlobalKey<FormState>();
  final _restaurantCodeController = TextEditingController();
  String _selectedPlan = 'monthly';
  int _expiryDays = 30;

  @override
  void dispose() {
    _restaurantCodeController.dispose();
    super.dispose();
  }

  void _generateKey() async {
    if (_formKey.currentState!.validate()) {
      final code = _restaurantCodeController.text.trim().toUpperCase();
      
      switch (_selectedPlan) {
        case 'monthly':
          _expiryDays = 30;
          break;
        case 'half-yearly':
          _expiryDays = 180;
          break;
        case 'yearly':
          _expiryDays = 365;
          break;
        case 'lifetime':
          _expiryDays = 9999;
          break;
      }

      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (context) => const Center(child: CircularProgressIndicator()),
      );

      try {
        await ref.read(licensesProvider.notifier).generateNewLicense(
          planType: _selectedPlan,
          restaurantCode: code,
          expiryDays: _expiryDays,
        );
        if (mounted) {
          Navigator.pop(context); // Dismiss loading
          _restaurantCodeController.clear();
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Cryptographic license key created successfully!'), backgroundColor: AppTheme.secondary),
          );
        }
      } catch (e) {
        if (mounted) {
          Navigator.pop(context); // Dismiss loading
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Failed to generate key: $e'), backgroundColor: AppTheme.error),
          );
        }
      }
    }
  }

  void _revoke(LicenseModel license) async {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => const Center(child: CircularProgressIndicator()),
    );

    try {
      await ref.read(licensesProvider.notifier).revoke(
        licenseId: license.id,
        claimedByUserId: license.claimedByUserId,
      );
      if (mounted) {
        Navigator.pop(context); // Dismiss loading
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('License key revoked and claimed client downgraded successfully.'), backgroundColor: AppTheme.error),
        );
      }
    } catch (e) {
      if (mounted) {
        Navigator.pop(context); // Dismiss loading
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to revoke license: $e'), backgroundColor: AppTheme.error),
        );
      }
    }
  }

  Future<void> _shareToWhatsApp(String licenseKey, String restaurantCode) async {
    final text = 'Hi, here is your cryptographic License Key for SIYA POS:\n\n'
        '*Restaurant*: $restaurantCode\n'
        '*License Key*: `$licenseKey`';
        
    final url = Uri.parse('https://wa.me/?text=${Uri.encodeComponent(text)}');
    
    try {
      if (await canLaunchUrl(url)) {
        await launchUrl(url, mode: LaunchMode.externalApplication);
      } else {
        throw 'Could not launch URL';
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: const Text('Could not open WhatsApp. Key copied to clipboard instead.'),
            backgroundColor: AppTheme.accent,
          ),
        );
        Clipboard.setData(ClipboardData(text: licenseKey));
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final licensesVal = ref.watch(licensesProvider);

    return Scaffold(
      body: LayoutBuilder(
        builder: (context, constraints) {
          if (constraints.maxWidth > 950) {
            return Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(flex: 2, child: _buildGeneratorForm()),
                const VerticalDivider(width: 1, color: AppTheme.border),
                Expanded(flex: 3, child: _buildLicensesList(licensesVal)),
              ],
            );
          }
          return SingleChildScrollView(
            child: Column(
              children: [
                _buildGeneratorForm(),
                const Divider(),
                SizedBox(
                  height: 500,
                  child: _buildLicensesList(licensesVal),
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildGeneratorForm() {
    return Padding(
      padding: const EdgeInsets.all(24.0),
      child: Form(
        key: _formKey,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('License Keys Engine', style: Theme.of(context).textTheme.headlineMedium),
            const SizedBox(height: 8),
            const Text(
              'Issues standard or lifetime licenses cryptographically. Enforces cloud signing and falls back to local asymmetric ECDSA P-256 signature on timeout.',
              style: TextStyle(color: AppTheme.textSecondary, fontSize: 13),
            ),
            const SizedBox(height: 24),
            TextFormField(
              controller: _restaurantCodeController,
              decoration: const InputDecoration(
                labelText: 'Target Restaurant Code',
                hintText: 'e.g. RES-G6T8X9',
                prefixIcon: Icon(Icons.store),
              ),
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Please enter restaurant code';
                }
                if (value.trim().length < 4) {
                  return 'Code must be at least 4 characters';
                }
                return null;
              },
            ),
            const SizedBox(height: 20),
            DropdownButtonFormField<String>(
              value: _selectedPlan,
              decoration: const InputDecoration(
                labelText: 'Premium Plan Duration',
                prefixIcon: Icon(Icons.card_membership_outlined),
              ),
              dropdownColor: AppTheme.darkSurface,
              items: const [
                DropdownMenuItem(value: 'monthly', child: Text('Monthly Plan (30 Days)')),
                DropdownMenuItem(value: 'half-yearly', child: Text('Half-Yearly Plan (180 Days)')),
                DropdownMenuItem(value: 'yearly', child: Text('Yearly Plan (365 Days)')),
                DropdownMenuItem(value: 'lifetime', child: Text('Lifetime License (Unlimited)')),
              ],
              onChanged: (val) {
                if (val != null) {
                  setState(() {
                    _selectedPlan = val;
                  });
                }
              },
            ),
            const SizedBox(height: 32),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: _generateKey,
                child: const Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.vpn_key_outlined),
                    SizedBox(width: 8),
                    Text('Generate Premium Key'),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildLicensesList(AsyncValue<List<LicenseModel>> licensesVal) {
    return Padding(
      padding: const EdgeInsets.all(24.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text('Claims & Generated Keys Logs', style: Theme.of(context).textTheme.titleMedium),
              IconButton(
                icon: const Icon(Icons.refresh, size: 20),
                onPressed: () => ref.read(licensesProvider.notifier).refresh(),
              )
            ],
          ),
          const SizedBox(height: 16),
          Expanded(
            child: licensesVal.when(
              data: (list) {
                if (list.isEmpty) {
                  return const Center(
                    child: Text('No cryptographic keys generated yet.', style: TextStyle(color: AppTheme.textSecondary)),
                  );
                }
                return ListView.builder(
                  itemCount: list.length,
                  itemBuilder: (context, index) {
                    final license = list[index];
                    final isClaimed = license.status == 'claimed';
                    final isRevoked = license.status == 'revoked';

                    return Card(
                      margin: const EdgeInsets.only(bottom: 12),
                      color: AppTheme.darkCard,
                      child: ListTile(
                        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                        title: Row(
                          children: [
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                              decoration: BoxDecoration(
                                color: AppTheme.primary.withOpacity(0.12),
                                borderRadius: BorderRadius.circular(4),
                              ),
                              child: Text(
                                license.planType.toUpperCase(),
                                style: const TextStyle(fontSize: 10, color: AppTheme.primary, fontWeight: FontWeight.bold),
                              ),
                            ),
                            const SizedBox(width: 8),
                            Text(license.restaurantCode, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
                          ],
                        ),
                        subtitle: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const SizedBox(height: 6),
                            SelectableText(
                              license.licenseKey,
                              style: const TextStyle(fontFamily: 'monospace', fontSize: 10, color: AppTheme.textSecondary),
                              maxLines: 1,
                            ),
                            const SizedBox(height: 4),
                            Text(
                              'Status: ${license.status.toUpperCase()} • Duration: ${license.expiryDays}d',
                              style: TextStyle(
                                fontSize: 10, 
                                color: isRevoked 
                                    ? AppTheme.error 
                                    : isClaimed 
                                        ? AppTheme.secondary 
                                        : AppTheme.accent
                              ),
                            ),
                          ],
                        ),
                        trailing: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            IconButton(
                              icon: const Icon(Icons.copy, size: 18),
                              onPressed: () {
                                Clipboard.setData(ClipboardData(text: license.licenseKey));
                                ScaffoldMessenger.of(context).showSnackBar(
                                  const SnackBar(content: Text('Copied key string!'), duration: Duration(seconds: 1)),
                                );
                              },
                            ),
                            IconButton(
                              icon: const Icon(Icons.share, size: 18, color: AppTheme.secondary),
                              onPressed: () => _shareToWhatsApp(license.licenseKey, license.restaurantCode),
                            ),
                            if (!isRevoked)
                              IconButton(
                                icon: const Icon(Icons.block, size: 18, color: AppTheme.error),
                                onPressed: () => _revoke(license),
                                tooltip: 'Revoke License Key',
                              ),
                          ],
                        ),
                      ),
                    );
                  },
                );
              },
              error: (e, __) => Center(
                child: Text('Error: $e', style: const TextStyle(color: AppTheme.error)),
              ),
              loading: () => const Center(child: CircularProgressIndicator()),
            ),
          )
        ],
      ),
    );
  }
}
extension on Color {
  Color withOpacity(double opacity) {
    return withValues(alpha: opacity);
  }
}
