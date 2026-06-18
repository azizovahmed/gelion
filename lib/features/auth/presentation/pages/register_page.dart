import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

import '../../../../app.dart';
import '../../../../core/l10n/app_l10n.dart';
import '../../../../core/locale/locale_controller.dart';
import '../../../../core/services/firebase_error_mapper.dart';
import '../../../../core/utils/validators.dart';
import '../../../home/presentation/pages/home_screen.dart';
import '../../domain/repositories/auth_repository.dart';
import '../widgets/auth_form_widgets.dart';
import 'login_page.dart';

class RegisterPage extends StatefulWidget {
  const RegisterPage({
    super.key,
    required this.authRepository,
    required this.onThemeChanged,
    required this.localeController,
  });

  final AuthRepository authRepository;
  final ValueChanged<ThemeMode> onThemeChanged;
  final LocaleController localeController;

  @override
  State<RegisterPage> createState() => _RegisterPageState();
}

class _RegisterPageState extends State<RegisterPage> {
  final _name = TextEditingController();
  final _phone = TextEditingController();
  final _email = TextEditingController();
  final _password = TextEditingController();
  final _formKey = GlobalKey<FormState>();
  bool _loading = false;
  bool _hide = true;

  @override
  void dispose() {
    _name.dispose();
    _phone.dispose();
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

  Future<void> _register() async {
    final l10n = context.l10n;
    if (!_formKey.currentState!.validate()) return;
    setState(() => _loading = true);
    try {
      await widget.authRepository.signUp(
        email: _email.text,
        password: _password.text,
        fullName: _name.text,
        phone: _phone.text,
      );
      await _goHome();
    } on FirebaseAuthException catch (e) {
      if (e.code == 'email-already-in-use') {
        try {
          await widget.authRepository.signIn(
            email: _email.text,
            password: _password.text,
          );
          await _goHome();
          return;
        } catch (signInError) {
          if (!mounted) return;
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(FirebaseErrorMapper.map(l10n, signInError))),
          );
          return;
        }
      }
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(FirebaseErrorMapper.map(l10n, e))),
      );
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(FirebaseErrorMapper.map(l10n, e))),
      );
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  void _openLogin() {
    Navigator.of(context).pushReplacement(
      FadeRoute(
        child: LoginPage(
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
              l10n.registerTitle,
              textAlign: TextAlign.center,
              style: const TextStyle(
                fontSize: 46,
                fontWeight: FontWeight.w900,
                color: Color(0xFF2B2018),
              ),
            ),
            const SizedBox(height: 8),
            Text(
              l10n.registerSubtitle,
              textAlign: TextAlign.center,
              style: const TextStyle(fontSize: 16, color: Color(0xFF4E4338)),
            ),
            const SizedBox(height: 14),
            AuthLabel(l10n.registerFullName),
            const SizedBox(height: 6),
            AuthField(
              controller: _name,
              hint: l10n.hintFullName,
              icon: Icons.person_outline_rounded,
              validator: (v) => Validators.requiredField(l10n, v, l10n.labelName),
            ),
            const SizedBox(height: 10),
            AuthLabel(l10n.registerPhone),
            const SizedBox(height: 6),
            AuthField(
              controller: _phone,
              hint: l10n.hintPhone,
              icon: Icons.phone_android_outlined,
              validator: (v) => Validators.requiredField(l10n, v, l10n.labelPhone),
              keyboardType: TextInputType.phone,
            ),
            const SizedBox(height: 10),
            AuthLabel(l10n.registerEmail),
            const SizedBox(height: 6),
            AuthField(
              controller: _email,
              hint: l10n.loginEmailHint,
              icon: Icons.email_outlined,
              validator: (v) => Validators.email(l10n, v),
              keyboardType: TextInputType.emailAddress,
            ),
            const SizedBox(height: 10),
            AuthLabel(l10n.registerPassword),
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
            const SizedBox(height: 14),
            AuthPrimaryButton(
              label: l10n.registerButton,
              loading: _loading,
              onPressed: _register,
            ),
            const SizedBox(height: 14),
            AuthDividerText(text: l10n.registerDivider),
            const SizedBox(height: 14),
            Row(
              children: [
                Expanded(
                  child: AuthSocialButton(
                    label: 'Google',
                    icon: Icons.g_mobiledata_rounded,
                    onTap: () => ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text(l10n.registerGoogleSoon)),
                    ),
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: AuthSocialButton(
                    label: 'Apple',
                    icon: Icons.apple_rounded,
                    onTap: () => ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text(l10n.registerAppleSoon)),
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
                  l10n.registerHaveAccount,
                  style: const TextStyle(color: Color(0xFF4E4338), fontSize: 15),
                ),
                GestureDetector(
                  onTap: _loading ? null : _openLogin,
                  child: Text(
                    l10n.registerLoginLink,
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
