import 'package:flutter/material.dart';

import '../../../../core/l10n/app_l10n.dart';
import '../../../../core/services/firebase_error_mapper.dart';
import '../../../../l10n/generated/app_localizations.dart';
import '../../../../core/utils/validators.dart';
import '../../domain/repositories/feedback_repository.dart';

class SubmitFeedbackPage extends StatefulWidget {
  const SubmitFeedbackPage({super.key, required this.feedbackRepository});

  final FeedbackRepository feedbackRepository;

  @override
  State<SubmitFeedbackPage> createState() => _SubmitFeedbackPageState();
}

class _SubmitFeedbackPageState extends State<SubmitFeedbackPage> {
  final _formKey = GlobalKey<FormState>();
  final _messageCtrl = TextEditingController();
  int _rating = 5;
  bool _submitting = false;

  @override
  void dispose() {
    _messageCtrl.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    final l10n = context.l10n;
    if (_submitting) return;
    if (!(_formKey.currentState?.validate() ?? false)) return;
    FocusScope.of(context).unfocus();
    setState(() => _submitting = true);
    try {
      await widget.feedbackRepository.submitFeedback(message: _messageCtrl.text, rating: _rating);
      if (!mounted) return;
      await showDialog<void>(
        context: context,
        barrierDismissible: false,
        builder: (ctx) => AlertDialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(22)),
          title: Text(l10n.feedbackSuccessTitle),
          content: Text(l10n.feedbackSuccessBody),
          actions: [
            FilledButton(
              onPressed: () => Navigator.of(ctx).pop(),
              style: FilledButton.styleFrom(backgroundColor: const Color(0xFFFF8C00), foregroundColor: Colors.white),
              child: Text(l10n.feedbackSuccessOk),
            ),
          ],
        ),
      );
      if (mounted) Navigator.of(context).pop(true);
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(behavior: SnackBarBehavior.floating, content: Text(FirebaseErrorMapper.map(l10n, e))),
      );
    } finally {
      if (mounted) setState(() => _submitting = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final bg = isDark ? const Color(0xFF141018) : const Color(0xFFFFF9F0);
    final card = isDark ? const Color(0xFF1E1A22) : Colors.white;

    return Scaffold(
      backgroundColor: bg,
      appBar: AppBar(
        title: Text(l10n.feedbackPageTitle),
        backgroundColor: isDark ? const Color(0xFF1E1A22) : Colors.white,
        foregroundColor: isDark ? Colors.white : const Color(0xFF2B1E16),
        elevation: 0,
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(20, 12, 20, 28),
          physics: const BouncingScrollPhysics(),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                TweenAnimationBuilder<double>(
                  tween: Tween(begin: 0, end: 1),
                  duration: const Duration(milliseconds: 420),
                  curve: Curves.easeOutCubic,
                  builder: (context, t, child) => Opacity(opacity: t, child: Transform.translate(offset: Offset(0, 10 * (1 - t)), child: child)),
                  child: _CardShell(
                    color: card,
                    isDark: isDark,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(l10n.feedbackYourRating, style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 15)),
                        const SizedBox(height: 12),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: List.generate(5, (i) {
                            final n = i + 1;
                            final on = n <= _rating;
                            return Padding(
                              padding: const EdgeInsets.symmetric(horizontal: 4),
                              child: Material(
                                color: Colors.transparent,
                                child: InkWell(
                                  customBorder: const CircleBorder(),
                                  onTap: _submitting
                                      ? null
                                      : () {
                                          setState(() => _rating = n);
                                        },
                                  child: AnimatedScale(
                                    scale: on ? 1.08 : 1,
                                    duration: const Duration(milliseconds: 180),
                                    curve: Curves.easeOutBack,
                                    child: Icon(
                                      on ? Icons.star_rounded : Icons.star_border_rounded,
                                      size: 40,
                                      color: on ? const Color(0xFFFFB300) : (isDark ? Colors.white38 : Colors.brown.shade300),
                                    ),
                                  ),
                                ),
                              ),
                            );
                          }),
                        ),
                        const SizedBox(height: 22),
                        TextFormField(
                          controller: _messageCtrl,
                          minLines: 5,
                          maxLines: 10,
                          textCapitalization: TextCapitalization.sentences,
                          decoration: _messageDecoration(l10n, isDark),
                          validator: (v) => Validators.feedbackMessage(l10n, v),
                          enabled: !_submitting,
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 24),
                AnimatedSwitcher(
                  duration: const Duration(milliseconds: 200),
                  child: _submitting
                      ? const Center(
                          key: ValueKey('ld'),
                          child: Padding(
                            padding: EdgeInsets.symmetric(vertical: 14),
                            child: CircularProgressIndicator(color: Color(0xFFFF8C00)),
                          ),
                        )
                      : FilledButton(
                          key: const ValueKey('bt'),
                          onPressed: _submit,
                          style: FilledButton.styleFrom(
                            backgroundColor: const Color(0xFFFF8C00),
                            foregroundColor: Colors.white,
                            padding: const EdgeInsets.symmetric(vertical: 16),
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
                            elevation: 2,
                          ),
                          child: Text(l10n.feedbackSubmit, style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 16)),
                        ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  InputDecoration _messageDecoration(AppLocalizations l10n, bool isDark) {
    final border = OutlineInputBorder(borderRadius: BorderRadius.circular(18));
    return InputDecoration(
      alignLabelWithHint: true,
      labelText: l10n.feedbackMessageLabel,
      hintText: l10n.feedbackMessageHint,
      filled: true,
      fillColor: isDark ? const Color(0xFF26212C) : const Color(0xFFFFF8F0),
      border: border,
      enabledBorder: border.copyWith(
        borderSide: BorderSide(color: isDark ? const Color(0xFF3D3645) : const Color(0xFFFFE0B2)),
      ),
      focusedBorder: border.copyWith(
        borderSide: const BorderSide(color: Color(0xFFFF8C00), width: 1.6),
      ),
    );
  }
}

class _CardShell extends StatelessWidget {
  const _CardShell({required this.child, required this.color, required this.isDark});

  final Widget child;
  final Color color;
  final bool isDark;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: isDark ? 0.32 : 0.08),
            blurRadius: 22,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: child,
    );
  }
}
