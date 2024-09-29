import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:make_tattoo_app/models/photo_models_tattoo.dart';
import 'package:make_tattoo_app/models/remote_config_count_tattoo.dart';
import 'package:make_tattoo_app/screens/home/custom_tatttoo_card.dart';
import 'package:make_tattoo_app/screens/preview/preview_sticker.dart';
import 'package:make_tattoo_app/screens/select_image_tattoo/my_work_screen.dart';
import 'package:make_tattoo_app/screens/select_image_tattoo/select_photo_screen.dart';
import 'package:make_tattoo_app/screens/select_image_tattoo/select_tattoo_sticker.dart';
import 'package:make_tattoo_app/screens/select_image_tattoo/tattoo_ideas.dart';
import 'package:make_tattoo_app/screens/settings/setting_screen.dart';
import 'package:make_tattoo_app/screens/splash_onbroading/subscription/subscription_screen.dart';
import 'package:make_tattoo_app/utils/style_config.dart';
import 'package:zerg_android_plugin/zerg_android_plugin.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final ImageService imageService = ImageService(
    baseUrl: 'https://hadesgame.studio/tattoo-maker/tattoo',
  );
  final RemoteConfigService remoteConfigService = RemoteConfigService();
  List<String> trendingImages = [];

  @override
  void initState() {
    super.initState();
    _loadTrendingImages();
  }

  Future<void> _loadTrendingImages() async {
    await Future.delayed(const Duration(seconds: 1));
    setState(() {
      trendingImages = _getTrendingTattoos();
    });
  }

  List<String> _getTrendingTattoos() {
    List<String> trendingImages = [];
    final categories = imageService.getCategories();

    for (var category
        in categories.where((cat) => cat.category != 'trending')) {
      final numberOfImages =
          remoteConfigService.getImageCount(category.category);
      if (numberOfImages > 0) {
        final trendingImageUrl =
            '${imageService.baseUrl}/${category.category}/${category.category}_${category.startIndex}.png';
        trendingImages.add(trendingImageUrl);
      }
    }
    return trendingImages.take(8).toList();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: backgroundColor,
      appBar: AppBar(
        centerTitle: true,
        backgroundColor: backgroundColor,
        leading: IconButton(
          icon: const Icon(
            Icons.settings,
            color: Colors.white,
            size: 26,
          ),
          onPressed: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => const SettingScreen(),
              ),
            );
          },
        ),
        title: Text(
          '𝓣𝓪𝓽𝓽𝓸𝓸 𝓜𝓪𝓴𝓮',
          style: TextStyle(
            color: textColor,
            fontSize: 24,
            fontWeight: FontWeight.bold,
          ),
        ),
        actions: [
          IconButton(
            icon: const Icon(
              Icons.ac_unit_sharp,
              color: Colors.white,
              size: 26,
            ),
            onPressed: () {
              ZergAndroidPlugin.showIntersAd(
                onFinished: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const SubscriptionScreen(),
                    ),
                  );
                },
              );
            },
          ),
        ],
      ),
      body: Column(
        children: [
          Expanded(
            child: SafeArea(
              child: SingleChildScrollView(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Padding(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 20, vertical: 20),
                        child: Row(
                          children: [
                            CustomTattooCard(
                              imagePath: 'assets/japanese/japanese_4.png',
                              title: 'Create Tattoo'.tr,
                              onTap: () {
                                ZergAndroidPlugin.showIntersAd(
                                  onFinished: () {
                                    Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                        builder: (context) =>
                                            const SelectPhotoScreen(
                                          stickerPath: '',
                                        ),
                                      ),
                                    );
                                  },
                                );
                              },
                              textColor: textColor,
                            ),
                            const SizedBox(width: 10),
                            CustomTattooCard(
                              imagePath: 'assets/japanese/japanese_5.png',
                              title: 'Tattoo Ideas'.tr,
                              onTap: () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) => const TattooIdea(),
                                  ),
                                );
                              },
                              textColor: textColor,
                            ),
                          ],
                        )),
                    Padding(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 20, vertical: 10),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Row(
                            children: [
                              const Icon(
                                Icons.whatshot,
                                color: Colors.red,
                                size: 24,
                              ),
                              const SizedBox(width: 8),
                              Text(
                                'TRENDING'.tr,
                                style: TextStyle(
                                  color: textColor,
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ],
                          ),
                          GestureDetector(
                            onTap: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) =>
                                      const TattooSelectSticker(),
                                ),
                              );
                            },
                            child: Text(
                              'See all'.tr,
                              style: TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                                color: textColor,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    Container(
                      height: 140,
                      padding: const EdgeInsets.symmetric(horizontal: 20),
                      child: ListView.builder(
                        scrollDirection: Axis.horizontal,
                        itemCount: trendingImages.length,
                        itemBuilder: (context, index) {
                          return GestureDetector(
                            onTap: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => PreviewScreen(
                                    imagePath: trendingImages[index],
                                  ),
                                ),
                              );
                            },
                            child: Container(
                              width: 110,
                              margin: const EdgeInsets.only(right: 10),
                              child: ClipRRect(
                                borderRadius: BorderRadius.circular(8),
                                child: Container(
                                  color: Colors.white,
                                  child: CachedNetworkImage(
                                    imageUrl: trendingImages[index],
                                    fit: BoxFit.cover,
                                    placeholder: (context, url) => const Center(
                                      child: CircularProgressIndicator(),
                                    ),
                                    errorWidget: (context, url, error) =>
                                        const Center(
                                      child: Icon(Icons.error,
                                          color: Colors.red, size: 50),
                                    ),
                                  ),
                                ),
                              ),
                            ),
                          );
                        },
                      ),
                    ),
                    const SizedBox(
                      height: 20,
                    ),
                    Container(
                      width: MediaQuery.of(context).size.width * 0.9,
                      margin: const EdgeInsets.symmetric(horizontal: 20),
                      child: ZergAndroidPlugin.getNativeAdView(
                        adWidth: MediaQuery.of(context).size.width,
                      ),
                    ),
                    const SizedBox(height: 20),
                    Padding(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 20, vertical: 10),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Icon(
                                Icons.thumb_up,
                                color: textColor,
                                size: 24,
                              ),
                              const SizedBox(width: 10),
                              Text(
                                'For you'.tr,
                                style: TextStyle(
                                  color: textColor,
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 20),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Expanded(
                                child: Container(
                                  margin: const EdgeInsets.only(right: 10),
                                  child: ElevatedButton(
                                    onPressed: () {
                                      Navigator.push(
                                        context,
                                        MaterialPageRoute(
                                          builder: (context) =>
                                              const SubscriptionScreen(),
                                        ),
                                      );
                                    },
                                    style: ElevatedButton.styleFrom(
                                      padding: const EdgeInsets.symmetric(
                                          vertical: 15),
                                      backgroundColor: Colors.black12,
                                      shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(10),
                                      ),
                                    ),
                                    child: Column(
                                      mainAxisSize: MainAxisSize.min,
                                      children: [
                                        Image.asset(
                                          'assets/images/giftbox.jpg',
                                          width: 60,
                                          height: 60,
                                        ),
                                        const SizedBox(height: 6),
                                        Padding(
                                          padding: const EdgeInsets.only(
                                              left: 4, right: 4),
                                          child: Text(
                                            'Special Gift'.tr,
                                            style: TextStyle(color: textColor),
                                            overflow: TextOverflow.ellipsis,
                                            maxLines: 1,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                              ),
                              Expanded(
                                child: Container(
                                  margin: const EdgeInsets.symmetric(
                                      horizontal: 10),
                                  child: ElevatedButton(
                                    onPressed: () {
                                      ZergAndroidPlugin.showIntersAd(
                                        onFinished: () {
                                          Navigator.push(
                                            context,
                                            MaterialPageRoute(
                                              builder: (context) =>
                                                  const MyWorkScreen(),
                                            ),
                                          );
                                        },
                                      );
                                    },
                                    style: ElevatedButton.styleFrom(
                                      padding: const EdgeInsets.symmetric(
                                          vertical: 15),
                                      backgroundColor: Colors.black12,
                                      shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(10),
                                      ),
                                    ),
                                    child: Column(
                                      mainAxisSize: MainAxisSize.min,
                                      children: [
                                        Image.asset(
                                          'assets/images/mywork.png',
                                          width: 60,
                                          height: 60,
                                        ),
                                        const SizedBox(height: 6),
                                        Padding(
                                          padding: const EdgeInsets.only(
                                              left: 4, right: 4),
                                          child: Text(
                                            'My Work'.tr,
                                            style: TextStyle(color: textColor),
                                            overflow: TextOverflow.ellipsis,
                                            maxLines: 1,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                              ),
                              Expanded(
                                child: Container(
                                  margin: const EdgeInsets.only(left: 10),
                                  child: ElevatedButton(
                                    onPressed: () {
                                      CustomRatingBottomSheet
                                          .showFeedBackBottomSheet(
                                              context: context);
                                    },
                                    style: ElevatedButton.styleFrom(
                                      padding: const EdgeInsets.symmetric(
                                          vertical: 15),
                                      backgroundColor: Colors.black12,
                                      shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(10),
                                      ),
                                    ),
                                    child: Column(
                                      mainAxisSize: MainAxisSize.min,
                                      children: [
                                        Image.asset(
                                          'assets/images/star.png',
                                          width: 60,
                                          height: 60,
                                        ),
                                        const SizedBox(height: 6),
                                        Padding(
                                          padding: const EdgeInsets.only(
                                              left: 4, right: 4),
                                          child: Text(
                                            'Rate US'.tr,
                                            style: TextStyle(color: textColor),
                                            overflow: TextOverflow.ellipsis,
                                            maxLines: 1,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    )
                  ],
                ),
              ),
            ),
          ),
          ZergAndroidPlugin.getCollapsibleBannerView(
              alignment: Alignment.bottomCenter)
        ],
      ),
    );
  }
}
