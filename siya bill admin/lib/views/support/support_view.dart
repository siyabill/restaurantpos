import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../models/restaurant_profile.dart';
import '../../core/theme.dart';
import '../../models/ticket.dart';
import '../../providers/data_provider.dart';
import '../../providers/supabase_provider.dart';

class SupportView extends ConsumerStatefulWidget {
  const SupportView({super.key});

  @override
  ConsumerState<SupportView> createState() => _SupportViewState();
}

class _SupportViewState extends ConsumerState<SupportView> {
  String? _selectedTicketId;
  final _messageController = TextEditingController();
  final _scrollController = ScrollController();
  String _filterStatus = 'all';
  String _filterPriority = 'all';

  String _normalizeTicketStatus(String status) {
    final s = status.toLowerCase().trim();
    if (s == 'open') return 'open';
    if (s == 'in-progress' || s == 'progress') return 'in-progress';
    if (s == 'resolved' || s == 'closed') return 'resolved';
    return 'open'; // default fallback
  }

  @override
  void dispose() {
    _messageController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  void _sendMessage() async {
    final text = _messageController.text.trim();
    if (text.isNotEmpty && _selectedTicketId != null) {
      _messageController.clear();
      await ref.read(supabaseServiceProvider).sendChatMessage(_selectedTicketId!, text);
      
      Future.delayed(const Duration(milliseconds: 100), () {
        if (_scrollController.hasClients) {
          _scrollController.jumpTo(_scrollController.position.maxScrollExtent);
        }
      });
    }
  }

  void _updateStatus(String status) async {
    if (_selectedTicketId != null) {
      await ref.read(supabaseServiceProvider).updateTicketStatus(_selectedTicketId!, status);
    }
  }

  void _quickUnblockAndResolve(String appUserId) async {
    if (_selectedTicketId != null) {
      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (context) => const Center(child: CircularProgressIndicator()),
      );

      try {
        await ref.read(supabaseServiceProvider).quickUnblockAndResolve(
          ticketId: _selectedTicketId!,
          targetUserId: appUserId,
        );
        // Refresh streams
        ref.invalidate(ticketsStreamProvider);
        ref.invalidate(violationsStreamProvider);

        if (mounted) {
          Navigator.pop(context); // Close loading
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Account unblocked and ticket resolved successfully!'), backgroundColor: AppTheme.secondary),
          );
        }
      } catch (e) {
        if (mounted) {
          Navigator.pop(context); // Close loading
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Failed operation: $e'), backgroundColor: AppTheme.error),
          );
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final ticketsVal = ref.watch(ticketsStreamProvider);

    return Scaffold(
      body: ticketsVal.when(
        data: (tickets) {
          final filtered = tickets.where((t) {
            final matchesStatus = _filterStatus == 'all' || t.status == _filterStatus;
            // Handle mock default priority or schemas
            final matchesPriority = _filterPriority == 'all' || t.subject.toLowerCase().contains(_filterPriority);
            return matchesStatus && matchesPriority;
          }).toList();

          return LayoutBuilder(
            builder: (context, constraints) {
              if (constraints.maxWidth > 800) {
                return Row(
                  children: [
                    SizedBox(
                      width: 320,
                      child: Column(
                        children: [
                          _buildFiltersBar(),
                          const Divider(height: 1),
                          Expanded(child: _buildTicketsList(filtered)),
                        ],
                      ),
                    ),
                    const VerticalDivider(width: 1, color: AppTheme.border),
                    Expanded(
                      child: _selectedTicketId == null
                          ? const Center(child: Text('Select a conversation to reply.', style: TextStyle(color: AppTheme.textSecondary)))
                          : _buildChatWindow(tickets.firstWhere((t) => t.id == _selectedTicketId)),
                    ),
                  ],
                );
              }

              // Mobile View
              if (_selectedTicketId != null) {
                return WillPopScope(
                  onWillPop: () async {
                    setState(() {
                      _selectedTicketId = null;
                    });
                    return false;
                  },
                  child: _buildChatWindow(tickets.firstWhere((t) => t.id == _selectedTicketId), showBackButton: true),
                );
              }

              return Column(
                children: [
                  _buildFiltersBar(),
                  const Divider(height: 1),
                  Expanded(child: _buildTicketsList(filtered)),
                ],
              );
            },
          );
        },
        error: (e, __) => Center(child: Text('Error: $e', style: const TextStyle(color: AppTheme.error))),
        loading: () => const Center(child: CircularProgressIndicator()),
      ),
    );
  }

  Widget _buildFiltersBar() {
    return Padding(
      padding: const EdgeInsets.all(12.0),
      child: Row(
        children: [
          Expanded(
            child: DropdownButtonHideUnderline(
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 8),
                decoration: BoxDecoration(
                  color: AppTheme.darkSurface,
                  border: Border.all(color: AppTheme.border),
                  borderRadius: BorderRadius.circular(6),
                ),
                child: DropdownButton<String>(
                  value: _filterStatus,
                  dropdownColor: AppTheme.darkSurface,
                  items: const [
                    DropdownMenuItem(value: 'all', child: Text('All Status', style: TextStyle(fontSize: 12))),
                    DropdownMenuItem(value: 'open', child: Text('Open', style: TextStyle(fontSize: 12))),
                    DropdownMenuItem(value: 'in-progress', child: Text('Progress', style: TextStyle(fontSize: 12))),
                    DropdownMenuItem(value: 'resolved', child: Text('Resolved', style: TextStyle(fontSize: 12))),
                  ],
                  onChanged: (val) {
                    if (val != null) {
                      setState(() {
                        _filterStatus = val;
                      });
                    }
                  },
                ),
              ),
            ),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: DropdownButtonHideUnderline(
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 8),
                decoration: BoxDecoration(
                  color: AppTheme.darkSurface,
                  border: Border.all(color: AppTheme.border),
                  borderRadius: BorderRadius.circular(6),
                ),
                child: DropdownButton<String>(
                  value: _filterPriority,
                  dropdownColor: AppTheme.darkSurface,
                  items: const [
                    DropdownMenuItem(value: 'all', child: Text('All Categories', style: TextStyle(fontSize: 12))),
                    DropdownMenuItem(value: 'printer', child: Text('Printers', style: TextStyle(fontSize: 12))),
                    DropdownMenuItem(value: 'renew', child: Text('Renewals', style: TextStyle(fontSize: 12))),
                    DropdownMenuItem(value: 'unblock', child: Text('Unblocks', style: TextStyle(fontSize: 12))),
                  ],
                  onChanged: (val) {
                    if (val != null) {
                      setState(() {
                        _filterPriority = val;
                      });
                    }
                  },
                ),
              ),
            ),
          )
        ],
      ),
    );
  }

  Widget _buildTicketsList(List<TicketModel> tickets) {
    final outlets = ref.watch(outletsProvider).value ?? [];

    return ListView.builder(
      itemCount: tickets.length,
      itemBuilder: (context, index) {
        final ticket = tickets[index];
        final isSelected = ticket.id == _selectedTicketId;
        final lastMsg = ticket.messages.isNotEmpty ? ticket.messages.last.content : 'No messages';

        // Lookup restaurant name
        final matchingOutlet = outlets.firstWhere(
          (o) => o.restaurantCode == ticket.restaurantCode || o.appUserId == ticket.appUserId,
          orElse: () => RestaurantProfileModel(
            id: '',
            appUserId: '',
            restaurantName: ticket.restaurantCode ?? 'Unknown Store',
            subscriptionStatus: '',
            subscriptionExpiry: 0,
            subscriptionPlan: '',
            updatedAt: DateTime.now(),
          ),
        );
        final displayName = matchingOutlet.restaurantName;

        return InkWell(
          onTap: () {
            setState(() {
              _selectedTicketId = ticket.id;
            });
          },
          child: Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: isSelected ? AppTheme.primary.withOpacity(0.08) : Colors.transparent,
              border: const Border(bottom: BorderSide(color: AppTheme.border, width: 0.5)),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Expanded(
                      child: Text(
                        ticket.category?.toUpperCase() ?? 'SUPPORT TICKET',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 13,
                          color: isSelected ? AppTheme.primary : AppTheme.textPrimary,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    _buildStatusLabel(ticket.status),
                  ],
                ),
                const SizedBox(height: 6),
                Text(
                  displayName,
                  style: const TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: AppTheme.textSecondary),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 4),
                Text(
                  ticket.description,
                  style: const TextStyle(fontSize: 11, color: AppTheme.textSecondary),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildChatWindow(TicketModel ticket, {bool showBackButton = false}) {
    final isUnblockRequest = ticket.subject.toLowerCase().contains('unblock') ||
        ticket.category?.toLowerCase() == 'unblock' ||
        ticket.messages.any((m) => m.content.toLowerCase().contains('unblock'));
    
    final outlets = ref.read(outletsProvider).value ?? [];
    final matchingOutlet = outlets.firstWhere(
      (o) => o.restaurantCode == ticket.restaurantCode || o.appUserId == ticket.appUserId,
      orElse: () => RestaurantProfileModel(
        id: '',
        appUserId: '',
        restaurantName: ticket.restaurantCode ?? 'Unknown Store',
        subscriptionStatus: '',
        subscriptionExpiry: 0,
        subscriptionPlan: '',
        updatedAt: DateTime.now(),
      ),
    );
    final displayName = matchingOutlet.restaurantName;

    return Column(
      children: [
        // Header
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          color: AppTheme.darkSurface,
          child: Row(
            children: [
              if (showBackButton)
                IconButton(
                  icon: const Icon(Icons.arrow_back),
                  onPressed: () {
                    setState(() {
                      _selectedTicketId = null;
                    });
                  },
                ),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(displayName, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
                    Text(
                      'Category: ${ticket.category?.toUpperCase() ?? 'SUPPORT'} • ID: ${ticket.id.toUpperCase()}',
                      style: const TextStyle(color: AppTheme.textSecondary, fontSize: 11),
                    ),
                  ],
                ),
              ),
              Row(
                children: [
                  if (isUnblockRequest)
                    ElevatedButton(
                      onPressed: () => _quickUnblockAndResolve(ticket.appUserId ?? ticket.id),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppTheme.secondary,
                        minimumSize: const Size(100, 32),
                        padding: const EdgeInsets.symmetric(horizontal: 12),
                      ),
                      child: const Row(
                        children: [
                          Icon(Icons.lock_open, size: 14),
                          SizedBox(width: 6),
                          Text('Unlock User', style: TextStyle(fontSize: 11)),
                        ],
                      ),
                    ),
                  const SizedBox(width: 8),
                  DropdownButton<String>(
                    value: _normalizeTicketStatus(ticket.status),
                    dropdownColor: AppTheme.darkSurface,
                    style: const TextStyle(fontSize: 12, color: AppTheme.primary, fontWeight: FontWeight.bold),
                    items: const [
                      DropdownMenuItem(value: 'open', child: Text('Open')),
                      DropdownMenuItem(value: 'in-progress', child: Text('In Progress')),
                      DropdownMenuItem(value: 'resolved', child: Text('Resolved')),
                    ],
                    onChanged: (val) {
                      if (val != null) {
                        _updateStatus(val);
                      }
                    },
                  ),
                ],
              ),
            ],
          ),
        ),
        const Divider(height: 1),

        // Messages list
        Expanded(
          child: ListView.builder(
            controller: _scrollController,
            padding: const EdgeInsets.all(16),
            itemCount: ticket.messages.length + 1,
            itemBuilder: (context, index) {
              if (index == 0) {
                return Container(
                  margin: const EdgeInsets.only(bottom: 16),
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: AppTheme.darkCard,
                    border: Border.all(color: AppTheme.border),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const Text(
                            'CLIENT COMPLAINT / PROBLEM',
                            style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: AppTheme.textSecondary),
                          ),
                          Text(
                            '${ticket.createdAt.day}/${ticket.createdAt.month}/${ticket.createdAt.year} ${ticket.createdAt.hour}:${ticket.createdAt.minute.toString().padLeft(2, '0')}',
                            style: const TextStyle(fontSize: 10, color: AppTheme.textSecondary),
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),
                      Text(
                        ticket.description,
                        style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w500, color: AppTheme.textPrimary),
                      ),
                    ],
                  ),
                );
              }

              final msg = ticket.messages[index - 1];
              final isAdmin = msg.sender == 'admin';

              return Align(
                alignment: isAdmin ? Alignment.centerRight : Alignment.centerLeft,
                child: Container(
                  margin: const EdgeInsets.only(bottom: 12),
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                  constraints: BoxConstraints(maxWidth: MediaQuery.of(context).size.width * 0.5),
                  decoration: BoxDecoration(
                    color: isAdmin ? AppTheme.primary : AppTheme.darkCard,
                    borderRadius: BorderRadius.only(
                      topLeft: const Radius.circular(12),
                      topRight: const Radius.circular(12),
                      bottomLeft: isAdmin ? const Radius.circular(12) : const Radius.circular(0),
                      bottomRight: isAdmin ? const Radius.circular(0) : const Radius.circular(12),
                    ),
                    border: isAdmin ? null : Border.all(color: AppTheme.border),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      if (msg.senderName != null || !isAdmin) ...[
                        Text(
                          msg.senderName ?? (isAdmin ? 'Admin' : 'Client'),
                          style: TextStyle(
                            fontSize: 9,
                            fontWeight: FontWeight.bold,
                            color: isAdmin ? Colors.white70 : AppTheme.primary,
                          ),
                        ),
                        const SizedBox(height: 4),
                      ],
                      Text(
                        msg.content,
                        style: TextStyle(color: isAdmin ? Colors.white : AppTheme.textPrimary, fontSize: 13),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        '${msg.timestamp.hour}:${msg.timestamp.minute.toString().padLeft(2, '0')}',
                        style: TextStyle(color: isAdmin ? Colors.white70 : AppTheme.textSecondary, fontSize: 9),
                      ),
                    ],
                  ),
                ),
              );
            },
          ),
        ),
        const Divider(height: 1),

        // Compose box
        Padding(
          padding: const EdgeInsets.all(16.0),
          child: Row(
            children: [
              Expanded(
                child: TextField(
                  controller: _messageController,
                  decoration: const InputDecoration(
                    hintText: 'Compose your reply message here...',
                    contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                  ),
                  onSubmitted: (_) => _sendMessage(),
                ),
              ),
              const SizedBox(width: 12),
              ElevatedButton(
                onPressed: _sendMessage,
                style: ElevatedButton.styleFrom(
                  minimumSize: const Size(44, 44),
                  padding: EdgeInsets.zero,
                ),
                child: const Icon(Icons.send, size: 16),
              ),
            ],
          ),
        )
      ],
    );
  }

  Widget _buildStatusLabel(String status) {
    Color badgeColor;
    switch (status) {
      case 'open':
        badgeColor = AppTheme.accent;
        break;
      case 'in-progress':
        badgeColor = AppTheme.primary;
        break;
      case 'resolved':
        badgeColor = AppTheme.secondary;
        break;
      default:
        badgeColor = AppTheme.textSecondary;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
      decoration: BoxDecoration(
        color: badgeColor.withOpacity(0.12),
        borderRadius: BorderRadius.circular(4),
      ),
      child: Text(
        status.toUpperCase(),
        style: TextStyle(color: badgeColor, fontSize: 9, fontWeight: FontWeight.bold),
      ),
    );
  }
}
extension on Color {
  Color withOpacity(double opacity) {
    return withValues(alpha: opacity);
  }
}
