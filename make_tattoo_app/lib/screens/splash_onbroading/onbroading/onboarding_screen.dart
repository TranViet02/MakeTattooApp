import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:make_tattoo_app/screens/home/home_screen.dart';
import 'package:make_tattoo_app/screens/splash_onbroading/onbroading/screen1.dart';
import 'package:make_tattoo_app/screens/splash_onbroading/onbroading/screen2.dart';
import 'package:make_tattoo_app/screens/splash_onbroading/onbroading/screen3.dart';
import 'package:make_tattoo_app/utils/style_config.dart';
import 'package:smooth_page_indicator/smooth_page_indicator.dart';
import 'package:shared_preferences/shared_preferences.dart';

class OnboardingScreen extends StatefulWidget {
  const OnboardingScreen({super.key});

  @override
  _OnboardingScreenState createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends State<OnboardingScreen> {
  final PageController _pageController = PageController();
  String buttonText = "Skip".tr;
  int currentPageIndex = 0;

  void _onPageChanged(int index) {
    setState(() {
      currentPageIndex = index;
      buttonText = index == 2 ? "Get Started".tr : "Skip".tr;
    });
  }

  Future<void> _onGetStarted() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('hasSeenOnboarding', true);
    Navigator.of(context).pushReplacement(
      MaterialPageRoute(builder: (context) => const HomeScreen()),
    );
  }

  void _goToPreviousPage() {
    if (currentPageIndex > 0) {
      _pageController.previousPage(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeIn,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: backgroundColor,
      body: Stack(
        children: [
          PageView(
            controller: _pageController,
            onPageChanged: _onPageChanged,
            children: const [
              Screen1(),
              Screen2(),
              Screen3(),
            ],
          ),
          Positioned(
            bottom: MediaQuery.of(context).size.height * 0.5,
            left: 0,
            right: 0,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20.0),
                  child: GestureDetector(
                    onTap: currentPageIndex > 0 ? _goToPreviousPage : null,
                    child: Opacity(
                      opacity: currentPageIndex > 0 ? 1.0 : 0.5,
                      child: Text(
                        "Previous".tr,
                        style: TextStyle(
                          fontSize: 16,
                          color: currentPageIndex > 0 ? iconColor : Colors.grey,
                        ),
                      ),
                    ),
                  ),
                ),
                SmoothPageIndicator(
                  controller: _pageController,
                  count: 3,
                  effect: WormEffect(
                    activeDotColor: iconColor,
                    dotColor: Colors.grey,
                    dotHeight: 8,
                    dotWidth: 8,
                    spacing: 16,
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20.0),
                  child: GestureDetector(
                    onTap: currentPageIndex == 2
                        ? _onGetStarted
                        : () {
                            _pageController.nextPage(
                              duration: const Duration(milliseconds: 300),
                              curve: Curves.easeIn,
                            );
                          },
                    child: Text(
                      currentPageIndex == 2 ? "Get Started".tr : "Next".tr,
                      style: TextStyle(
                        fontSize: 16,
                        color: iconColor,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
