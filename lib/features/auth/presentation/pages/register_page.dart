import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import '../../../../app.dart';
import '../../../../core/l10n/app_l10n.dart';
import '../../../../core/locale/locale_controller.dart';
import '../../../../core/services/firebase_error_mapper.dart';
import '../../../../core/utils/validators.dart';
import '../../../home/presentation/pages/home_screen.dart';
import '../../domain/repositories/auth_repository.dart';
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
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(FirebaseErrorMapper.map(l10n, e))));
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(FirebaseErrorMapper.map(l10n, e))));
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          image: DecorationImage(
            image: AssetImage('assets/onboarding_delivery.png'),
            fit: BoxFit.cover,
          ),
        ),
        child: SafeArea(
          child: Center(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(20),
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 560),
                child: Container(
                  padding: const EdgeInsets.fromLTRB(20, 20, 20, 20),
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.92),
                    borderRadius: BorderRadius.circular(34),
                    border: Border.all(color: const Color(0xFFFFE8CD)),
                  ),
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
                        _Label(l10n.registerFullName),
                        const SizedBox(height: 6),
                        _AuthField(
                          controller: _name,
                          hint: l10n.hintFullName,
                          icon: Icons.person_outline_rounded,
                          validator: (v) => Validators.requiredField(l10n, v, l10n.labelName),
                        ),
                        const SizedBox(height: 10),
                        _Label(l10n.registerPhone),
                        const SizedBox(height: 6),
                        _AuthField(
                          controller: _phone,
                          hint: l10n.hintPhone,
                          icon: Icons.phone_android_outlined,
                          validator: (v) => Validators.requiredField(l10n, v, l10n.labelPhone),
                          keyboardType: TextInputType.phone,
                        ),
                        const SizedBox(height: 10),
                        _Label(l10n.registerEmail),
                        const SizedBox(height: 6),
                        _AuthField(
                          controller: _email,
                          hint: l10n.loginEmailHint,
                          icon: Icons.email_outlined,
                          validator: (v) => Validators.email(l10n, v),
                          keyboardType: TextInputType.emailAddress,
                        ),
                        const SizedBox(height: 10),
                        _Label(l10n.registerPassword),
                        const SizedBox(height: 6),
                        _AuthField(
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
                        _PrimaryActionButton(
                          label: l10n.registerButton,
                          loading: _loading,
                          onPressed: _register,
                        ),
                        const SizedBox(height: 14),
                        _DividerText(text: l10n.registerDivider),
                        const SizedBox(height: 14),
                        Row(
                          children: [
                            Expanded(
                              child: _SocialButton(
                                label: 'Google',
                                icon: Icons.g_mobiledata_rounded,
                                onTap: () => ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(content: Text(l10n.registerGoogleSoon)),
                                ),
                              ),
                            ),
                            const SizedBox(width: 10),
                            Expanded(
                              child: _SocialButton(
                                label: 'Apple',
                                icon: Icons.apple_rounded,
                                onTap: () => ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(content: Text(l10n.registerAppleSoon)),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _Label extends StatelessWidget {
  const _Label(this.text);
  final String text;

  @override
  Widget build(BuildContext context) {
    return Text(text, style: const TextStyle(fontSize: 20, color: Color(0xFF433428)));
  }
}

class _AuthField extends StatelessWidget {
  const _AuthField({
    required this.controller,
    required this.hint,
    required this.icon,
    required this.validator,
    this.obscureText = false,
    this.suffix,
    this.keyboardType,
  });

  final TextEditingController controller;
  final String hint;
  final IconData icon;
  final String? Function(String?) validator;
  final bool obscureText;
  final Widget? suffix;
  final TextInputType? keyboardType;

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      controller: controller,
      validator: validator,
      obscureText: obscureText,
      keyboardType: keyboardType,
      decoration: InputDecoration(
        hintText: hint,
        prefixIcon: Icon(icon),
        suffixIcon: suffix,
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
        filled: true,
        fillColor: const Color(0xFFFFFBF6),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(24),
          borderSide: const BorderSide(color: Color(0xFFECD9C6)),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(24),
          borderSide: const BorderSide(color: Color(0xFFECD9C6)),
        ),
      ),
    );
  }
}

class _PrimaryActionButton extends StatelessWidget {
  const _PrimaryActionButton({
    required this.label,
    required this.loading,
    required this.onPressed,
  });

  final String label;
  final bool loading;
  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 58,
      child: ElevatedButton(
        onPressed: loading ? null : onPressed,
        style: ElevatedButton.styleFrom(
          elevation: 0,
          backgroundColor: const Color(0xFFFFAA00),
          foregroundColor: const Color(0xFF2F1C09),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
          textStyle: const TextStyle(fontSize: 18, fontWeight: FontWeight.w700),
        ),
        child: loading
            ? const SizedBox(
                width: 20,
                height: 20,
                child: CircularProgressIndicator(strokeWidth: 2.2, color: Color(0xFF2F1C09)),
              )
            : Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(label),
                  const SizedBox(width: 8),
                  const Icon(Icons.arrow_forward_rounded),
                ],
              ),
      ),
    );
  }
}

class _DividerText extends StatelessWidget {
  const _DividerText({required this.text});
  final String text;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        const Expanded(child: Divider(color: Color(0xFFE5D7C8))),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 10),
          child: Text(text, style: const TextStyle(color: Color(0xFFB1A08E))),
        ),
        const Expanded(child: Divider(color: Color(0xFFE5D7C8))),
      ],
    );
  }
}

class _SocialButton extends StatelessWidget {
  const _SocialButton({
    required this.label,
    required this.icon,
    required this.onTap,
  });

  final String label;
  final IconData icon;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return OutlinedButton.icon(
      onPressed: onTap,
      style: OutlinedButton.styleFrom(
        minimumSize: const Size.fromHeight(52),
        side: const BorderSide(color: Color(0xFFE6D6C4)),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        backgroundColor: Colors.white,
      ),
      icon: Icon(icon, color: const Color(0xFF2D2319)),
      label: Text(
        label,
        style: const TextStyle(color: Color(0xFF2D2319), fontSize: 16),
      ),
    );
  }
}
