import 'package:shared_preferences/shared_preferences.dart';

abstract final class AppPrefs {
  static const onboardingDoneKey = 'onboarding_done';

  static Future<bool> isOnboardingDone() async {
    final p = await SharedPreferences.getInstance();
    return p.getBool(onboardingDoneKey) ?? false;
  }

  static Future<void> setOnboardingDone() async {
    final p = await SharedPreferences.getInstance();
    await p.setBool(onboardingDoneKey, true);
  }
}
