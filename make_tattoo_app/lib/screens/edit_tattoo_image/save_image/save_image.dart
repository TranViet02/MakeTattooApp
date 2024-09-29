import 'dart:io';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:make_tattoo_app/screens/home/home_screen.dart';
import 'package:make_tattoo_app/screens/settings/setting_screen.dart';
import 'package:make_tattoo_app/utils/style_config.dart';
import 'package:share_plus/share_plus.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:zerg_android_plugin/zerg_android_plugin.dart';

class ImageSaveScreen extends StatefulWidget {
  const ImageSaveScreen({super.key});

  @override
  State<ImageSaveScreen> createState() => _ImageSaveScreenState();
}

class _ImageSaveScreenState extends State<ImageSaveScreen> {
  late Future<String?> _latestImagePathFuture;
  String? _imagePath;

  @override
  void initState() {
    super.initState();
    _latestImagePathFuture = _loadLatestImagePath();
  }

  Future<String?> _loadLatestImagePath() async {
    final prefs = await SharedPreferences.getInstance();
    final imagePaths = prefs.getStringList('saved_image_paths') ?? [];
    if (imagePaths.isEmpty) return null;
    return imagePaths.last;
  }

  void _shareImage() {
    if (_imagePath != null && _imagePath!.isNotEmpty) {
      final xfile = XFile(_imagePath!);
      Share.shareXFiles([xfile], text: 'Check out this image!');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black45,
      appBar: AppBar(
        backgroundColor: Colors.black45,
        leading: BackButton(
          color: textColor,
        ),
        title: Text(
          "Share".tr,
          style: TextStyle(color: textColor),
        ),
        centerTitle: true,
        actions: [
          IconButton(
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => HomeScreen(),
                ),
              );
            },
            icon: Icon(
              Icons.home,
              color: textColor,
            ),
          )
        ],
      ),
      body: Column(
        children: [
          Expanded(
            child: Stack(
              children: [
                FutureBuilder<String?>(
                  future: _latestImagePathFuture,
                  builder: (context, snapshot) {
                    if (snapshot.connectionState == ConnectionState.waiting) {
                      return const Center(
                        child: CircularProgressIndicator(),
                      );
                    } else if (snapshot.hasError) {
                      return const Center(
                        child: Text('Error loading image'),
                      );
                    } else {
                      _imagePath = snapshot.data;
                      if (_imagePath == null) {
                        return const Center(
                          child: Text('No image found'),
                        );
                      }
                      return Column(
                        children: [
                          Expanded(
                            child: Transform.translate(
                              offset: const Offset(0, -220),
                              child: Padding(
                                padding: const EdgeInsets.all(10),
                                child: Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                  children: [
                                    Image.file(
                                      File(_imagePath!),
                                      fit: BoxFit.cover,
                                      height: 650,
                                      width: 140,
                                    ),
                                    Padding(
                                      padding: const EdgeInsets.only(top: 285),
                                      child: Column(
                                        children: [
                                          Container(
                                            width: 185,
                                            child: ElevatedButton(
                                              onPressed: () {
                                                CustomRatingBottomSheet
                                                    .showFeedBackBottomSheet(
                                                        context: context);
                                              },
                                              style: ElevatedButton.styleFrom(
                                                foregroundColor: Colors.black,
                                                backgroundColor:
                                                    backgroundColor,
                                                shape: RoundedRectangleBorder(
                                                  borderRadius:
                                                      BorderRadius.circular(
                                                          12.0),
                                                ),
                                                padding:
                                                    const EdgeInsets.symmetric(
                                                  vertical: 16,
                                                ),
                                              ),
                                              child: const Text(
                                                'GIVE FEEDBACK',
                                                overflow: TextOverflow.ellipsis,
                                                maxLines: 1,
                                              ),
                                            ),
                                          ),
                                          const SizedBox(height: 16),
                                          Container(
                                            width: 185,
                                            child: ElevatedButton(
                                              onPressed: () {
                                                Navigator.pop(
                                                    context, _imagePath);
                                              },
                                              style: ElevatedButton.styleFrom(
                                                foregroundColor: Colors.black,
                                                backgroundColor: iconColor,
                                                shape: RoundedRectangleBorder(
                                                  borderRadius:
                                                      BorderRadius.circular(
                                                          12.0),
                                                ),
                                                padding:
                                                    const EdgeInsets.symmetric(
                                                  vertical: 16.0,
                                                ),
                                              ),
                                              child: const Text(
                                                'CONTINUE TATTOOING',
                                                overflow: TextOverflow.ellipsis,
                                                maxLines: 1,
                                              ),
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ),
                        ],
                      );
                    }
                  },
                ),
                Center(
                  child: Container(
                    padding: const EdgeInsets.only(
                        left: 46, right: 46, top: 8, bottom: 10),
                    decoration: BoxDecoration(
                      color: Colors.black.withOpacity(0.7),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                        color: Colors.grey,
                        width: 1,
                      ),
                    ),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          'Share on Social Media',
                          style: TextStyle(
                            color: textColor,
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(
                          height: 3,
                        ),
                        Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            _buildCircularIconButton(
                              Icons.facebook,
                              _shareImage,
                            ),
                            const SizedBox(width: 30),
                            _buildCircularIconButton(
                              Icons.camera_alt,
                              _shareImage,
                            ),
                            const SizedBox(width: 30),
                            _buildCircularIconButton(
                              Icons.more_horiz,
                              _shareImage,
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
                Positioned(
                  bottom: 0,
                  child: ZergAndroidPlugin.getNativeAdView(
                    isMediumSize: false,
                    adWidth: MediaQuery.of(context).size.width,
                  ),
                )
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCircularIconButton(IconData icon, VoidCallback onPressed) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        shape: BoxShape.circle,
        border: Border.all(
          color: Colors.white,
          width: 1,
        ),
      ),
      child: IconButton(
        onPressed: onPressed,
        icon: Icon(
          icon,
          color: Colors.black,
        ),
      ),
    );
  }
}
