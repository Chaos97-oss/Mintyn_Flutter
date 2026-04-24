import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'providers/auth_provider.dart';
import 'providers/notifications_provider.dart';
import 'providers/ui_provider.dart';
import 'providers/wallet_provider.dart';
import 'screens/login_screen.dart';
import 'screens/main_shell.dart';
import 'screens/onboarding_screen.dart';
import 'screens/splash_screen.dart';
import 'theme/app_theme.dart';

class FinPayApp extends StatelessWidget {
  const FinPayApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => AuthProvider()),
        ChangeNotifierProvider(create: (_) => WalletProvider()),
        ChangeNotifierProvider(create: (_) => NotificationsProvider()),
        ChangeNotifierProvider(create: (_) => UiProvider()),
      ],
      child: MaterialApp(
        debugShowCheckedModeBanner: false,
        title: 'FinPay',
        theme: buildAppTheme(),
        home: const _Bootstrap(),
      ),
    );
  }
}

enum _Phase { splash, onboarding, app }

class _Bootstrap extends StatefulWidget {
  const _Bootstrap();

  @override
  State<_Bootstrap> createState() => _BootstrapState();
}

class _BootstrapState extends State<_Bootstrap> {
  _Phase _phase = _Phase.splash;

  @override
  Widget build(BuildContext context) {
    switch (_phase) {
      case _Phase.splash:
        return SplashScreen(
          onFinished: ({required bool onboardingDone}) {
            setState(() {
              _phase = onboardingDone ? _Phase.app : _Phase.onboarding;
            });
          },
        );
      case _Phase.onboarding:
        return OnboardingScreen(
          onComplete: () => setState(() => _phase = _Phase.app),
        );
      case _Phase.app:
        return Consumer<AuthProvider>(
          builder: (context, auth, _) {
            if (!auth.isReady) {
              return const Scaffold(
                body: Center(child: CircularProgressIndicator()),
              );
            }
            if (auth.isLoggedIn) {
              return const MainShell();
            }
            return const LoginScreen();
          },
        );
    }
  }
}
