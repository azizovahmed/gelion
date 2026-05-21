import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'core/l10n/app_l10n.dart';
import 'core/locale/locale_controller.dart';
import 'core/locale/locale_scope.dart';
import 'core/services/firebase_bootstrap.dart';
import 'core/theme/app_theme.dart';
import 'features/auth/data/repositories/firebase_auth_repository.dart';
import 'features/auth/domain/repositories/auth_repository.dart';
import 'features/auth/presentation/pages/register_page.dart';
import 'features/home/presentation/pages/home_screen.dart';
import 'features/intro/presentation/pages/onboarding_page.dart';
import 'features/intro/presentation/pages/splash_page.dart';
import 'l10n/generated/app_localizations.dart';

class GelionApp extends StatefulWidget {
  const GelionApp({super.key});

  @override
  State<GelionApp> createState() => _GelionAppState();
}

class _GelionAppState extends State<GelionApp> {
  final AuthRepository _authRepository = FirebaseAuthRepository();
  final LocaleController _localeController = LocaleController();
  /// Til o‘zgarganda [MaterialApp] qayta qurilganda [BootstrapGate] holati va splash yo‘qolmasin.
  final GlobalKey _bootstrapGateKey = GlobalKey(debugLabel: 'bootstrap_gate');
  ThemeMode _themeMode = ThemeMode.system;
  bool _themeReady = false;

  @override
  void initState() {
    super.initState();
    _loadPrefs();
  }

  @override
  void dispose() {
    _localeController.dispose();
    super.dispose();
  }

  Future<void> _loadPrefs() async {
    final prefs = await SharedPreferences.getInstance();
    final value = prefs.getString('theme_mode') ?? 'system';
    await _localeController.load();
    if (!mounted) return;
    setState(() {
      _themeMode = switch (value) {
        'light' => ThemeMode.light,
        'dark' => ThemeMode.dark,
        _ => ThemeMode.system,
      };
      _themeReady = true;
    });
  }

  Future<void> _updateTheme(ThemeMode mode) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('theme_mode', mode.name);
    if (!mounted) return;
    setState(() => _themeMode = mode);
  }

  @override
  Widget build(BuildContext context) {
    if (!_themeReady) {
      return MaterialApp(
        debugShowCheckedModeBanner: false,
        theme: AppTheme.lightTheme,
        home: const Scaffold(body: Center(child: CircularProgressIndicator())),
      );
    }

    return ListenableBuilder(
      listenable: _localeController,
      builder: (context, _) {
        return MaterialApp(
          title: 'Gelion',
          debugShowCheckedModeBanner: false,
          theme: AppTheme.lightTheme,
          darkTheme: AppTheme.darkTheme,
          themeMode: _themeMode,
          locale: _localeController.locale,
          supportedLocales: AppLocalizations.supportedLocales,
          localizationsDelegates: const [
            AppLocalizations.delegate,
            GlobalMaterialLocalizations.delegate,
            GlobalWidgetsLocalizations.delegate,
            GlobalCupertinoLocalizations.delegate,
          ],
          builder: (context, child) {
            return LocaleScope(
              notifier: _localeController,
              child: child ?? const SizedBox.shrink(),
            );
          },
          home: BootstrapGate(
            key: _bootstrapGateKey,
            authRepository: _authRepository,
            onThemeChanged: _updateTheme,
            localeController: _localeController,
          ),
        );
      },
    );
  }
}

class BootstrapGate extends StatefulWidget {
  const BootstrapGate({
    super.key,
    required this.authRepository,
    required this.onThemeChanged,
    required this.localeController,
  });

  final AuthRepository authRepository;
  final ValueChanged<ThemeMode> onThemeChanged;
  final LocaleController localeController;

  @override
  State<BootstrapGate> createState() => _BootstrapGateState();
}

