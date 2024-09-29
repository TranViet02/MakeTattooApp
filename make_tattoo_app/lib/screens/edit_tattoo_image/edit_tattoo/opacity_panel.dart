import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:make_tattoo_app/utils/style_config.dart';

class OpacityPanel extends StatelessWidget {
  final double opacity;
  final Function(double) onOpacityChanged;
  final VoidCallback onClose;
  final VoidCallback onSave;

  const OpacityPanel({
    required this.opacity,
    required this.onOpacityChanged,
    required this.onClose,
    required this.onSave,
  });

  @override
  Widget build(BuildContext context) {
    return Positioned(
      bottom: 0,
      right: 0,
      left: 0,
      child: Container(
        height: MediaQuery.of(context).size.height * 0.16,
        color: const Color.fromARGB(255, 23, 23, 23),
        child: Transform.translate(
          offset: const Offset(0, -16),
          child: Column(
            children: [
              Container(
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    IconButton(
                      icon: const Icon(Icons.close,
                          color: Colors.white, size: 24),
                      onPressed: onClose,
                    ),
                    Expanded(
                      child: Center(
                        child: Text(
                          "Opacity".tr,
                          style: TextStyle(color: iconColor, fontSize: 18),
                        ),
                      ),
                    ),
                    IconButton(
                      icon: Icon(Icons.check, color: iconColor, size: 24),
                      onPressed: onSave,
                    ),
                  ],
                ),
              ),
              Container(
                width: double.infinity,
                color: const Color.fromARGB(255, 54, 53, 53),
                height: 1,
              ),
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 1.0),
                  child: Slider(
                    thumbColor: Colors.white,
                    activeColor: Colors.white,
                    value: opacity,
                    min: 0.0,
                    max: 1.0,
                    onChanged: onOpacityChanged,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
