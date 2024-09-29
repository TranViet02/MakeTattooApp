import 'dart:typed_data';
import 'dart:ui';
import 'dart:ui' as ui;
import 'package:crop_image/crop_image.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:make_tattoo_app/providers/app_image_provider.dart';
import 'package:make_tattoo_app/utils/style_config.dart';
import 'package:provider/provider.dart';
import 'package:zerg_android_plugin/zerg_android_plugin.dart';

class CropScreen extends StatefulWidget {
  const CropScreen({super.key});

  @override
  State<CropScreen> createState() => _CropScreenState();
}

class _CropScreenState extends State<CropScreen> {
  final controller = CropController(
    aspectRatio: 1,
    defaultCrop: const Rect.fromLTRB(0.1, 0.1, 0.9, 0.9),
  );
  late AppImageProvider imageProvider;

  String _currentMode = 'Custom';

  @override
  void initState() {
    super.initState();
    imageProvider = Provider.of<AppImageProvider>(context, listen: false);
  }

  void _setMode(String mode, double aspectRatio) {
    setState(() {
      _currentMode = mode;
      controller.aspectRatio = aspectRatio;
      controller.crop = const Rect.fromLTRB(0.1, 0.1, 0.9, 0.9);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.black,
        automaticallyImplyLeading: false,
      ),
      backgroundColor: backgroundColor,
      body: Column(
        children: [
          Expanded(
            child: Padding(
              padding: const EdgeInsets.only(top: 29),
              child: Center(
                child: Consumer<AppImageProvider>(
                  builder: (BuildContext context, value, Widget? child) {
                    if (value.currentImage != null) {
                      return CropImage(
                        controller: controller,
                        image: Image.memory(value.currentImage!),
                      );
                    }
                    return const Center(
                      child: CircularProgressIndicator(),
                    );
                  },
                ),
              ),
            ),
          ),
          Container(
            width: double.infinity,
            color: Colors.black,
            height: 130,
            child: Column(
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    IconButton(
                      onPressed: () {
                        Navigator.pop(context);
                      },
                      icon: Icon(
                        Icons.close,
                        color: textColor,
                      ),
                    ),
                    Text(
                      "Crop".tr,
                      style: TextStyle(color: iconColor, fontSize: 18),
                    ),
                    IconButton(
                      icon: Icon(Icons.check, color: iconColor),
                      onPressed: () async {
                        ui.Image bitmap = await controller.croppedBitmap();
                        ByteData? data = await bitmap.toByteData(
                            format: ImageByteFormat.png);
                        Uint8List bytes = data!.buffer.asUint8List();

                        imageProvider.changeImage(bytes);
                        if (mounted) {
                          Navigator.of(context).pop();
                        }
                      },
                    ),
                  ],
                ),
                Container(
                  width: double.infinity,
                  color: const Color.fromARGB(255, 54, 53, 53),
                  height: 1,
                ),
                SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: Row(
                    children: [
                      Padding(
                        padding: const EdgeInsets.only(top: 10, left: 8),
                        child: ElevatedButton(
                          onPressed: () => _setMode('Custom', 1),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: _currentMode == 'Custom'
                                ? iconColor
                                : const Color.fromARGB(255, 59, 53, 53),
                            minimumSize: const Size(60, 40),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(10),
                            ),
                            padding: const EdgeInsets.symmetric(
                                vertical: 4, horizontal: 16.0),
                          ),
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(
                                Icons.border_all,
                                color: _currentMode == 'Custom'
                                    ? Colors.black
                                    : textColor,
                              ),
                              SizedBox(height: 3),
                              Text(
                                "Custom",
                                style: TextStyle(
                                    color: _currentMode == 'Custom'
                                        ? Colors.black
                                        : textColor,
                                    fontSize: 16),
                              ),
                            ],
                          ),
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.only(top: 10, left: 8),
                        child: ElevatedButton(
                          onPressed: () => _setMode('1:1', 1),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: _currentMode == '1:1'
                                ? iconColor
                                : const Color.fromARGB(255, 59, 53, 53),
                            minimumSize: const Size(60, 40),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(10),
                            ),
                            padding: const EdgeInsets.symmetric(
                                vertical: 4, horizontal: 16.0),
                          ),
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(
                                Icons.border_all,
                                color: _currentMode == '1:1'
                                    ? Colors.black
                                    : Colors.white,
                              ),
                              const SizedBox(height: 3),
                              Text(
                                "1:1",
                                style: TextStyle(
                                    color: _currentMode == '1:1'
                                        ? Colors.black
                                        : textColor,
                                    fontSize: 16),
                              ),
                            ],
                          ),
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.only(top: 10, left: 8),
                        child: ElevatedButton(
                          onPressed: () => _setMode('2:3', 2 / 3),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: _currentMode == '2:3'
                                ? iconColor
                                : const Color.fromARGB(255, 59, 53, 53),
                            minimumSize: const Size(60, 40),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(10),
                            ),
                            padding: const EdgeInsets.symmetric(
                                vertical: 4, horizontal: 16.0),
                          ),
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(
                                Icons.border_all,
                                color: _currentMode == '2:3'
                                    ? Colors.black
                                    : Colors.white,
                              ),
                              const SizedBox(height: 3),
                              Text(
                                "2:3",
                                style: TextStyle(
                                    color: _currentMode == '2:3'
                                        ? Colors.black
                                        : textColor,
                                    fontSize: 16),
                              ),
                            ],
                          ),
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.only(top: 10, left: 8),
                        child: ElevatedButton(
                          onPressed: () => _setMode('3:4', 3 / 4),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: _currentMode == '3:4'
                                ? iconColor
                                : const Color.fromARGB(255, 59, 53, 53),
                            minimumSize: const Size(60, 40),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(10),
                            ),
                            padding: const EdgeInsets.symmetric(
                                vertical: 4, horizontal: 16.0),
                          ),
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(
                                Icons.border_all,
                                color: _currentMode == '3:4'
                                    ? Colors.black
                                    : textColor,
                              ),
                              const SizedBox(height: 3),
                              Text(
                                "3:4",
                                style: TextStyle(
                                    color: _currentMode == '3:4'
                                        ? Colors.black
                                        : textColor,
                                    fontSize: 16),
                              ),
                            ],
                          ),
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.only(top: 10, left: 8),
                        child: ElevatedButton(
                          onPressed: () => _setMode('16:9', 16 / 9),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: _currentMode == '16:9'
                                ? iconColor
                                : const Color.fromARGB(255, 59, 53, 53),
                            minimumSize: const Size(60, 40),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(10),
                            ),
                            padding: const EdgeInsets.symmetric(
                                vertical: 4, horizontal: 16.0),
                          ),
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(
                                Icons.border_all,
                                color: _currentMode == '16:9'
                                    ? Colors.black
                                    : Colors.white,
                              ),
                              const SizedBox(height: 3),
                              Text(
                                "16:9",
                                style: TextStyle(
                                    color: _currentMode == '16:9'
                                        ? Colors.black
                                        : textColor,
                                    fontSize: 16),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          ZergAndroidPlugin.getSmallBannerView(
            alignment: Alignment.bottomCenter,
          ),
        ],
      ),
    );
  }
}