class _BootstrapGateState extends State<BootstrapGate> {
  bool _ready = false;
  bool _isOnboardingSeen = false;
  String? _error;
  /// Bir marta auth oqimidan javob kelgach, qayta `waiting` bo‘lsa ham splash ko‘rsatilmaydi (masalan, til almashtirish).
  late final Stream<User?> _authUserStream = FirebaseAuth.instance.authStateChanges();
  bool _authStreamHydrated = false;
  User? _lastAuthUser;

  @override
  void initState() {
    super.initState();
    _bootstrap();
  }

  Future<void> _bootstrap() async {
    setState(() {
      _ready = false;
      _error = null;
    });
    try {
      await Future.wait<void>([
        FirebaseBootstrap.initialize(),
        Future<void>.delayed(const Duration(seconds: 3)),
      ]);
      final prefs = await SharedPreferences.getInstance();
      final isSeen = prefs.getBool('seen_onboarding') ?? false;
      if (!mounted) return;
      setState(() {
        _isOnboardingSeen = isSeen;
        _ready = true;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() => _error = e.toString());
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_error != null) {
      return FirebaseErrorPage(
        message: _error!,
        onRetry: _bootstrap,
      );
    }
    if (!_ready) {
      return const SplashPage();
    }
    if (!_isOnboardingSeen) {
      return OnboardingPage(
        authRepository: widget.authRepository,
        onThemeChanged: widget.onThemeChanged,
        localeController: widget.localeController,
      );
    }

    return StreamBuilder<User?>(
      stream: _authUserStream,
      builder: (context, snapshot) {
        final conn = snapshot.connectionState;
        if (conn != ConnectionState.waiting) {
          _authStreamHydrated = true;
          _lastAuthUser = snapshot.data;
        }
        if (conn == ConnectionState.waiting && !_authStreamHydrated) {
          return const SplashPage();
        }
        final user = conn == ConnectionState.waiting && _authStreamHydrated
            ? (_lastAuthUser ?? snapshot.data)
            : snapshot.data;
        final child = user != null
            ? HomeScreen(
                authRepository: widget.authRepository,
                onThemeChanged: widget.onThemeChanged,
                localeController: widget.localeController,
              )
            : RegisterPage(
                authRepository: widget.authRepository,
                onThemeChanged: widget.onThemeChanged,
                localeController: widget.localeController,
              );
        return AnimatedSwitcher(
          duration: const Duration(milliseconds: 350),
          child: child,
        );
      },
    );
  }
}

class FadeRoute extends PageRouteBuilder<void> {
  FadeRoute({required Widget child})
      : super(
          pageBuilder: (context, animation, secondaryAnimation) => child,
          transitionDuration: const Duration(milliseconds: 380),
          reverseTransitionDuration: const Duration(milliseconds: 280),
          transitionsBuilder: (context, animation, secondaryAnimation, child) {
            return FadeTransition(
              opacity: CurvedAnimation(parent: animation, curve: Curves.easeOutCubic),
              child: child,
            );
          },
        );
}

class FirebaseErrorPage extends StatelessWidget {
  const FirebaseErrorPage({
    super.key,
    required this.message,
    required this.onRetry,
  });

  final String message;
  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    return Scaffold(
      body: Stack(
        children: [
          Container(
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                colors: [Color(0xFF1A120D), Color(0xFFFC8D00)],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
            ),
            child: Center(
              child: Padding(
                padding: const EdgeInsets.all(24),
                child: Card(
                  color: Colors.black.withValues(alpha: 0.55),
                  child: Padding(
                    padding: const EdgeInsets.all(20),
                    child: Text(
                      l10n.firebaseConnectionError(message),
                      textAlign: TextAlign.center,
                      style: const TextStyle(color: Colors.white, fontSize: 15),
                    ),
                  ),
                ),
              ),
            ),
          ),
          Positioned(
            left: 24,
            right: 24,
            bottom: 40,
            child: ElevatedButton(
              onPressed: onRetry,
              child: Text(l10n.retry),
            ),
          ),
        ],
      ),
    );
  }
}
