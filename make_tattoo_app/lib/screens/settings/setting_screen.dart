import 'package:flutter/material.dart';
import 'package:flutter_rating_bar/flutter_rating_bar.dart';

import 'package:get/get.dart';
import 'package:launch_app_store/launch_app_store.dart';
import 'package:make_tattoo_app/screens/settings/language/language_screen.dart';
import 'package:make_tattoo_app/utils/style_config.dart';
import 'package:share_plus/share_plus.dart';

class SettingScreen extends StatefulWidget {
  const SettingScreen({super.key});

  @override
  State<SettingScreen> createState() => _SettingScreenState();
}

class _SettingScreenState extends State<SettingScreen> {
  void _onLanguageVersionPressed() {}

  void _onLanguageButtonPressed() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => LanguageScreen(),
      ),
    );
  }

  void _onShareButtonPressed() {
    Share.share("Choose one");
  }

  void _onRateButtonPressed() {
    CustomRatingBottomSheet.showFeedBackBottomSheet(context: context);
  }

  void _onPrivacyButtonPressed() {}
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black54,
      appBar: AppBar(
        backgroundColor: Colors.black54,
        leading: BackButtonWidget(),
        centerTitle: true,
        title: Text(
          'Settings'.tr,
          style: TextStyle(color: textColor, fontWeight: FontWeight.w700),
        ),
      ),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Container(
            width: double.infinity,
            height: 0.5,
            color: Colors.white54,
          ),
          const SizedBox(height: 8),
          Align(
            alignment: Alignment.centerLeft,
            child: Container(
              padding: EdgeInsets.symmetric(horizontal: 16),
              child: Text(
                'Normal setting'.tr,
                style: const TextStyle(
                  color: Colors.white54,
                  fontWeight: FontWeight.bold,
                  fontSize: 14,
                ),
              ),
            ),
          ),
          const SizedBox(height: 8),
          Container(
            width: double.infinity,
            height: 0.5,
            color: Colors.white54,
          ),
          _buildLabeledButton(
              'Your Language'.tr, Icons.language, _onLanguageButtonPressed),
          _buildLabeledButton(
              'Share App'.tr, Icons.share, _onShareButtonPressed),
          _buildLabeledButton(
              'Rate & Feedback'.tr, Icons.star, _onRateButtonPressed),
          _buildLabeledButton(
              'Privacy Policy'.tr, Icons.lock, _onPrivacyButtonPressed),
          const SizedBox(height: 8),
          Align(
            alignment: Alignment.centerLeft,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Text(
                'About'.tr,
                style: const TextStyle(
                  color: Colors.white54,
                  fontWeight: FontWeight.bold,
                  fontSize: 14,
                ),
              ),
            ),
          ),
          const SizedBox(height: 10),
          Container(
            width: double.infinity,
            height: 0.5,
            color: Colors.white,
          ),
          _buildLabeledButton(
              'Version'.tr,
              Icons.sentiment_very_satisfied_outlined,
              _onLanguageVersionPressed),
        ],
      ),
    );
  }

  Widget _buildLabeledButton(
      String label, IconData icon, VoidCallback onPressed) {
    return Column(
      children: [
        TextButton(
          onPressed: onPressed,
          child: Container(
            padding: const EdgeInsets.symmetric(vertical: 8),
            child: Row(
              children: [
                Icon(icon, color: Colors.white),
                const SizedBox(width: 16),
                Text(
                  label,
                  style: TextStyle(
                    color: textColor,
                    fontSize: 14,
                  ),
                ),
              ],
            ),
          ),
        ),
        Container(
          margin: const EdgeInsets.only(left: 16, right: 16),
          width: double.infinity,
          child: Align(
            alignment: Alignment.centerLeft,
            child: Container(
              width: MediaQuery.of(context).size.width * 0.87,
              height: 0.5,
              color: Colors.white54,
            ),
          ),
        ),
      ],
    );
  }
}

class CustomRatingBottomSheet {
  CustomRatingBottomSheet._();

