import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../prefs/app_prefs.dart';
import '../theme/app_colors.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key, required this.onFinished});

  final void Function({required bool onboardingDone}) onFinished;

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> with TickerProviderStateMixin {
  late final AnimationController _logoCtrl;
  late final AnimationController _exitCtrl;
  late final Animation<double> _logoScale;
  late final Animation<double> _logoOpacity;
  late final Animation<Offset> _titleSlide;
  late final Animation<double> _titleOpacity;
  late final Animation<Offset> _tagSlide;
  late final Animation<double> _tagOpacity;

  bool _prefsReady = false;
  bool _onboardingDone = false;

  @override
  void initState() {
    super.initState();
    _logoCtrl = AnimationController(vsync: this, duration: const Duration(milliseconds: 600));
    _exitCtrl = AnimationController(vsync: this, duration: const Duration(milliseconds: 400));

    _logoScale = Tween(begin: 0.6, end: 1.0).animate(
      CurvedAnimation(parent: _logoCtrl, curve: Curves.elasticOut),
    );
    _logoOpacity = Tween(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _logoCtrl, curve: Curves.easeOut),
    );

    _titleSlide = Tween(begin: const Offset(0, 0.08), end: Offset.zero).animate(
      CurvedAnimation(
        parent: _logoCtrl,
        curve: const Interval(0.35, 1.0, curve: Curves.easeOutCubic),
      ),
    );
    _titleOpacity = Tween(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _logoCtrl,
        curve: const Interval(0.35, 1.0, curve: Curves.easeOut),
      ),
    );

    _tagSlide = Tween(begin: const Offset(0, 0.08), end: Offset.zero).animate(
      CurvedAnimation(
        parent: _logoCtrl,
        curve: const Interval(0.55, 1.0, curve: Curves.easeOutCubic),
      ),
    );
    _tagOpacity = Tween(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _logoCtrl,
        curve: const Interval(0.55, 1.0, curve: Curves.easeOut),
      ),
    );

    _logoCtrl.forward();
    _bootstrap();

    Future<void>.delayed(const Duration(milliseconds: 2500), () async {
      if (!mounted) return;
      await _exitCtrl.forward();
      if (!mounted) return;
      while (!_prefsReady) {
        await Future<void>.delayed(const Duration(milliseconds: 16));
        if (!mounted) return;
      }
      if (!mounted) return;
      widget.onFinished(onboardingDone: _onboardingDone);
    });
  }

  Future<void> _bootstrap() async {
    _onboardingDone = await AppPrefs.isOnboardingDone();
    _prefsReady = true;
  }

  @override
  void dispose() {
    _logoCtrl.dispose();
    _exitCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final exitFade = Tween(begin: 1.0, end: 0.0).animate(
      CurvedAnimation(parent: _exitCtrl, curve: Curves.easeInCubic),
    );
    final exitScale = Tween(begin: 1.0, end: 1.1).animate(
      CurvedAnimation(parent: _exitCtrl, curve: Curves.easeInCubic),
    );

    return Scaffold(
      backgroundColor: AppColors.background,
      body: AnimatedBuilder(
        animation: Listenable.merge([_logoCtrl, _exitCtrl]),
        builder: (context, _) {
          return Opacity(
            opacity: exitFade.value,
            child: Transform.scale(
              scale: exitScale.value,
              child: Center(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    FadeTransition(
                      opacity: _logoOpacity,
                      child: ScaleTransition(
                        scale: _logoScale,
                        child: Container(
                          width: 80,
                          height: 80,
                          decoration: BoxDecoration(
                            color: AppColors.accent,
                            borderRadius: BorderRadius.circular(24),
                          ),
                          child: const Icon(Icons.account_balance_wallet, color: Colors.white, size: 40),
                        ),
                      ),
                    ),
                    const SizedBox(height: 20),
                    SlideTransition(
                      position: _titleSlide,
                      child: FadeTransition(
                        opacity: _titleOpacity,
                        child: Text(
                          'FinPay',
                          style: GoogleFonts.poppins(
                            fontSize: 28,
                            fontWeight: FontWeight.w700,
                            color: AppColors.textPrimary,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 8),
                    SlideTransition(
                      position: _tagSlide,
                      child: FadeTransition(
                        opacity: _tagOpacity,
                        child: Text(
                          'Your money, simplified',
                          style: GoogleFonts.poppins(
                            fontSize: 14,
                            color: AppColors.textSecondary,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}
