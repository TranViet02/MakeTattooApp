import 'package:flutter/material.dart';

import 'package:get/get.dart';
import 'package:make_tattoo_app/utils/style_config.dart';
import 'package:zerg_android_plugin/zerg_android_plugin.dart';

class Screen3 extends StatelessWidget {
  const Screen3({super.key});

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Container(
          decoration: BoxDecoration(
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.5),
                spreadRadius: 2,
                blurRadius: 8,
                offset: Offset(0, 8),
              ),
            ],
          ),
          child: ClipRRect(
            child: Image.asset(
              'assets/images/onboarding3.png',
              fit: BoxFit.cover,
            ),
          ),
        ),
        const SizedBox(
          height: 10,
        ),
        Text(
          "Custom Your Own Tattoo".tr,
          style: TextStyle(
            color: textColor,
            fontSize: 14,
            fontWeight: FontWeight.bold,
          ),
          textAlign: TextAlign.center,
        ),
        Expanded(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              Container(
                width: MediaQuery.of(context).size.width * 0.9,
                margin: const EdgeInsets.symmetric(horizontal: 20),
                child: ZergAndroidPlugin.getNativeAdView(
                  adWidth: MediaQuery.of(context).size.width,
                ),
              ),
            ],
          ),
        )
      ],
    );
  }
}