  static Future<void> showFeedBackBottomSheet({
    required BuildContext context,
  }) {
    double width = MediaQuery.of(context).size.width;
    double height = MediaQuery.of(context).size.height;

    _ratingNotifier.value = 3.5;

    return showModalBottomSheet<void>(
      enableDrag: false,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      isDismissible: false,
      context: context,
      builder: (BuildContext context) {
        return Padding(
          padding:
              EdgeInsets.only(bottom: MediaQuery.of(context).viewInsets.bottom),
          child: Container(
            width: width,
            height: height * 0.55,
            decoration: const BoxDecoration(
              color: Colors.grey,
              borderRadius: BorderRadius.only(
                topRight: Radius.circular(20),
                topLeft: Radius.circular(20),
              ),
            ),
            child: Column(
              children: <Widget>[
                Align(
                  alignment: Alignment.topRight,
                  child: IconButton(
                    onPressed: () {
                      Navigator.pop(context);
                    },
                    icon: const Icon(Icons.close),
                  ),
                ),
                ValueListenableBuilder<double>(
                  valueListenable: _ratingNotifier,
                  builder: (context, rating, child) {
                    final feedback = _getFeedbackForRating(rating);
                    return Column(
                      children: [
                        Text(
                          feedback.emoji,
                          style: TextStyle(fontSize: 100),
                        ),
                        const SizedBox(height: 10),
                        Text(
                          feedback.text,
                          textAlign: TextAlign.center,
                          maxLines: 4,
                        ),
                      ],
                    );
                  },
                ),
                const Padding(
                  padding: EdgeInsets.symmetric(horizontal: 10, vertical: 20),
                  child: Text(
                    "How do you feel about the app? Your feedback is important to us",
                    maxLines: 4,
                    textAlign: TextAlign.center,
                  ),
                ),
                SizedBox(
                  height: height * 0.02,
                ),
                RatingBar.builder(
                  glow: false,
                  allowHalfRating: true,
                  unratedColor: Colors.grey[400],
                  itemSize: 50,
                  itemBuilder: (context, _) => const Icon(
                    Icons.star,
                    color: Colors.amber,
                  ),
                  onRatingUpdate: (rating) {
                    _ratingNotifier.value = rating;
                  },
                ),
                const SizedBox(height: 20),
                ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(horizontal: 105),
                    backgroundColor: Colors.amber[600],
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                  onPressed: () {
                    final rating = _ratingNotifier.value;
                    Navigator.pop(context);
                    if (rating < 4) {
                      _showFeedbackDialog(context, rating);
                    } else {
                      _openAppStore();
                    }
                  },
                  child: const Text(
                    'OK',
                    style: TextStyle(color: Colors.black),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  static final _ratingNotifier = ValueNotifier<double>(3.5);

  static Feedback _getFeedbackForRating(double rating) {
    if (rating >= 4.5) {
      return Feedback('🤩', 'We are thrilled to hear that you love the app!');
    } else if (rating >= 3.5) {
      return Feedback('😊', 'We are glad you enjoyed using the app.');
    } else if (rating >= 2.5) {
      return Feedback('😐',
          'Okay. We appreciate your feedback and will work on improvements.');
    } else if (rating >= 1.5) {
      return Feedback('😕',
          'Sorry to hear that. We would like to know more about your experience.');
    } else {
      return Feedback(
          '😠', 'Very disappointed. Please let us know how we can improve.');
    }
  }

  static Future<void> _showFeedbackDialog(BuildContext context, double rating) {
    return showDialog<void>(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Feedback'),
          content: Text(
              'We noticed that you rated the app $rating stars. Can you please provide us with some feedback?'),
          actions: <Widget>[
            TextButton(
              onPressed: () {
                Navigator.pop(context);
              },
              child: const Text('Cancel'),
            ),
            TextButton(
              onPressed: () {
                Navigator.pop(context);
              },
              child: const Text('Submit'),
            ),
          ],
        );
      },
    );
  }

  static Future<void> _openAppStore() async {
    await LaunchReview.launch(androidAppId: "com.rockstargames.gtasa");
  }
}

class Feedback {
  final String emoji;
  final String text;

  Feedback(this.emoji, this.text);
}
