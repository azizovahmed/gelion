import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/constants/legal_urls.dart';
import '../../../../core/l10n/app_l10n.dart';
import '../../../../core/utils/legal_url_launcher.dart';
import '../../../../core/services/firebase_error_mapper.dart';
import '../../../../core/utils/validators.dart';
import '../../../auth/domain/entities/app_user.dart';
import '../../../auth/domain/repositories/auth_repository.dart';
import '../../../feedback/domain/repositories/feedback_repository.dart';
import '../../../feedback/presentation/pages/submit_feedback_page.dart';
import 'change_password_page.dart';

class AccountSettingsPage extends ConsumerStatefulWidget {
  const AccountSettingsPage({
    super.key,
    required this.authRepository,
    required this.feedbackRepository,
    required this.onThemeChanged,
  });

  final AuthRepository authRepository;
  final FeedbackRepository feedbackRepository;
  final ValueChanged<ThemeMode> onThemeChanged;

  @override
  ConsumerState<AccountSettingsPage> createState() => _AccountSettingsPageState();
}

class _AccountSettingsPageState extends ConsumerState<AccountSettingsPage> {
  final _formKey = GlobalKey<FormState>();
  final _nameCtrl = TextEditingController();
  final _phoneCtrl = TextEditingController();
  final _emailCtrl = TextEditingController();
  bool _loadingProfile = true;
  bool _saving = false;
  String? _initialEmail;
  bool _isAdmin = false;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    setState(() => _loadingProfile = true);
    try {
      final r = await Future.wait<dynamic>([
        widget.authRepository.currentUserProfile(),
        widget.feedbackRepository.isCurrentUserAdmin(),
      ]);
      if (!mounted) return;
      final u = r[0] as AppUser?;
      final admin = r[1] as bool;
      _nameCtrl.text = u?.fullName ?? '';
      _phoneCtrl.text = u?.phone ?? '';
      _emailCtrl.text = u?.email ?? '';
      _initialEmail = (u?.email ?? '').trim().toLowerCase();
      _isAdmin = admin;
    } finally {
      if (mounted) setState(() => _loadingProfile = false);
    }
  }

  @override
  void dispose() {
    _nameCtrl.dispose();
    _phoneCtrl.dispose();
    _emailCtrl.dispose();
    super.dispose();
  }

  Future<void> _openLegal(String url) => LegalUrlLauncher.openHttpsExternal(context, url);

  void _openChangePassword() {
    Navigator.of(context).push<void>(
      PageRouteBuilder<void>(
        pageBuilder: (context, animation, secondaryAnimation) => ChangePasswordPage(authRepository: widget.authRepository),
        transitionsBuilder: (context, animation, secondaryAnimation, child) {
          final curve = CurvedAnimation(parent: animation, curve: Curves.easeOutCubic);
          return FadeTransition(
            opacity: curve,
            child: SlideTransition(
              position: Tween<Offset>(begin: const Offset(0.06, 0), end: Offset.zero).animate(curve),
              child: child,
            ),
          );
        },
      ),
    );
  }

  void _openSubmitFeedback() {
    Navigator.of(context).push<void>(
      PageRouteBuilder<void>(
        pageBuilder: (context, animation, secondaryAnimation) => SubmitFeedbackPage(feedbackRepository: widget.feedbackRepository),
        transitionsBuilder: (context, animation, secondaryAnimation, child) {
          final curve = CurvedAnimation(parent: animation, curve: Curves.easeOutCubic);
          return FadeTransition(
            opacity: curve,
            child: SlideTransition(
              position: Tween<Offset>(begin: const Offset(0.06, 0), end: Offset.zero).animate(curve),
              child: child,
            ),
          );
        },
      ),
    );
  }





  Future<void> _save() async {
    final l10n = context.l10n;
    if (_saving || _loadingProfile) return;
    if (!(_formKey.currentState?.validate() ?? false)) return;
    FocusScope.of(context).unfocus();
    setState(() => _saving = true);
    try {
      await widget.authRepository.updateUserProfile(
        fullName: _nameCtrl.text,
        phone: _phoneCtrl.text,
        email: _emailCtrl.text,
      );
      if (!mounted) return;
      final newEmail = _emailCtrl.text.trim().toLowerCase();
      final emailChanged = _initialEmail != null && newEmail != _initialEmail;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          behavior: SnackBarBehavior.floating,
          content: Text(
            emailChanged ? '${l10n.settingsSaved} ${l10n.settingsVerifyEmailSent}' : l10n.settingsSaved,
          ),
        ),
      );
      setState(() => _initialEmail = newEmail);
      Navigator.of(context).pop(true);
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          behavior: SnackBarBehavior.floating,
          content: Text(FirebaseErrorMapper.map(l10n, e)),
        ),
      );
    } finally {
      if (mounted) setState(() => _saving = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final bg = isDark ? const Color(0xFF141018) : const Color(0xFFFFF9F0);
    final card = isDark ? const Color(0xFF1E1A22) : Colors.white;
    final themeMode = Theme.of(context).brightness == Brightness.dark ? ThemeMode.dark : ThemeMode.light;

    return Scaffold(
      backgroundColor: bg,
      appBar: AppBar(
        title: Text(l10n.settingsTitle),
        backgroundColor: isDark ? const Color(0xFF1E1A22) : Colors.white,
        foregroundColor: isDark ? Colors.white : const Color(0xFF2B1E16),
        elevation: 0,
      ),
      body: _loadingProfile
          ? const Center(child: CircularProgressIndicator(color: Color(0xFFFF8C00)))
          : SafeArea(
              child: Form(
                key: _formKey,
                child: ListView(
                  padding: const EdgeInsets.fromLTRB(18, 8, 18, 32),
                  physics: const BouncingScrollPhysics(),
                  children: [
                    _SectionTitle(text: l10n.settingsTheme),
                    const SizedBox(height: 8),
                    _Card(
                      color: card,
                      isDark: isDark,
                      child: SegmentedButton<ThemeMode>(
                        segments: [
                          ButtonSegment(value: ThemeMode.light, label: Text(l10n.settingsThemeLight)),
                          ButtonSegment(value: ThemeMode.dark, label: Text(l10n.settingsThemeDark)),
                        ],
                        selected: {themeMode},
                        onSelectionChanged: (s) => widget.onThemeChanged(s.first),
                        style: ButtonStyle(
                          visualDensity: VisualDensity.compact,
                          shape: WidgetStateProperty.all(RoundedRectangleBorder(borderRadius: BorderRadius.circular(14))),
                        ),
                      ),
                    ),
                    const SizedBox(height: 22),
                    _SectionTitle(text: l10n.settingsSectionPersonal),
                    const SizedBox(height: 8),
                    _Card(
                      color: card,
                      isDark: isDark,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          TextFormField(
                            controller: _nameCtrl,
                            textInputAction: TextInputAction.next,
                            textCapitalization: TextCapitalization.words,
                            decoration: _fieldDecoration(l10n.settingsFullName, l10n.hintFullName, isDark),
                            validator: (v) => Validators.requiredField(l10n, v, l10n.settingsFullName),
                          ),
                          const SizedBox(height: 14),
                          TextFormField(
                            controller: _phoneCtrl,
                            keyboardType: TextInputType.phone,
                            textInputAction: TextInputAction.next,
                            decoration: _fieldDecoration(l10n.settingsPhone, l10n.hintPhone, isDark),
                            validator: (v) => Validators.phone(l10n, v),
                          ),
                          const SizedBox(height: 14),
                          TextFormField(
                            controller: _emailCtrl,
                            keyboardType: TextInputType.emailAddress,
                            textInputAction: TextInputAction.done,
                            decoration: _fieldDecoration(l10n.settingsEmail, l10n.loginEmailHint, isDark),
                            validator: (v) => Validators.email(l10n, v),
                          ),
                          const SizedBox(height: 20),
                          AnimatedSwitcher(
                            duration: const Duration(milliseconds: 200),
                            child: _saving
                                ? const Center(
                                    key: ValueKey('sv'),
                                    child: Padding(
                                      padding: EdgeInsets.symmetric(vertical: 10),
                                      child: CircularProgressIndicator(color: Color(0xFFFF8C00)),
                                    ),
                                  )
                                : FilledButton(
                                    key: const ValueKey('btn'),
                                    onPressed: _saving ? null : _save,
                                    style: FilledButton.styleFrom(
                                      backgroundColor: const Color(0xFFFF8C00),
                                      foregroundColor: Colors.white,
                                      padding: const EdgeInsets.symmetric(vertical: 16),
                                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
                                      elevation: 2,
                                    ),
                                    child: Text(l10n.settingsSave, style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 16)),
                                  ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 22),
                    _SectionTitle(text: l10n.settingsSectionSecurity),
                    const SizedBox(height: 8),
                    _ActionTile(
                      icon: Icons.lock_reset_rounded,
                      title: l10n.settingsPasswordChange,
                      subtitle: l10n.settingsPasswordChangeSubtitle,
                      isDark: isDark,
                      card: card,
                      onTap: _openChangePassword,
                    ),
                    const SizedBox(height: 22),
                    _SectionTitle(text: l10n.settingsSectionFeedback),
                    const SizedBox(height: 8),
                    _ActionTile(
                      icon: Icons.rate_review_rounded,
                      title: l10n.feedbackSendTitle,
                      subtitle: l10n.feedbackSendSubtitle,
                      isDark: isDark,
                      card: card,
                      onTap: _openSubmitFeedback,
                    ),

                    const SizedBox(height: 22),
                    _SectionTitle(text: l10n.settingsSectionAbout),
                    const SizedBox(height: 8),
                    _ActionTile(
                      icon: Icons.privacy_tip_outlined,
                      title: l10n.settingsPrivacy,
                      subtitle: l10n.settingsPrivacySubtitle,
                      isDark: isDark,
                      card: card,
                      onTap: () => _openLegal(LegalUrls.privacyPolicy),
                    ),
                    const SizedBox(height: 10),
                    _ActionTile(
                      icon: Icons.article_outlined,
                      title: l10n.settingsTerms,
                      subtitle: l10n.settingsTermsSubtitle,
                      isDark: isDark,
                      card: card,
                      onTap: () => _openLegal(LegalUrls.termsOfUse),
                    ),
                  ],
                ),
              ),
            ),
    );
  }

  InputDecoration _fieldDecoration(String label, String hint, bool isDark) {
    final border = OutlineInputBorder(borderRadius: BorderRadius.circular(16));
    return InputDecoration(
      labelText: label,
      hintText: hint,
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

class _SectionTitle extends StatelessWidget {
  const _SectionTitle({required this.text});

  final String text;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Text(
      text,
      style: TextStyle(
        fontSize: 15,
        fontWeight: FontWeight.w900,
        letterSpacing: -0.2,
        color: isDark ? Colors.white : const Color(0xFF2B1E16),
      ),
    );
  }
}

class _Card extends StatelessWidget {
  const _Card({required this.child, required this.color, required this.isDark});

  final Widget child;
  final Color color;
  final bool isDark;

  @override
  Widget build(BuildContext context) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 220),
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: isDark ? 0.32 : 0.07),
            blurRadius: 18,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: child,
    );
  }
}

