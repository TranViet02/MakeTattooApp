import 'package:flutter/material.dart';
import 'package:make_tattoo_app/firebase_options.dart';
import 'package:make_tattoo_app/screens/home/home_screen.dart';
import 'package:make_tattoo_app/screens/splash_onbroading/onbroading/onboarding_screen.dart';
import 'package:make_tattoo_app/screens/settings/language/language_screen.dart';
import 'package:make_tattoo_app/utils/style_config.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:zerg_android_plugin/services/ad_manager.dart';
import 'package:zerg_android_plugin/zerg_android_plugin.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    super.initState();
    _checkAppStatus();
    _initializeApp();
  }

  Future<void> initHadesSDK() async {
    ZergAndroidPlugin.initialize(
      firebaseOptions: DefaultFirebaseOptions.currentPlatform,
      isTestingAd: false,
      isNoAdBuild: false,
      adMediationType: AdMediationType.admob,
    );
  }

  Future<void> _initializeApp() async {
    await initHadesSDK();

    await Future.delayed(
      const Duration(seconds: 4),
    );

    await _checkAppStatus();
  }

  Future<void> _checkAppStatus() async {
    final prefs = await SharedPreferences.getInstance();
    final bool hasSelectedLanguage =
        prefs.getBool('hasSelectedLanguage') ?? false;
    final bool hasSeenOnboarding = prefs.getBool('hasSeenOnboarding') ?? false;

    Future.delayed(const Duration(seconds: 4), () {
      if (!hasSelectedLanguage) {
        Navigator.pushReplacement(
            context, MaterialPageRoute(builder: (context) => LanguageScreen()));
      } else if (!hasSeenOnboarding) {
        Navigator.pushReplacement(context,
            MaterialPageRoute(builder: (context) => const OnboardingScreen()));
      } else {
        Navigator.pushReplacement(context,
            MaterialPageRoute(builder: (context) => const HomeScreen()));
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Center(
        child: Stack(
          fit: StackFit.expand,
          children: [
            Image.asset(
              'assets/images/logo.png',
              fit: BoxFit.cover,
            ),
            Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  CircularProgressIndicator(
                    valueColor: AlwaysStoppedAnimation<Color>(
                      iconColor,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
