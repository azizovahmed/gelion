import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../../../../core/l10n/app_l10n.dart';
import '../../../../core/services/firebase_error_mapper.dart';
import '../../../../l10n/generated/app_localizations.dart';
import '../../domain/entities/feedback_entry.dart';
import '../../domain/repositories/feedback_repository.dart';

class AdminFeedbacksPage extends StatelessWidget {
  const AdminFeedbacksPage({super.key, required this.feedbackRepository});

  final FeedbackRepository feedbackRepository;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final bg = isDark ? const Color(0xFF141018) : const Color(0xFFFFF9F0);

    return Scaffold(
      backgroundColor: bg,
      appBar: AppBar(
        title: Text(l10n.adminFeedbackTitle),
        backgroundColor: isDark ? const Color(0xFF1E1A22) : Colors.white,
        foregroundColor: isDark ? Colors.white : const Color(0xFF2B1E16),
        elevation: 0,
      ),
      body: StreamBuilder<List<FeedbackEntry>>(
        stream: feedbackRepository.watchFeedbacks(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting && !snapshot.hasData) {
            return const Center(child: CircularProgressIndicator(color: Color(0xFFFF8C00)));
          }
          if (snapshot.hasError) {
            final err = snapshot.error;
            final msg = err is FirebaseException ? '${err.code}: ${err.message}' : l10n.settingsSaveError;
            return Center(
              child: Padding(
                padding: const EdgeInsets.all(24),
                child: Text(msg, textAlign: TextAlign.center, style: TextStyle(color: isDark ? Colors.white70 : Colors.brown.shade800)),
              ),
            );
          }
          final list = snapshot.data ?? [];
          if (list.isEmpty) {
            return Center(
              child: Text(
                l10n.adminFeedbackEmpty,
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700, color: isDark ? Colors.white54 : Colors.brown.shade600),
              ),
            );
          }
          return ListView.separated(
            padding: const EdgeInsets.fromLTRB(16, 12, 16, 28),
            physics: const BouncingScrollPhysics(),
            itemCount: list.length,
            separatorBuilder: (context, index) => const SizedBox(height: 12),
            itemBuilder: (context, i) {
              final e = list[i];
              return _FeedbackAdminTile(
                entry: e,
                isDark: isDark,
                l10n: l10n,
                feedbackRepository: feedbackRepository,
              );
            },
          );
        },
      ),
    );
  }
}

class _FeedbackAdminTile extends StatelessWidget {
  const _FeedbackAdminTile({
    required this.entry,
    required this.isDark,
    required this.l10n,
    required this.feedbackRepository,
  });

  final FeedbackEntry entry;
  final bool isDark;
  final AppLocalizations l10n;
  final FeedbackRepository feedbackRepository;

  String _dateLine(BuildContext context) {
    final loc = Localizations.localeOf(context).toLanguageTag();
    return DateFormat.yMMMd(loc).add_Hm().format(entry.createdAt);
  }

  Future<void> _confirmDelete(BuildContext context) async {
    final ok = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: Text(l10n.adminFeedbackDeleteTitle),
        content: Text(l10n.adminFeedbackDeleteBody),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx, false), child: Text(l10n.profileCancel)),
          FilledButton(
            style: FilledButton.styleFrom(backgroundColor: const Color(0xFFE65100)),
            onPressed: () => Navigator.pop(ctx, true),
            child: Text(l10n.adminFeedbackDelete),
          ),
        ],
      ),
    );
    if (ok != true || !context.mounted) return;
    try {
      await feedbackRepository.deleteFeedback(entry.id);
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(behavior: SnackBarBehavior.floating, content: Text(l10n.adminFeedbackDeleted)));
      }
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(behavior: SnackBarBehavior.floating, content: Text(FirebaseErrorMapper.map(l10n, e))),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final card = isDark ? const Color(0xFF1E1A22) : Colors.white;
    return AnimatedContainer(
      duration: const Duration(milliseconds: 220),
      decoration: BoxDecoration(
        color: card,
        borderRadius: BorderRadius.circular(22),
        border: entry.read
            ? null
            : const Border(
                left: BorderSide(color: Color(0xFFFF8C00), width: 4),
              ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: isDark ? 0.28 : 0.07),
            blurRadius: 16,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: Padding(
          padding: const EdgeInsets.fromLTRB(16, 14, 8, 14),
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
                          entry.fullName,
                          style: TextStyle(
                            fontWeight: FontWeight.w900,
                            fontSize: 17,
                            color: isDark ? Colors.white : const Color(0xFF2B1E16),
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(entry.email, style: TextStyle(fontSize: 13, color: isDark ? Colors.white60 : Colors.brown.shade600)),
                        const SizedBox(height: 8),
                        Row(
                          children: List.generate(
                            5,
                            (i) => Icon(
                              i < entry.rating ? Icons.star_rounded : Icons.star_border_rounded,
                              size: 20,
                              color: const Color(0xFFFFB300),
                            ),
                          ),
                        ),
                        const SizedBox(height: 6),
                        Text(
                          _dateLine(context),
                          style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: isDark ? Colors.white38 : Colors.brown.shade500),
                        ),
                      ],
                    ),
                  ),
                  Column(
                    children: [
                      IconButton(
                        tooltip: entry.read ? l10n.adminFeedbackMarkUnread : l10n.adminFeedbackMarkRead,
                        onPressed: () => feedbackRepository.setFeedbackRead(entry.id, read: !entry.read),
                        icon: Icon(entry.read ? Icons.mark_email_unread_outlined : Icons.mark_email_read_outlined),
                        color: const Color(0xFFFF8C00),
                      ),
                      IconButton(
                        tooltip: l10n.adminFeedbackDelete,
                        onPressed: () => _confirmDelete(context),
                        icon: const Icon(Icons.delete_outline_rounded),
                        color: const Color(0xFFE65100),
                      ),
                    ],
                  ),
                ],
              ),
              const SizedBox(height: 10),
              Text(
                entry.message,
                style: TextStyle(height: 1.45, fontSize: 15, color: isDark ? Colors.white.withValues(alpha: 0.92) : const Color(0xFF3E2723)),
              ),
              if (entry.deviceInfo != null && entry.deviceInfo!.isNotEmpty) ...[
                const SizedBox(height: 8),
                Text(
                  entry.deviceInfo!,
                  style: TextStyle(fontSize: 11, color: isDark ? Colors.white38 : Colors.brown.shade400),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}
