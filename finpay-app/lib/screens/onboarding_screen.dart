import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../prefs/app_prefs.dart';
import '../theme/app_colors.dart';
import '../widgets/primary_button.dart';

class OnboardingScreen extends StatefulWidget {
  const OnboardingScreen({super.key, required this.onComplete});

  final VoidCallback onComplete;

  @override
  State<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingSlide {
  const _OnboardingSlide({
    required this.icon,
    required this.title,
    required this.description,
    required this.accent,
  });

  final IconData icon;
  final String title;
  final String description;
  final Color accent;
}

class _OnboardingScreenState extends State<OnboardingScreen> with TickerProviderStateMixin {
  final _controller = PageController();
  int _index = 0;

  late final AnimationController _pulse;

  static const _slides = [
    _OnboardingSlide(
      icon: Icons.credit_card,
      title: 'Manage Your Cards',
      description: 'View and control all your physical and virtual cards in one place.',
      accent: AppColors.accent,
    ),
    _OnboardingSlide(
      icon: Icons.trending_up,
      title: 'Track Spending',
      description: 'Get detailed analytics on your spending patterns and transaction history.',
      accent: AppColors.green,
    ),
    _OnboardingSlide(
      icon: Icons.send,
      title: 'Send & Receive Instantly',
      description: 'Transfer money to anyone, anywhere, with zero friction.',
      accent: Color(0xFF8B5CF6),
    ),
  ];

  @override
  void initState() {
    super.initState();
    _pulse = AnimationController(vsync: this, duration: const Duration(seconds: 2))..repeat(reverse: true);
  }

  @override
  void dispose() {
    _pulse.dispose();
    _controller.dispose();
    super.dispose();
  }

  Future<void> _finish() async {
    await AppPrefs.setOnboardingDone();
    widget.onComplete();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: Stack(
          children: [
            Positioned(
              top: 8,
              right: 12,
              child: TextButton(
                onPressed: _finish,
                child: Text(
                  'Skip',
                  style: GoogleFonts.poppins(fontSize: 14, color: AppColors.textSecondary),
                ),
              ),
            ),
            PageView.builder(
              controller: _controller,
              itemCount: _slides.length,
              onPageChanged: (i) => setState(() => _index = i),
              itemBuilder: (context, i) {
                final s = _slides[i];
                return _SlideBody(slide: s, pulse: _pulse, active: _index == i);
              },
            ),
            Align(
              alignment: Alignment.bottomCenter,
              child: Padding(
                padding: const EdgeInsets.fromLTRB(20, 0, 20, 24),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: List.generate(_slides.length, (i) {
                        final active = i == _index;
                        return AnimatedContainer(
                          duration: const Duration(milliseconds: 320),
                          curve: Curves.easeOutCubic,
                          width: active ? 24 : 6,
                          height: 6,
                          margin: const EdgeInsets.symmetric(horizontal: 4),
                          decoration: BoxDecoration(
                            color: active ? Colors.white : AppColors.textMuted,
                            borderRadius: BorderRadius.circular(999),
                          ),
                        );
                      }),
                    ),
                    const SizedBox(height: 16),
                    if (_index < 2)
                      PillPrimaryButton(
                        label: 'Next',
                        onPressed: () => _controller.nextPage(
                          duration: const Duration(milliseconds: 320),
                          curve: Curves.easeOutCubic,
                        ),
                      )
                    else
                      PillPrimaryButton(label: 'Get Started', onPressed: _finish),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _SlideBody extends StatelessWidget {
  const _SlideBody({
    required this.slide,
    required this.pulse,
    required this.active,
  });

  final _OnboardingSlide slide;
  final Animation<double> pulse;
  final bool active;

  @override
  Widget build(BuildContext context) {
    final h = MediaQuery.sizeOf(context).height;
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Column(
        children: [
          SizedBox(height: h * 0.08),
          SizedBox(
            height: h * 0.34,
            child: Center(
              child: AnimatedScale(
                duration: const Duration(milliseconds: 420),
                curve: Curves.elasticOut,
                scale: active ? 1.0 : 0.92,
                child: AnimatedBuilder(
                  animation: pulse,
                  builder: (context, _) {
                    final t = 0.3 + (pulse.value * 0.3);
                    return Stack(
                      alignment: Alignment.center,
                      children: [
                        Container(
                          width: 220,
                          height: 220,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            gradient: RadialGradient(
                              colors: [
                                slide.accent.withValues(alpha: t),
                                Colors.transparent,
                              ],
                            ),
                          ),
                        ),
                        Icon(slide.icon, size: 160, color: slide.accent),
                      ],
                    );
                  },
                ),
              ),
            ),
          ),
          const SizedBox(height: 32),
          Text(
            slide.title,
            textAlign: TextAlign.center,
            style: GoogleFonts.poppins(
              fontSize: 26,
              fontWeight: FontWeight.w700,
              color: AppColors.textPrimary,
            ),
          ),
          const SizedBox(height: 12),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: Text(
              slide.description,
              textAlign: TextAlign.center,
              style: GoogleFonts.poppins(
                fontSize: 15,
                height: 1.4,
                color: AppColors.textSecondary,
              ),
            ),
          ),
          const Spacer(),
          SizedBox(height: h * 0.16),
        ],
      ),
    );
  }
}
