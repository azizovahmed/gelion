import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/l10n/app_l10n.dart';
import '../../application/order_providers.dart';
import '../../data/firebase_order_repository.dart';
import '../../data/order_user_scope.dart';
import '../../domain/entities/app_order.dart';
import '../theme/order_presentation_theme.dart';
import '../widgets/order_history_card.dart';
import '../widgets/order_history_empty_state.dart';
import '../widgets/order_shimmer.dart';
import 'order_detail_page.dart';

enum _OrderDateFilter { all, today, week, month }

/// Profil → Buyurtmalar tarixi (faqat joriy auth user).
class UserOrderHistoryPage extends ConsumerStatefulWidget {
  const UserOrderHistoryPage({
    super.key,
    this.onStartShopping,
  });

  final VoidCallback? onStartShopping;

  @override
  ConsumerState<UserOrderHistoryPage> createState() => _UserOrderHistoryPageState();
}

class _UserOrderHistoryPageState extends ConsumerState<UserOrderHistoryPage> {
  final _searchCtrl = TextEditingController();
  String _searchQuery = '';
  _OrderDateFilter _dateFilter = _OrderDateFilter.all;
  List<AppOrder> _cachedOrders = const [];

  @override
  void initState() {
    super.initState();
    _searchCtrl.addListener(() {
      setState(() => _searchQuery = _searchCtrl.text.trim().toUpperCase());
    });
    WidgetsBinding.instance.addPostFrameCallback((_) => _loadCache());
  }

  @override
  void dispose() {
    _searchCtrl.dispose();
    super.dispose();
  }

  Future<void> _loadCache() async {
    final uid = ref.read(currentUserIdProvider);
    if (uid.isEmpty) return;
    final cached = await ref.read(cachedUserOrdersProvider.future);
    if (!mounted) return;
    if (cached.isNotEmpty) {
      setState(() => _cachedOrders = cached);
    }
  }

  void _onAuthChanged(String? prev, String next) {
    if (prev == next) return;
    setState(() => _cachedOrders = const []);
    ref.invalidate(userOrdersProvider);
    ref.invalidate(cachedUserOrdersProvider);
    ref.read(userOrdersLimitProvider.notifier).state =
        FirebaseOrderRepository.defaultPageSize;
    if (next.isNotEmpty) {
      _loadCache();
    }
  }

  List<AppOrder> _applyFilters(List<AppOrder> source) {
    final uid = ref.read(currentUserIdProvider);
    var list = filterOrdersForUser(source, uid);
    final now = DateTime.now();

    list = switch (_dateFilter) {
      _OrderDateFilter.today => list.where((o) {
        final d = o.createdAt;
        return d.year == now.year && d.month == now.month && d.day == now.day;
      }).toList(),
      _OrderDateFilter.week => list
          .where((o) => now.difference(o.createdAt).inDays <= 7)
          .toList(),
      _OrderDateFilter.month => list
          .where((o) => now.difference(o.createdAt).inDays <= 30)
          .toList(),
      _OrderDateFilter.all => list,
    };

    if (_searchQuery.isNotEmpty) {
      final q = _searchQuery.replaceAll('#', '');
      list = list
          .where((o) => o.displayNumber.toUpperCase().contains(q))
          .toList();
    }

    return list;
  }

  Future<void> _onRefresh() async {
    ref.read(userOrdersLimitProvider.notifier).state =
        FirebaseOrderRepository.defaultPageSize;
    ref.invalidate(userOrdersProvider);
    await Future<void>.delayed(const Duration(milliseconds: 400));
  }

  void _loadMore() {
    final current = ref.read(userOrdersLimitProvider);
    ref.read(userOrdersLimitProvider.notifier).state = current + 20;
  }