class _ActionTile extends StatelessWidget {
  const _ActionTile({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.isDark,
    required this.card,
    required this.onTap,
    this.badgeCount,
  });

  final IconData icon;
  final String title;
  final String subtitle;
  final bool isDark;
  final Color card;
  final VoidCallback onTap;
  final int? badgeCount;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: card,
      borderRadius: BorderRadius.circular(22),
      child: InkWell(
        borderRadius: BorderRadius.circular(22),
        onTap: onTap,
        child: Container(
          width: double.infinity,
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(22),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: isDark ? 0.28 : 0.06),
                blurRadius: 14,
                offset: const Offset(0, 7),
              ),
            ],
          ),
          child: Row(
            children: [
              Icon(icon, color: const Color(0xFFFF8C00), size: 26),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: TextStyle(
                        fontWeight: FontWeight.w800,
                        fontSize: 16,
                        color: isDark ? Colors.white : const Color(0xFF2B1E16),
                      ),
                    ),
                    Text(
                      subtitle,
                      style: TextStyle(color: isDark ? Colors.white60 : Colors.brown.shade600, fontSize: 13),
                    ),
                  ],
                ),
              ),
              if (badgeCount != null && badgeCount! > 0) ...[
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: const Color(0xFFEF5350),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    badgeCount! > 99 ? '99+' : '$badgeCount',
                    style: const TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.w900,
                      fontSize: 12,
                    ),
                  ),
                ),
                const SizedBox(width: 6),
              ],
              const Icon(Icons.chevron_right_rounded),
            ],
          ),
        ),
      ),
    );
  }
}
