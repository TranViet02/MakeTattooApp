import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:provider/provider.dart';
import 'package:screenshot/screenshot.dart';
import 'package:make_tattoo_app/models/filter_models.dart';
import 'package:make_tattoo_app/providers/app_image_provider.dart';
import 'package:make_tattoo_app/utils/filter__image_config.dart';
import 'package:make_tattoo_app/utils/style_config.dart';
import 'package:zerg_android_plugin/zerg_android_plugin.dart';

class FilterScreen extends StatefulWidget {
  const FilterScreen({super.key});

  @override
  State<FilterScreen> createState() => _FilterScreenState();
}

class _FilterScreenState extends State<FilterScreen> {
  late Filter currentFilter;
  late List<Filter> filters;
  late AppImageProvider imageProvider;
  ScreenshotController screenshotController = ScreenshotController();

  @override
  void initState() {
    super.initState();
    filters = Filters().list();
    currentFilter = filters[0];
    imageProvider = Provider.of<AppImageProvider>(context, listen: false);
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
            child: Stack(
              children: [
                Center(
                  child: Consumer<AppImageProvider>(
                    builder: (BuildContext context, value, Widget? child) {
                      if (value.currentImage != null) {
                        return Screenshot(
                          controller: screenshotController,
                          child: ColorFiltered(
                            colorFilter:
                                ColorFilter.matrix(currentFilter.matrix),
                            child: Image.memory(
                              value.currentImage!,
                              width: MediaQuery.of(context).size.width,
                              fit: BoxFit.cover,
                            ),
                          ),
                        );
                      }
                      return const Center(
                        child: CircularProgressIndicator(),
                      );
                    },
                  ),
                ),
              ],
            ),
          ),
          Container(
            width: double.infinity,
            color: Colors.black,
            height: 140,
            child: SafeArea(
              child: Stack(
                children: [
                  Positioned(
                    top: 0,
                    left: 0,
                    right: 0,
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Container(
                          padding: const EdgeInsets.all(4),
                          child: IconButton(
                            onPressed: () {
                              Navigator.of(context).pop();
                            },
                            icon: const Icon(
                              Icons.close,
                              color: Colors.white,
                              size: 25,
                            ),
                          ),
                        ),
                        Text(
                          "Filter".tr,
                          textAlign: TextAlign.center,
                          style: TextStyle(color: iconColor, fontSize: 19),
                        ),
                        Container(
                          padding: const EdgeInsets.all(4),
                          child: IconButton(
                            onPressed: () async {
                              Uint8List? bytes =
                                  await screenshotController.capture();
                              if (bytes != null) {
                                imageProvider.changeImage(bytes);
                                if (mounted) {
                                  Navigator.of(context).pop();
                                }
                              }
                            },
                            icon: Icon(
                              Icons.check,
                              color: iconColor,
                              size: 25,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.only(top: 50),
                    child: Container(
                      width: double.infinity,
                      color: const Color.fromARGB(255, 54, 53, 53),
                      height: 1,
                    ),
                  ),
                  Positioned(
                    bottom: 0,
                    left: 0,
                    right: 0,
                    height: 75,
                    child: Consumer<AppImageProvider>(
                      builder: (BuildContext context, value, Widget? child) {
                        return ListView.builder(
                          scrollDirection: Axis.horizontal,
                          itemCount: filters.length,
                          itemBuilder: (BuildContext context, index) {
                            Filter filter = filters[index];
                            return Padding(
                              padding: const EdgeInsets.only(left: 10),
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  SizedBox(
                                    width: 57,
                                    height: 62,
                                    child: ClipRRect(
                                      borderRadius: BorderRadius.circular(18),
                                      child: FittedBox(
                                        fit: BoxFit.fill,
                                        child: InkWell(
                                          onTap: () {
                                            setState(() {
                                              currentFilter = filter;
                                            });
                                          },
                                          child: ColorFiltered(
                                            colorFilter: ColorFilter.matrix(
                                                filter.matrix),
                                            child: Image.memory(
                                                value.currentImage!),
                                          ),
                                        ),
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            );
                          },
                        );
                      },
                    ),
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
}
