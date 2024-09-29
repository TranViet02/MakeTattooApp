import 'package:flutter/material.dart';
import 'package:flutter_phosphor_icons/flutter_phosphor_icons.dart';
import 'package:get/get.dart';
import 'package:make_tattoo_app/utils/style_config.dart';

class EditTattooActions extends StatelessWidget {
  final bool isEditing;

  final VoidCallback onReplaceTattoo;
  final VoidCallback onToggleBlendingMode;
  final VoidCallback onToggleOpacity;
  final VoidCallback onToggleEraser;
  final VoidCallback onCancel;

  const EditTattooActions({
    Key? key,
    required this.isEditing,
    required this.onReplaceTattoo,
    required this.onToggleBlendingMode,
    required this.onToggleOpacity,
    required this.onToggleEraser,
    required this.onCancel,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Positioned(
      bottom: 0,
      right: 0,
      left: 0,
      child: Container(
        height: MediaQuery.of(context).size.height * 0.19,
        color: const Color.fromARGB(255, 23, 23, 23),
        child: Column(
          children: [
            Container(
              padding: const EdgeInsets.symmetric(vertical: 10),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    child: Center(
                      child: Text(
                        "Edit tattoo".tr,
                        style: TextStyle(color: iconColor, fontSize: 18),
                      ),
                    ),
                  ),
                  IconButton(
                    icon: Icon(Icons.check, color: iconColor, size: 24),
                    onPressed: onCancel,
                  ),
                ],
              ),
            ),
            Container(
              width: double.infinity,
              color: const Color.fromARGB(255, 54, 53, 53),
              height: 1,
            ),
            const SizedBox(
              height: 12,
            ),
            Expanded(
              child: SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: Row(
                  children: [
                    _buildActionButton(
                      icon: Icons.mode,
                      text: 'Blending mode',
                      onPressed: onToggleBlendingMode,
                    ),
                    _buildActionButton(
                      icon: Icons.opacity,
                      text: 'Opacity',
                      onPressed: onToggleOpacity,
                    ),
                    _buildActionButton(
                      icon: PhosphorIcons.eraser,
                      text: 'Eraser',
                      onPressed: onToggleEraser,
                    ),
                    _buildActionButton(
                      icon: Icons.replay_circle_filled_outlined,
                      text: 'Replace tattoo',
                      onPressed: onReplaceTattoo,
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildActionButton({
    required IconData icon,
    required String text,
    required VoidCallback onPressed,
  }) {
    return GestureDetector(
      onTap: onPressed,
      child: Container(
        width: 90,
        height: 63,
        margin: const EdgeInsets.symmetric(horizontal: 4),
        decoration: BoxDecoration(
          color: const Color.fromARGB(255, 66, 66, 66),
          borderRadius: BorderRadius.circular(10),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.2),
              blurRadius: 4,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Container(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(icon, size: 24, color: Colors.white),
              Text(
                text,
                style: TextStyle(fontSize: 12, color: textColor),
                textAlign: TextAlign.center,
                overflow: TextOverflow.ellipsis,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
