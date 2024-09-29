import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:get/get.dart';
import 'package:make_tattoo_app/utils/style_config.dart';

class BlendingModeButton extends StatelessWidget {
  final IconData icon;
  final String label;
  final bool isSelected;
  final VoidCallback onPressed;

  const BlendingModeButton({
    required this.icon,
    required this.label,
    required this.isSelected,
    required this.onPressed,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onPressed,
      child: Container(
        width: 80,
        height: 70,
        margin: const EdgeInsets.symmetric(horizontal: 4),
        decoration: BoxDecoration(
          color: isSelected ? Colors.white : Color.fromARGB(255, 49, 48, 48),
          borderRadius: BorderRadius.circular(8),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.2),
              blurRadius: 4,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon,
                size: 24, color: isSelected ? Colors.black : Colors.white),
            SizedBox(height: 2),
            Text(
              label,
              style: TextStyle(
                fontSize: 12,
                color: isSelected ? Colors.black : Colors.white,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}

class BlendingModePanel extends StatefulWidget {
  final VoidCallback onClose;
  final VoidCallback onSave;
  final List<BlendingModeButton> blendingModes;

  const BlendingModePanel({
    required this.onClose,
    required this.onSave,
    required this.blendingModes,
  });

  @override
  _BlendingModePanelState createState() => _BlendingModePanelState();
}

class _BlendingModePanelState extends State<BlendingModePanel> {
  late String selectedMode;

  @override
  void initState() {
    super.initState();
    selectedMode = 'None';
  }

  @override
  Widget build(BuildContext context) {
    return Positioned(
      bottom: 0,
      right: 0,
      left: 0,
      child: Container(
        height: MediaQuery.of(context).size.height * 0.17,
        color: const Color.fromARGB(255, 23, 23, 23),
        child: Column(
          children: [
            Transform.translate(
              offset: Offset(0, -1),
              child: Container(
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    IconButton(
                      icon: const Icon(Icons.close,
                          color: Colors.white, size: 24),
                      onPressed: widget.onClose,
                    ),
                    Expanded(
                      child: Center(
                        child: Text(
                          "Blending Mode".tr,
                          style: TextStyle(color: iconColor, fontSize: 18),
                        ),
                      ),
                    ),
                    IconButton(
                      icon: Icon(Icons.check, color: iconColor, size: 24),
                      onPressed: widget.onSave,
                    ),
                  ],
                ),
              ),
            ),
            Container(
              width: double.infinity,
              color: const Color.fromARGB(255, 54, 53, 53),
              height: 1,
            ),
            Expanded(
              child: SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: Row(
                  children: widget.blendingModes.map((button) {
                    bool isSelected = button.label == selectedMode;
                    return BlendingModeButton(
                      icon: button.icon,
                      label: button.label,
                      isSelected: isSelected,
                      onPressed: () {
                        setState(() {
                          selectedMode = button.label;
                        });
                        button.onPressed();
                      },
                    );
                  }).toList(),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