  void _openDetail(AppOrder order) {
    final uid = ref.read(currentUserIdProvider);
    if (uid.isEmpty || order.userId.trim().isNotEmpty && order.userId != uid) {
      return;
    }
    Navigator.of(context).push<void>(
      PageRouteBuilder<void>(
        pageBuilder: (_, animation, __) => OrderDetailPage(order: order),
        transitionsBuilder: (_, animation, __, child) {
          final curve = CurvedAnimation(parent: animation, curve: Curves.easeOutCubic);
          return FadeTransition(
            opacity: curve,
            child: SlideTransition(
              position: Tween<Offset>(
                begin: const Offset(0.04, 0),
                end: Offset.zero,
              ).animate(curve),
              child: child,
            ),
          );
        },
        transitionDuration: const Duration(milliseconds: 320),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final userId = ref.watch(currentUserIdProvider);

    ref.listen<String>(currentUserIdProvider, _onAuthChanged);

    if (userId.isEmpty) {
      return Scaffold(
        backgroundColor: OrderPresentationTheme.cream,
        appBar: _appBar(l10n),
        body: Center(
          child: Padding(
            padding: const EdgeInsets.all(28),
            child: Text(
              l10n.orderHistoryAuthRequired,
              textAlign: TextAlign.center,
              style: TextStyle(
                fontWeight: FontWeight.w700,
                color: OrderPresentationTheme.brown.withValues(alpha: 0.9),
              ),
            ),
          ),
        ),
      );
    }

    final limit = ref.watch(userOrdersLimitProvider);
    final ordersAsync = ref.watch(userOrdersProvider);
    final showOfflineBanner =
        ordersAsync.hasError && _cachedOrders.isNotEmpty;

    return Scaffold(
      backgroundColor: OrderPresentationTheme.cream,
      appBar: _appBar(l10n),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          if (showOfflineBanner)
            Material(
              color: OrderPresentationTheme.orange.withValues(alpha: 0.12),
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                child: Row(
                  children: [
                    const Icon(Icons.cloud_off_rounded, color: OrderPresentationTheme.orange, size: 20),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        l10n.orderHistoryOffline,
                        style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 13),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 12, 20, 0),
            child: TextField(
              controller: _searchCtrl,
              decoration: InputDecoration(
                hintText: l10n.orderHistorySearchHint,
                prefixIcon: const Icon(Icons.search_rounded, color: OrderPresentationTheme.orange),
                filled: true,
                fillColor: OrderPresentationTheme.white,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(18),
                  borderSide: BorderSide.none,
                ),
                contentPadding: const EdgeInsets.symmetric(vertical: 12),
              ),
            ),
          ),
          const SizedBox(height: 10),
          SizedBox(
            height: 40,
            child: ListView(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: 20),
              children: [
                _FilterChip(
                  label: l10n.orderFilterAll,
                  selected: _dateFilter == _OrderDateFilter.all,
                  onTap: () => setState(() => _dateFilter = _OrderDateFilter.all),
                ),
                const SizedBox(width: 8),
                _FilterChip(
                  label: l10n.orderFilterToday,
                  selected: _dateFilter == _OrderDateFilter.today,
                  onTap: () => setState(() => _dateFilter = _OrderDateFilter.today),
                ),
                const SizedBox(width: 8),
                _FilterChip(
                  label: l10n.orderFilterWeek,
                  selected: _dateFilter == _OrderDateFilter.week,
                  onTap: () => setState(() => _dateFilter = _OrderDateFilter.week),
                ),
                const SizedBox(width: 8),
                _FilterChip(
                  label: l10n.orderFilterMonth,
                  selected: _dateFilter == _OrderDateFilter.month,
                  onTap: () => setState(() => _dateFilter = _OrderDateFilter.month),
                ),
              ],
            ),
          ),
          const SizedBox(height: 8),
          Expanded(
            child: ordersAsync.when(
              loading: () {
                if (_cachedOrders.isNotEmpty) {
                  final filtered = _applyFilters(_cachedOrders);
                  return _OrderList(
                    orders: filtered,
                    onRefresh: _onRefresh,
                    onTap: _openDetail,
                    onLoadMore: _loadMore,
                    canLoadMore: filtered.length >= limit,
                    showLoadMore: true,
                  );
                }
                return const OrderListShimmer();
              },
              error: (err, _) {
                final fallback = _applyFilters(_cachedOrders);
                if (fallback.isEmpty) {
                  return _ErrorBody(
                    message: l10n.orderHistoryLoadFailed,
                    onRetry: () => ref.invalidate(userOrdersProvider),
                  );
                }
                return _OrderList(
                  orders: fallback,
                  onRefresh: _onRefresh,
                  onTap: _openDetail,
                  onLoadMore: _loadMore,
                  canLoadMore: false,
                  showLoadMore: false,
                );
              },
              data: (orders) {
                final filtered = _applyFilters(orders);
                if (filtered.isEmpty) {
                  return RefreshIndicator(
                    color: OrderPresentationTheme.orange,
                    onRefresh: _onRefresh,
                    child: ListView(
                      physics: const AlwaysScrollableScrollPhysics(
                        parent: BouncingScrollPhysics(),
                      ),
                      children: [
                        SizedBox(
                          height: MediaQuery.sizeOf(context).height * 0.55,
                          child: OrderHistoryEmptyState(
                            onPlaceOrder: widget.onStartShopping == null
                                ? null
                                : () {
                                    Navigator.of(context).pop();
                                    widget.onStartShopping!();
                                  },
                          ),
                        ),
                      ],
                    ),
                  );
                }
                return _OrderList(
                  orders: filtered,
                  onRefresh: _onRefresh,
                  onTap: _openDetail,
                  onLoadMore: _loadMore,
                  canLoadMore: orders.length >= limit,
                  showLoadMore: true,
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  PreferredSizeWidget _appBar(dynamic l10n) {
    return AppBar(
      backgroundColor: OrderPresentationTheme.white,
      foregroundColor: OrderPresentationTheme.brownDark,
      elevation: 0,
      title: Text(
        l10n.orderHistoryTitle,
        style: const TextStyle(fontWeight: FontWeight.w800),
      ),
    );
  }
}

class _FilterChip extends StatelessWidget {
  const _FilterChip({
    required this.label,
    required this.selected,
    required this.onTap,
  });

  final String label;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return FilterChip(
      label: Text(label, style: TextStyle(fontWeight: selected ? FontWeight.w800 : FontWeight.w600)),
      selected: selected,
      onSelected: (_) => onTap(),
      selectedColor: OrderPresentationTheme.orange.withValues(alpha: 0.2),
      checkmarkColor: OrderPresentationTheme.orange,
      backgroundColor: OrderPresentationTheme.white,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
    );
  }
}

class _OrderList extends StatelessWidget {
  const _OrderList({
    required this.orders,
    required this.onRefresh,
    required this.onTap,
    required this.onLoadMore,
    required this.canLoadMore,
    required this.showLoadMore,
  });

  final List<AppOrder> orders;
  final Future<void> Function() onRefresh;
  final void Function(AppOrder) onTap;
  final VoidCallback onLoadMore;
  final bool canLoadMore;
  final bool showLoadMore;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    return RefreshIndicator(
      color: OrderPresentationTheme.orange,
      onRefresh: onRefresh,
      child: ListView.separated(
        padding: const EdgeInsets.fromLTRB(20, 8, 20, 32),
        physics: const AlwaysScrollableScrollPhysics(
          parent: BouncingScrollPhysics(),
        ),
        itemCount: orders.length + (showLoadMore && canLoadMore ? 1 : 0),
        separatorBuilder: (_, __) => const SizedBox(height: 12),
        itemBuilder: (context, index) {
          if (index >= orders.length) {
            return Padding(
              padding: const EdgeInsets.only(top: 8),
              child: OutlinedButton(
                onPressed: onLoadMore,
                style: OutlinedButton.styleFrom(
                  foregroundColor: OrderPresentationTheme.orange,
                  side: const BorderSide(color: OrderPresentationTheme.orange),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(18),
                  ),
                ),
                child: Text(l10n.orderHistoryLoadMore, style: const TextStyle(fontWeight: FontWeight.w800)),
              ),
            );
          }
          final order = orders[index];
          return AnimatedSwitcher(
            duration: const Duration(milliseconds: 220),
            child: OrderHistoryCard(
              key: ValueKey<String>(order.id),
              order: order,
              onTap: () => onTap(order),
            ),
          );
        },
      ),
    );
  }
}

class _ErrorBody extends StatelessWidget {
  const _ErrorBody({required this.message, required this.onRetry});

  final String message;
  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.error_outline_rounded, size: 48, color: OrderPresentationTheme.orange),
            const SizedBox(height: 12),
            Text(message, textAlign: TextAlign.center),
            const SizedBox(height: 16),
            FilledButton(
              onPressed: onRetry,
              style: FilledButton.styleFrom(backgroundColor: OrderPresentationTheme.orange),
              child: Text(l10n.orderHistoryRetry),
            ),
          ],
        ),
      ),
    );
  }
}
