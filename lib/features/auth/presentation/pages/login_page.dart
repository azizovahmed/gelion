import 'package:flutter/material.dart';

import '../../../../app.dart';
import '../../../../core/l10n/app_l10n.dart';
import '../../../../core/locale/locale_controller.dart';
import '../../../../core/services/firebase_error_mapper.dart';
import '../../../../core/utils/validators.dart';
import '../../../home/presentation/pages/home_screen.dart';
import '../../domain/repositories/auth_repository.dart';
import '../widgets/auth_form_widgets.dart';
import 'register_page.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({
    super.key,
    required this.authRepository,
    required this.onThemeChanged,
    required this.localeController,
  });

  final AuthRepository authRepository;
  final ValueChanged<ThemeMode> onThemeChanged;
  final LocaleController localeController;

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final _email = TextEditingController();
  final _password = TextEditingController();
  final _formKey = GlobalKey<FormState>();
  bool _loading = false;
  bool _hide = true;

  @override
  void dispose() {
    _email.dispose();
    _password.dispose();
    super.dispose();
  }

  Future<void> _goHome() async {
    if (!mounted) return;
    await Navigator.of(context, rootNavigator: true).pushAndRemoveUntil(
      FadeRoute(
        child: HomeScreen(
          authRepository: widget.authRepository,
          onThemeChanged: widget.onThemeChanged,
          localeController: widget.localeController,
        ),
      ),
      (route) => false,
    );
  }

  Future<void> _login() async {
    final l10n = context.l10n;
    if (!_formKey.currentState!.validate()) return;
    setState(() => _loading = true);
    try {
      await widget.authRepository.signIn(
        email: _email.text,
        password: _password.text,
      );
      await _goHome();
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(FirebaseErrorMapper.map(l10n, e))),
      );
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  Future<void> _resetPassword() async {
    final l10n = context.l10n;
    final email = _email.text.trim();
    if (email.isEmpty || Validators.email(l10n, email) != null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(l10n.loginResetEnterEmail)),
      );
      return;
    }
    try {
      await widget.authRepository.sendResetPassword(email: email);
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(l10n.loginResetSent)),
      );
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(FirebaseErrorMapper.map(l10n, e))),
      );
    }
  }

  void _openRegister() {
    Navigator.of(context).push(
      FadeRoute(
        child: RegisterPage(
          authRepository: widget.authRepository,
          onThemeChanged: widget.onThemeChanged,
          localeController: widget.localeController,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    return AuthCardShell(
      child: Form(
        key: _formKey,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(
              l10n.appTitle,
              textAlign: TextAlign.center,
              style: const TextStyle(
                fontSize: 46,
                fontWeight: FontWeight.w900,
                color: Color(0xFF2B2018),
              ),
            ),
            const SizedBox(height: 8),
            Text(
              l10n.loginWelcomeSubtitle,
              textAlign: TextAlign.center,
              style: const TextStyle(fontSize: 16, color: Color(0xFF4E4338)),
            ),
            const SizedBox(height: 20),
            AuthLabel(l10n.loginEmailLabel),
            const SizedBox(height: 6),
            AuthField(
              controller: _email,
              hint: l10n.loginEmailHint,
              icon: Icons.email_outlined,
              validator: (v) => Validators.email(l10n, v),
              keyboardType: TextInputType.emailAddress,
            ),
            const SizedBox(height: 10),
            AuthLabel(l10n.loginPasswordLabel),
            const SizedBox(height: 6),
            AuthField(
              controller: _password,
              hint: l10n.loginPasswordHint,
              icon: Icons.lock_outline_rounded,
              validator: (v) => Validators.password(l10n, v),
              obscureText: _hide,
              suffix: IconButton(
                onPressed: () => setState(() => _hide = !_hide),
                icon: Icon(
                  _hide ? Icons.visibility_outlined : Icons.visibility_off_outlined,
                  color: const Color(0xFF8E7E6D),
                ),
              ),
            ),
            const SizedBox(height: 8),
            Align(
              alignment: Alignment.centerRight,
              child: TextButton(
                onPressed: _loading ? null : _resetPassword,
                child: Text(
                  l10n.loginForgotPassword,
                  style: const TextStyle(
                    fontWeight: FontWeight.w700,
                    color: Color(0xFFFF8C00),
                  ),
                ),
              ),
            ),
            const SizedBox(height: 6),
            AuthPrimaryButton(
              label: l10n.loginButton,
              loading: _loading,
              onPressed: _login,
            ),
            const SizedBox(height: 14),
            AuthDividerText(text: l10n.loginDivider),
            const SizedBox(height: 14),
            Row(
              children: [
                Expanded(
                  child: AuthSocialButton(
                    label: 'Google',
                    icon: Icons.g_mobiledata_rounded,
                    onTap: () => ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text(l10n.loginGoogleSoon)),
                    ),
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: AuthSocialButton(
                    label: 'Apple',
                    icon: Icons.apple_rounded,
                    onTap: () => ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text(l10n.loginAppleSoon)),
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  l10n.loginNoAccount,
                  style: const TextStyle(color: Color(0xFF4E4338), fontSize: 15),
                ),
                GestureDetector(
                  onTap: _loading ? null : _openRegister,
                  child: Text(
                    l10n.loginRegisterLink,
                    style: const TextStyle(
                      color: Color(0xFFFF8C00),
                      fontWeight: FontWeight.w800,
                      fontSize: 15,
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
