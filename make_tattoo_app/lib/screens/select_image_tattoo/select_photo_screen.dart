import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_phosphor_icons/flutter_phosphor_icons.dart';
import 'package:get/get.dart';
import 'package:make_tattoo_app/helper/app_image_picker.dart';
import 'package:make_tattoo_app/providers/app_image_provider.dart';
import 'package:make_tattoo_app/screens/edit_tattoo_image/edit_tattoo_screen.dart';
import 'package:make_tattoo_app/screens/select_image_tattoo/mockup_screen.dart';
import 'package:make_tattoo_app/utils/style_config.dart';
import 'package:provider/provider.dart';
import 'package:image_picker/image_picker.dart';
import 'package:zerg_android_plugin/zerg_android_plugin.dart';

class SelectPhotoScreen extends StatefulWidget {
  final String stickerPath;

  const SelectPhotoScreen({super.key, required this.stickerPath});

  @override
  State<SelectPhotoScreen> createState() => _SelectPhotoScreenState();
}

class _SelectPhotoScreenState extends State<SelectPhotoScreen> {
  late AppImageProvider imageProvider;

  @override
  void initState() {
    imageProvider = Provider.of<AppImageProvider>(context, listen: false);
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: backgroundColor,
      appBar: AppBar(
        backgroundColor: backgroundColor,
        centerTitle: true,
        leading: IconButton(
          onPressed: () {
            Navigator.pop(context);
          },
          icon: Icon(
            PhosphorIcons.arrow_left,
            color: textColor,
          ),
        ),
        title: Text(
          "SELECT A PHOTO".tr,
          style: TextStyle(color: textColor),
        ),
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.only(top: 12),
            child: SizedBox(
              child: Container(
                margin: const EdgeInsets.symmetric(horizontal: 20),
                color: Colors.grey[300],
                child: Center(
                  child: ZergAndroidPlugin.getNativeAdView(
                    adWidth: MediaQuery.of(context).size.width,
                  ),
                ),
              ),
            ),
          ),
          const Spacer(),
          Container(
            padding: const EdgeInsets.only(top: 15, left: 15, right: 15),
            decoration: BoxDecoration(
              border: Border.all(color: Colors.white24, width: 1),
              borderRadius: BorderRadius.circular(12),
              color: Colors.black12,
            ),
            child: Column(
              children: [
                ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    foregroundColor: Colors.white,
                    backgroundColor: Colors.black12,
                    minimumSize: const Size(80, 80),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                  onPressed: () {
                    AppImagePicker(source: ImageSource.camera).pick(
                      onPick: (File? image) {
                        imageProvider.changeImageFile(image!);
                        Navigator.of(context).pushReplacement(
                          MaterialPageRoute(
                            builder: (context) => EditTattooScreen(
                              imagePath: image.path,
                              stickerPath: widget.stickerPath.isEmpty
                                  ? ''
                                  : widget.stickerPath,
                            ),
                          ),
                        );
                      },
                    );
                  },
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Icon(Icons.camera_alt, size: 28),
                      const SizedBox(width: 8),
                      Text(
                        "Take a photo".tr,
                        overflow: TextOverflow.ellipsis,
                        maxLines: 1,
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 16),
                SizedBox(
                  width: MediaQuery.of(context).size.width * 0.7,
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Expanded(
                        child: ElevatedButton(
                          style: ElevatedButton.styleFrom(
                            foregroundColor: Colors.white,
                            backgroundColor: Colors.black12,
                            minimumSize: const Size(80, 80),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(8),
                            ),
                          ),
                          onPressed: () {
                            AppImagePicker(source: ImageSource.gallery).pick(
                              onPick: (File image) {
                                imageProvider.changeImageFile(image);
                                Navigator.of(context).pushReplacement(
                                  MaterialPageRoute(
                                    builder: (context) => EditTattooScreen(
                                      imagePath: image.path,
                                      stickerPath: widget.stickerPath.isEmpty
                                          ? ''
                                          : widget.stickerPath,
                                    ),
                                  ),
                                );
                              },
                            );
                          },
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              const Icon(Icons.photo, size: 28),
                              const SizedBox(width: 8),
                              Text(
                                "Your Gallery".tr,
                                overflow: TextOverflow.ellipsis,
                                maxLines: 1,
                              ),
                            ],
                          ),
                        ),
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: ElevatedButton(
                          style: ElevatedButton.styleFrom(
                            foregroundColor: Colors.white,
                            backgroundColor: Colors.black12,
                            minimumSize: const Size(80, 80),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(8),
                            ),
                          ),
                          onPressed: () {
                            Navigator.of(context).pushReplacement(
                              MaterialPageRoute(
                                builder: (context) => MockupScreen(
                                  stickerPath: widget.stickerPath.isEmpty
                                      ? ''
                                      : widget.stickerPath,
                                ),
                              ),
                            );
                          },
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              const Icon(Icons.person_rounded, size: 30),
                              const SizedBox(width: 8),
                              Text("Sample".tr),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 20),
              ],
            ),
          ),
          SizedBox(
            height: MediaQuery.of(context).size.height * 0.04,
          )
        ],
      ),
    );
  }
}
