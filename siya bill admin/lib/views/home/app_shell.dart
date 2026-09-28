import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/theme.dart';
import '../../providers/auth_provider.dart';
import '../dashboard/dashboard_view.dart';
import '../outlets/outlets_view.dart';
import '../licenses/licenses_view.dart';
import '../plans/plans_view.dart';
import '../support/support_view.dart';
import '../violations/violations_view.dart';
import '../network/network_view.dart';
import '../analytics/analytics_view.dart';
import '../backups/backups_view.dart';

class AppShell extends ConsumerStatefulWidget {
  const AppShell({super.key});

  @override
  ConsumerState<AppShell> createState() => _AppShellState();
}

class _AppShellState extends ConsumerState<AppShell> {
  int _currentIndex = 0;
  bool _sidebarExpanded = true;

  final List<Widget> _views = [
    const DashboardView(),
    const OutletsView(),
    const LicensesView(),
    const PlansView(),
    const SupportView(),
    const ViolationsView(),
    const NetworkView(),
    const AnalyticsView(),
    const BackupsView(),
  ];

  final List<NavigationItem> _navItems = [
    NavigationItem(Icons.dashboard_outlined, 'Dashboard'),
    NavigationItem(Icons.storefront_outlined, 'Outlets Directory'),
    NavigationItem(Icons.vpn_key_outlined, 'License Keys'),
    NavigationItem(Icons.payments_outlined, 'Plans Manager'),
    NavigationItem(Icons.chat_bubble_outline, 'Support Helpdesk'),
    NavigationItem(Icons.gavel_outlined, 'Anti-Abuse Blocks'),
    NavigationItem(Icons.wifi_tethering_outlined, 'Network Audits'),
    NavigationItem(Icons.analytics_outlined, 'Ecosystem Analytics'),
    NavigationItem(Icons.backup_outlined, 'JSON Backups'),
  ];

  @override
  Widget build(BuildContext context) {
    final authState = ref.watch(authProvider);

    return Scaffold(
      appBar: AppBar(
        title: Row(
          children: [
            const Icon(Icons.shield_outlined, color: AppTheme.primary),
            const SizedBox(width: 8),
            Text(
              'SIYA POS Admin Console',
              style: Theme.of(context).appBarTheme.titleTextStyle?.copyWith(
                letterSpacing: 0.5,
              ),
            ),
          ],
        ),
        actions: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Row(
              children: [
                Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    const Text(
                      'Super Admin',
                      style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: AppTheme.secondary),
                    ),
                    Text(
                      authState.email ?? 'gudduk483@gmail.com',
                      style: const TextStyle(fontSize: 10, color: AppTheme.textSecondary),
                    ),
                  ],
                ),
                const SizedBox(width: 12),
                IconButton(
                  icon: const Icon(Icons.logout, color: AppTheme.error, size: 20),
                  onPressed: () => ref.read(authProvider.notifier).logout(),
                  tooltip: 'Sign Out',
                ),
              ],
            ),
          ),
        ],
      ),
      body: LayoutBuilder(
        builder: (context, constraints) {
          if (constraints.maxWidth > 980) {
            return Row(
              children: [
                _buildSidebar(context),
                const VerticalDivider(width: 1, color: AppTheme.border),
                Expanded(
                  child: AnimatedSwitcher(
                    duration: const Duration(milliseconds: 200),
                    child: _views[_currentIndex],
                  ),
                ),
              ],
            );
          }
          return _views[_currentIndex];
        },
      ),
      bottomNavigationBar: LayoutBuilder(
        builder: (context, constraints) {
          if (constraints.maxWidth <= 980) {
            return BottomNavigationBar(
              currentIndex: _currentIndex,
              onTap: (index) {
                setState(() {
                  _currentIndex = index;
                });
              },
              backgroundColor: AppTheme.darkSurface,
              selectedItemColor: AppTheme.primary,
              unselectedItemColor: AppTheme.textSecondary,
              type: BottomNavigationBarType.fixed,
              selectedFontSize: 9,
              unselectedFontSize: 9,
              items: _navItems.map((item) {
                return BottomNavigationBarItem(
                  icon: Icon(item.icon, size: 20),
                  label: item.title,
                );
              }).toList(),
            );
          }
          return const SizedBox.shrink();
        },
      ),
    );
  }

  Widget _buildSidebar(BuildContext context) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 150),
      width: _sidebarExpanded ? 260 : 72,
      color: AppTheme.darkSurface,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SizedBox(height: 16),
          IconButton(
            padding: const EdgeInsets.symmetric(horizontal: 24),
            icon: Icon(_sidebarExpanded ? Icons.chevron_left : Icons.chevron_right),
            onPressed: () {
              setState(() {
                _sidebarExpanded = !_sidebarExpanded;
              });
            },
          ),
          const SizedBox(height: 16),
          Expanded(
            child: ListView.builder(
              itemCount: _navItems.length,
              itemBuilder: (context, index) {
                final item = _navItems[index];
                final isSelected = index == _currentIndex;
                return InkWell(
                  onTap: () {
                    setState(() {
                      _currentIndex = index;
                    });
                  },
                  child: Container(
                    height: 44,
                    margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 2),
                    padding: const EdgeInsets.symmetric(horizontal: 12),
                    decoration: BoxDecoration(
                      color: isSelected 
                          ? AppTheme.primary.withOpacity(0.12)
                          : Colors.transparent,
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(
                        color: isSelected ? AppTheme.primary.withOpacity(0.3) : Colors.transparent,
                      ),
                    ),
                    child: Row(
                      children: [
                        Icon(
                          item.icon,
                          color: isSelected ? AppTheme.primary : AppTheme.textSecondary,
                          size: 20,
                        ),
                        if (_sidebarExpanded) ...[
                          const SizedBox(width: 12),
                          Expanded(
                            child: Text(
                              item.title,
                              style: TextStyle(
                                color: isSelected ? AppTheme.textPrimary : AppTheme.textSecondary,
                                fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                                fontSize: 13,
                              ),
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                        ]
                      ],
                    ),
                  ),
                );
              },
            ),
          ),
          const SizedBox(height: 16),
        ],
      ),
    );
  }
}

class NavigationItem {
  final IconData icon;
  final String title;
  NavigationItem(this.icon, this.title);
}
