import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../../../../core/l10n/app_l10n.dart';
import '../../../../l10n/generated/app_localizations.dart';
import '../../../cart/presentation/utils/format_sum.dart';
import '../../data/firebase_order_repository.dart';
import '../../domain/entities/app_order.dart';

class AdminOrdersPage extends StatelessWidget {
  const AdminOrdersPage({super.key, this.orderRepository});

  final FirebaseOrderRepository? orderRepository;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final bg = isDark ? const Color(0xFF141018) : const Color(0xFFFFF9F0);
    final repo = orderRepository ?? FirebaseOrderRepository();

    return Scaffold(
      backgroundColor: bg,
      appBar: AppBar(
        title: Text(l10n.adminOrdersTitle),
        backgroundColor: isDark ? const Color(0xFF1E1A22) : Colors.white,
        foregroundColor: isDark ? Colors.white : const Color(0xFF2B1E16),
        elevation: 0,
      ),
      body: StreamBuilder<List<AppOrder>>(
        stream: repo.watchAllOrders(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting && !snapshot.hasData) {
            return const Center(child: CircularProgressIndicator(color: Color(0xFFFF8C00)));
          }
          if (snapshot.hasError) {
            final err = snapshot.error;
            final msg = err is FirebaseException ? '${err.code}: ${err.message}' : l10n.adminOrdersLoadError;
            return Center(
              child: Padding(
                padding: const EdgeInsets.all(24),
                child: Text(msg, textAlign: TextAlign.center),
              ),
            );
          }
          final orders = snapshot.data ?? [];
          if (orders.isEmpty) {
            return Center(
              child: Text(
                l10n.adminOrdersEmpty,
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w700,
                  color: isDark ? Colors.white54 : Colors.brown.shade600,
                ),
              ),
            );
          }
          return ListView.separated(
            padding: const EdgeInsets.fromLTRB(16, 12, 16, 28),
            physics: const BouncingScrollPhysics(),
            itemCount: orders.length,
            separatorBuilder: (_, _) => const SizedBox(height: 12),
            itemBuilder: (context, i) => _AdminOrderCard(
              order: orders[i],
              isDark: isDark,
              l10n: l10n,
              repository: repo,
            ),
          );
        },
      ),
    );
  }
}

class _AdminOrderCard extends StatefulWidget {
  const _AdminOrderCard({
    required this.order,
    required this.isDark,
    required this.l10n,
    required this.repository,
  });

  final AppOrder order;
  final bool isDark;
  final AppLocalizations l10n;
  final FirebaseOrderRepository repository;

  @override
  State<_AdminOrderCard> createState() => _AdminOrderCardState();
}

class _AdminOrderCardState extends State<_AdminOrderCard> {
  late String _status;
  bool _updating = false;

  static const _statuses = ['pending', 'preparing', 'delivering', 'completed', 'cancelled'];

  @override
  void initState() {
    super.initState();
    _status = widget.order.status;
  }

