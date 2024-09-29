import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:get/get.dart';
import 'package:make_tattoo_app/screens/settings/language/locale_controller.dart';
import 'package:make_tattoo_app/screens/splash_onbroading/onbroading/onboarding_screen.dart';
import 'package:make_tattoo_app/utils/style_config.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:zerg_android_plugin/zerg_android_plugin.dart';

class LanguageScreen extends StatelessWidget {
  final LocaleController localeController = Get.find();
  final Rx<LanguageModel?> selectedLanguage = Rx<LanguageModel?>(null);

  @override
  Widget build(BuildContext context) {
    _setInitialLanguage();

    return Scaffold(
      backgroundColor: const Color.fromARGB(255, 22, 22, 22),
      appBar: AppBar(
        automaticallyImplyLeading: false,
        backgroundColor: const Color.fromARGB(255, 22, 22, 22),
        title: Text(
          'Language'.tr,
          style: TextStyle(color: textColor),
        ),
        centerTitle: true,
        actions: [
          IconButton(
            onPressed: () async {
              if (selectedLanguage.value != null) {
                localeController
                    .changeLocale(selectedLanguage.value!.languageCode);
                localeController.saveSelectedLocale();

                final prefs = await SharedPreferences.getInstance();
                await prefs.setBool('hasSelectedLanguage', true);
                if (!(await prefs.getBool('hasSeenOnboarding') ?? false)) {
                  Navigator.pushReplacement(
                      context,
                      MaterialPageRoute(
                          builder: (context) => const OnboardingScreen()));
                } else {
                  Navigator.pop(context);
                }
              }
            },
            icon: Icon(
              Icons.done,
              color: textColor,
            ),
          )
        ],
      ),
      body: Column(
        children: [
          Expanded(
            child: SingleChildScrollView(
              child: Column(
                children: localeController.languages.map((language) {
                  return buildLanguageCheckbox(language);
                }).toList(),
              ),
            ),
          ),
          Align(
            alignment: Alignment.bottomCenter,
            child: ZergAndroidPlugin.getNativeAdView(
              isMediumSize: false,
              adWidth: MediaQuery.of(context).size.width,
            ),
          ),
        ],
      ),
    );
  }

  void _setInitialLanguage() {
    final currentLanguageCode = Get.locale?.languageCode;
    localeController.languages.forEach((lang) {
      lang.isSelected.value = lang.languageCode == currentLanguageCode;
    });
    selectedLanguage.value = localeController.languages.firstWhere(
      (lang) => lang.languageCode == currentLanguageCode,
      orElse: () => localeController.languages.first,
    );
  }

  Widget buildLanguageCheckbox(LanguageModel language) {
    return Obx(() {
      bool isSelected = language.isSelected.value;

      return GestureDetector(
        onTap: () {
          if (!isSelected) {
            localeController.languages.forEach((lang) {
              lang.isSelected.value = false;
            });

            language.isSelected.value = true;
            selectedLanguage.value = language;
          }
        },
        child: Container(
          margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
          decoration: BoxDecoration(
            color: isSelected
                ? const Color.fromARGB(255, 87, 87, 87)
                : backgroundColor,
            borderRadius: BorderRadius.circular(10),
            border: Border.all(
              color: isSelected
                  ? const Color.fromARGB(255, 161, 98, 93)
                  : Colors.transparent,
              width: 1,
            ),
          ),
          child: CheckboxListTile(
            contentPadding: const EdgeInsets.symmetric(horizontal: 8),
            controlAffinity: ListTileControlAffinity.trailing,
            title: Text(
              language.languageName,
              style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
            ),
            secondary: Text(
              language.languageEmoji,
              style: const TextStyle(fontSize: 29),
            ),
            value: isSelected,
            onChanged: (bool? checked) {
              if (checked != null && checked) {
                localeController.languages.forEach((lang) {
                  lang.isSelected.value = false;
                });
                language.isSelected.value = true;
                selectedLanguage.value = language;
              }
            },
          ),
        ),
      );
    });
  }
}
