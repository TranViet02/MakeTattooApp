import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:get/get.dart';
import 'package:make_tattoo_app/providers/app_image_provider.dart';
import 'package:make_tattoo_app/utils/style_config.dart';
import 'package:provider/provider.dart';
import 'package:zerg_android_plugin/zerg_android_plugin.dart';

class FlipScreen extends StatefulWidget {
  const FlipScreen({super.key});

  @override
  State<FlipScreen> createState() => _FlipScreenState();
}

class _FlipScreenState extends State<FlipScreen> {
  double _rotationAngle = 0.0;
  bool _flipVertical = false;

  @override
  void initState() {
    super.initState();
    final provider = Provider.of<AppImageProvider>(context, listen: false);
    _rotationAngle = provider.rotationAngle;
    _flipVertical = provider.flipVertical;
  }

  void _rotateLeft() {
    setState(() {
      _rotationAngle -= 3.14159 / 2;
      print('Rotate Left: $_rotationAngle');
    });
  }

  void _rotateRight() {
    setState(() {
      _rotationAngle += 3.14159 / 2;
    });
  }

  void _toggleFlipVertical() {
    setState(() {
      _flipVertical = !_flipVertical;
    });
  }

  void _reset() {
    setState(() {
      _rotationAngle = 0.0;
      _flipVertical = false;
    });
  }

  void _confirm() {
    final provider = Provider.of<AppImageProvider>(context, listen: false);
    provider.setRotationAngle(_rotationAngle);
    provider.setFlipVertical(_flipVertical);
    Navigator.of(context).pop();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: backgroundColor,
      appBar: AppBar(
        automaticallyImplyLeading: false,
        backgroundColor: Colors.black,
      ),
      body: Column(
        children: [
          Expanded(
            child: Center(
              child: Consumer<AppImageProvider>(
                builder: (BuildContext context, value, Widget? child) {
                  if (value.currentImage != null) {
                    return Stack(
                      children: [
                        Center(
                          child: Transform(
                            alignment: Alignment.center,
                            transform: Matrix4.identity()
                              ..rotateZ(_rotationAngle)
                              ..scale(_flipVertical ? -1.0 : 1.0, 1.0),
                            child: Image.memory(
                              value.currentImage!,
                              width: double.infinity,
                              fit: BoxFit.cover,
                            ),
                          ),
                        ),
                      ],
                    );
                  }
                  return const Center(
                    child: CircularProgressIndicator(),
                  );
                },
              ),
            ),
          ),
          Container(
            height: 145,
            child: BottomAppBar(
              color: Colors.black,
              child: Column(
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      IconButton(
                        icon: const Icon(
                          Icons.close,
                          color: Colors.white,
                        ),
                        onPressed: _confirm,
                        tooltip: 'Confirm',
                      ),
                      Text(
                        "Filip & Rotate".tr,
                        style: TextStyle(color: iconColor, fontSize: 18),
                      ),
                      IconButton(
                        icon: Icon(
                          Icons.check,
                          color: iconColor,
                        ),
                        onPressed: _confirm,
                        tooltip: 'Confirm',
                      ),
                    ],
                  ),
                  Container(
                    width: double.infinity,
                    color: const Color.fromARGB(255, 54, 53, 53),
                    height: 1,
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    children: [
                      _buildControlButton(Icons.restore, _reset, 'Reset'),
                      _buildControlButton(
                          Icons.rotate_left, _rotateLeft, 'Left'),
                      _buildControlButton(
                          Icons.rotate_right, _rotateRight, 'Right'),
                      _buildControlButton(
                          Icons.flip, _toggleFlipVertical, 'Flip'),
                    ],
                  ),
                ],
              ),
            ),
          ),
          ZergAndroidPlugin.getSmallBannerView(
            alignment: Alignment.bottomCenter,
          ),
        ],
      ),
    );
  }

  Widget _buildControlButton(
      IconData icon, VoidCallback onPressed, String label) {
    return Padding(
      padding: const EdgeInsets.only(top: 15),
      child: InkWell(
        onTap: onPressed,
        child: Container(
          width: 60,
          padding: const EdgeInsets.all(7),
          decoration: BoxDecoration(
            color: const Color.fromARGB(255, 59, 53, 53),
            borderRadius: BorderRadius.circular(8.0),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.2),
                offset: const Offset(0, 2),
                blurRadius: 4.0,
              ),
            ],
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                icon,
                color: Colors.white,
                size: 24,
              ),
              const SizedBox(height: 2),
              Text(
                label,
                style: TextStyle(color: textColor, fontSize: 12),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