  @override
  void didUpdateWidget(covariant _AdminOrderCard oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.order.status != widget.order.status) {
      _status = widget.order.status;
    }
  }

  String _statusLabel(String code) {
    return switch (code) {
      'preparing' => widget.l10n.orderStatusPreparing,
      'delivering' => widget.l10n.orderStatusDelivering,
      'completed' => widget.l10n.orderStatusCompleted,
      'cancelled' => widget.l10n.orderStatusCancelled,
      _ => widget.l10n.orderStatusPending,
    };
  }

  Color _statusColor(String code) {
    return switch (code) {
      'preparing' => const Color(0xFF42A5F5),
      'delivering' => const Color(0xFFAB47BC),
      'completed' => const Color(0xFF66BB6A),
      'cancelled' => const Color(0xFFEF5350),
      _ => const Color(0xFFFF8C00),
    };
  }

  Future<void> _onStatusChanged(String? value) async {
    if (value == null || value == _status) return;
    setState(() {
      _updating = true;
      _status = value;
    });
    try {
      await widget.repository.updateOrderStatus(widget.order.id, value);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            behavior: SnackBarBehavior.floating,
            content: Text(widget.l10n.adminOrderStatusUpdated),
          ),
        );
      }
    } catch (_) {
      if (mounted) {
        setState(() => _status = widget.order.status);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            behavior: SnackBarBehavior.floating,
            content: Text(widget.l10n.adminOrderStatusFailed),
          ),
        );
      }
    } finally {
      if (mounted) setState(() => _updating = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final o = widget.order;
    final card = widget.isDark ? const Color(0xFF1E1A22) : Colors.white;
    final loc = Localizations.localeOf(context).toLanguageTag();
    final when = DateFormat.yMMMd(loc).add_Hm().format(o.createdAt);

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: card,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: widget.isDark ? Colors.white.withValues(alpha: 0.08) : const Color(0xFFFFE0B2).withValues(alpha: 0.5),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: widget.isDark ? 0.28 : 0.06),
            blurRadius: 14,
            offset: const Offset(0, 7),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      widget.l10n.orderHistoryOrder(o.displayNumber),
                      style: TextStyle(
                        fontWeight: FontWeight.w900,
                        fontSize: 17,
                        color: widget.isDark ? Colors.white : const Color(0xFF2B1E16),
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      when,
                      style: TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w600,
                        color: widget.isDark ? Colors.white60 : Colors.brown.shade600,
                      ),
                    ),
                  ],
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                decoration: BoxDecoration(
                  color: _statusColor(_status).withValues(alpha: 0.15),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  _statusLabel(_status),
                  style: TextStyle(
                    fontWeight: FontWeight.w800,
                    fontSize: 12,
                    color: _statusColor(_status),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),
          _InfoRow(
            icon: Icons.person_outline_rounded,
            label: widget.l10n.adminOrderCustomer,
            value: o.customerName.isNotEmpty ? o.customerName : '—',
            isDark: widget.isDark,
          ),
          const SizedBox(height: 8),
          _InfoRow(
            icon: Icons.phone_outlined,
            label: widget.l10n.adminOrderPhone,
            value: o.phone.isNotEmpty ? o.phone : '—',
            isDark: widget.isDark,
          ),
          const SizedBox(height: 12),
          Text(
            widget.l10n.adminOrderDeliveryAddress,
            style: TextStyle(
              fontWeight: FontWeight.w800,
              fontSize: 14,
              color: widget.isDark ? Colors.white : const Color(0xFF2B1E16),
            ),
          ),
          const SizedBox(height: 6),
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: widget.isDark ? const Color(0xFF252030) : const Color(0xFFFFF6ED),
              borderRadius: BorderRadius.circular(14),
              border: Border.all(
                color: const Color(0xFFFF8C00).withValues(alpha: 0.25),
              ),
            ),
            child: Text(
              o.address.isNotEmpty ? o.address : '—',
              style: TextStyle(
                fontSize: 14,
                height: 1.45,
                fontWeight: FontWeight.w600,
                color: widget.isDark ? Colors.white.withValues(alpha: 0.92) : const Color(0xFF4E342E),
              ),
            ),
          ),
          const SizedBox(height: 12),
          Text(
            widget.l10n.adminOrderItems,
            style: TextStyle(
              fontWeight: FontWeight.w800,
              fontSize: 14,
              color: widget.isDark ? Colors.white : const Color(0xFF2B1E16),
            ),
          ),
          const SizedBox(height: 6),
          ...o.items.map(
            (item) => Padding(
              padding: const EdgeInsets.only(bottom: 4),
              child: Text(
                '• ${item.name} ×${item.quantity} — ${formatSum(item.price * item.quantity)} ${widget.l10n.currencySom}',
                style: TextStyle(
                  fontSize: 13,
                  height: 1.35,
                  color: widget.isDark ? Colors.white70 : Colors.brown.shade700,
                ),
              ),
            ),
          ),
          const SizedBox(height: 10),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                widget.l10n.cartRowTotal,
                style: TextStyle(
                  fontWeight: FontWeight.w800,
                  color: widget.isDark ? Colors.white70 : Colors.brown.shade700,
                ),
              ),
              Text(
                '${formatSum(o.totalPrice)} ${widget.l10n.currencySom}',
                style: const TextStyle(
                  fontWeight: FontWeight.w900,
                  fontSize: 18,
                  color: Color(0xFFFF8C00),
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),
          DropdownButtonFormField<String>(
            initialValue: _statuses.contains(_status) ? _status : 'pending',
            decoration: InputDecoration(
              labelText: widget.l10n.adminOrderStatusLabel,
              border: OutlineInputBorder(borderRadius: BorderRadius.circular(14)),
              contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
            ),
            items: _statuses
                .map(
                  (s) => DropdownMenuItem(
                    value: s,
                    child: Text(_statusLabel(s)),
                  ),
                )
                .toList(),
            onChanged: _updating ? null : _onStatusChanged,
          ),
          if (_updating)
            const Padding(
              padding: EdgeInsets.only(top: 10),
              child: LinearProgressIndicator(color: Color(0xFFFF8C00)),
            ),
        ],
      ),
    );
  }
}

class _InfoRow extends StatelessWidget {
  const _InfoRow({
    required this.icon,
    required this.label,
    required this.value,
    required this.isDark,
  });

  final IconData icon;
  final String label;
  final String value;
  final bool isDark;

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(icon, size: 18, color: const Color(0xFFFF8C00)),
        const SizedBox(width: 8),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w700,
                  color: isDark ? Colors.white54 : Colors.brown.shade500,
                ),
              ),
              Text(
                value,
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w700,
                  color: isDark ? Colors.white : const Color(0xFF2B1E16),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
