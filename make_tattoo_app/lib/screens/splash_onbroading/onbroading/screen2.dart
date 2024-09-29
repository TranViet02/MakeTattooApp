import 'package:flutter/material.dart';

import 'package:get/get.dart';
import 'package:make_tattoo_app/utils/style_config.dart';

class Screen2 extends StatelessWidget {
  const Screen2({super.key});

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.start,
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
              'assets/images/onboarding2.png',
              fit: BoxFit.cover,
            ),
          ),
        ),
        SizedBox(
          height: 10,
        ),
        Text(
          "Give Yourself A Real Tattoo".tr,
          style: TextStyle(
            color: textColor,
            fontSize: 14,
            fontWeight: FontWeight.bold,
          ),
          textAlign: TextAlign.center,
        ),
      ],
    );
  }
}
