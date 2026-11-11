import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import '../core/l10n/madad_localizations.dart';
import '../core/theme/madad_theme.dart';
import '../data/auth_repository.dart';
import '../data/auth_state.dart';
import '../data/madad_api_client.dart';
import '../data/madad_app_scope.dart';
import '../data/session_storage.dart';
import '../features/auth/auth_screen.dart';
import '../features/home/home_screen.dart';

class MadadApp extends StatefulWidget {
  const MadadApp({super.key, this.apiClient, this.sessionStorage});

  final MadadApiClient? apiClient;
  final SessionStorage? sessionStorage;

  @override
  State<MadadApp> createState() => _MadadAppState();
}

class _MadadAppState extends State<MadadApp> {
  final locale = ValueNotifier(const Locale('ar'));
  bool _splashElapsed = false;
  late final MadadApiClient api;
  late final AuthRepository authRepository;
  late final AuthState authState;

  @override
  void initState() {
    super.initState();
    api = widget.apiClient ?? MadadApiClient();
    authRepository = widget.sessionStorage == null
        ? AuthRepository(api: api)
        : AuthRepository.withStorage(api: api, storage: widget.sessionStorage!);
    authState = AuthState(authRepository)..restore();
  }

  @override
  void dispose() {
    locale.dispose();
    authState.dispose();
    api.close();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => ValueListenableBuilder<Locale>(
        valueListenable: locale,
        builder: (context, activeLocale, _) => MaterialApp(
          title: 'MADAD | مَدَد',
          debugShowCheckedModeBanner: false,
          theme: MadadTheme.dark,
          darkTheme: MadadTheme.dark,
          themeMode: ThemeMode.dark,
          locale: activeLocale,
          supportedLocales: MadadLocalizations.supportedLocales,
          localizationsDelegates: const [
            MadadLocalizations.delegate,
            GlobalMaterialLocalizations.delegate,
            GlobalWidgetsLocalizations.delegate,
            GlobalCupertinoLocalizations.delegate,
          ],
          localeResolutionCallback: (preferred, supported) {
            if (preferred != null) {
              for (final candidate in supported) {
                if (candidate.languageCode == preferred.languageCode) {
                  return candidate;
                }
              }
            }
            return const Locale('ar');
          },
          builder: (context, child) => MadadLocaleController(
            onLocaleChanged: (value) => locale.value = value,
            child: child ?? const SizedBox.shrink(),
          ),
          home: AnimatedBuilder(
            animation: authState,
            builder: (context, _) {
              if (!authState.isInitialized || !_splashElapsed) {
                return _SessionLoadingScreen(
                  onComplete: () {
                    if (mounted && !_splashElapsed) {
                      setState(() => _splashElapsed = true);
                    }
                  },
                );
              }
              return MadadAppScope(
                auth: authState,
                repository: authRepository,
                child: authState.isAuthenticated
                    ? const HomeScreen()
                    : const AuthScreen(),
              );
            },
          ),
        ),
      );
}

class _SessionLoadingScreen extends StatefulWidget {
  const _SessionLoadingScreen({required this.onComplete});

  final VoidCallback onComplete;

  @override
  State<_SessionLoadingScreen> createState() => _SessionLoadingScreenState();
}

class _SessionLoadingScreenState extends State<_SessionLoadingScreen>
    with SingleTickerProviderStateMixin {
  late final AnimationController _draw = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 1200),
  )..addStatusListener((status) {
      if (status == AnimationStatus.completed) widget.onComplete();
    });

  @override
  void initState() {
    super.initState();
    _draw.forward();
  }

  @override
  void dispose() {
    _draw.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => Scaffold(
        body: Center(
          child: AnimatedBuilder(
            animation: _draw,
            builder: (context, _) => CustomPaint(
              size: const Size.square(112),
              painter: _MadadMarkPainter(_draw.value),
            ),
          ),
        ),
      );
}

class _MadadMarkPainter extends CustomPainter {
  const _MadadMarkPainter(this.progress);

  final double progress;

  @override
  void paint(Canvas canvas, Size size) {
    final scale = size.width / 100;
    canvas.save();
    canvas.scale(scale);
    final paint = Paint()
      ..color = MadadColors.orange
      ..style = PaintingStyle.stroke
      ..strokeWidth = 8
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round;
    final path = Path()
      ..moveTo(18, 18)
      ..lineTo(69, 18)
      ..quadraticBezierTo(83, 18, 83, 32)
      ..lineTo(83, 55)
      ..cubicTo(83, 73, 69, 84, 51, 84)
      ..cubicTo(32, 84, 18, 72, 18, 54)
      ..lineTo(18, 40);
    final metrics = path.computeMetrics().toList();
    final totalLength =
        metrics.fold<double>(0, (sum, metric) => sum + metric.length);
    var remaining = totalLength * progress;
    final drawn = Path();
    for (final metric in metrics) {
      if (remaining <= 0) break;
      final length = remaining.clamp(0, metric.length).toDouble();
      drawn.addPath(metric.extractPath(0, length), Offset.zero);
      remaining -= length;
    }
    canvas.drawPath(drawn, paint);
    if (progress > .54) {
      final dotProgress = ((progress - .54) / .46).clamp(0.0, 1.0);
      final dotPaint = Paint()..color = MadadColors.orange;
      canvas.drawCircle(const Offset(33, 39), 7 * dotProgress, dotPaint);
    }
    canvas.restore();
  }

  @override
  bool shouldRepaint(covariant _MadadMarkPainter oldDelegate) =>
      oldDelegate.progress != progress;
}
