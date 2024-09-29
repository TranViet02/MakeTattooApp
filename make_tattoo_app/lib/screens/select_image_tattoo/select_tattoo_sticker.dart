import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:make_tattoo_app/models/photo_models_tattoo.dart';
import 'package:make_tattoo_app/models/remote_config_count_tattoo.dart';
import 'package:make_tattoo_app/screens/preview/preview_sticker.dart';
import 'package:make_tattoo_app/utils/style_config.dart';

class TattooSelectSticker extends StatefulWidget {
  const TattooSelectSticker({super.key});

  @override
  State<TattooSelectSticker> createState() => _TattooSelectStickerState();
}

class _TattooSelectStickerState extends State<TattooSelectSticker> {
  String _selectedCategory = 'trending';

  final RemoteConfigService remoteConfigService = RemoteConfigService();
  final ImageService imageService = ImageService(
    baseUrl: 'https://hadesgame.studio/tattoo-maker/tattoo',
  );

  List<String> get _allTrendingTattoos {
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

    return trendingImages;
  }

  List<String> get _filteredTattoos {
    if (_selectedCategory == 'trending') {
      return _allTrendingTattoos;
    } else {
      final category = imageService.getCategories().firstWhere(
            (cat) => cat.category == _selectedCategory,
          );
      final numberOfImages =
          remoteConfigService.getImageCount(category.category);
      return List.generate(
        numberOfImages,
        (index) =>
            '${imageService.baseUrl}/${category.category}/${category.category}_${index + category.startIndex}.png',
      );
    }
  }

  String capitalize(String text) {
    if (text.isEmpty) {
      return text;
    }
    return text[0].toUpperCase() + text.substring(1);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: backgroundColor,
      appBar: AppBar(
        backgroundColor: backgroundColor,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () {
            Navigator.of(context).pop();
          },
        ),
        centerTitle: true,
        title: Text(
          'TATTOO STICKER'.tr,
          style: TextStyle(
              color: textColor, fontSize: 18, fontWeight: FontWeight.bold),
        ),
      ),
      body: Column(
        children: [
          const SizedBox(height: 10),
          Container(
            height: 30,
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              itemCount: imageService.getCategories().length,
              itemBuilder: (context, index) {
                final category = imageService.getCategories()[index].category;
                final isSelected = category == _selectedCategory;
                return GestureDetector(
                  onTap: () {
                    setState(() {
                      _selectedCategory = category;
                    });
                  },
                  child: Padding(
                    padding: const EdgeInsets.only(left: 10),
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 12,
                      ),
                      margin: const EdgeInsets.symmetric(
                        horizontal: 3,
                      ),
                      decoration: BoxDecoration(
                        color:
                            isSelected ? Colors.yellow[900] : Colors.grey[800],
                        borderRadius: BorderRadius.circular(15),
                        boxShadow: [
                          if (isSelected)
                            BoxShadow(
                              color: Colors.black.withOpacity(0.3),
                              offset: const Offset(0, 4),
                              blurRadius: 6,
                            ),
                        ],
                      ),
                      alignment: Alignment.center,
                      child: Text(
                        capitalize(category),
                        style: const TextStyle(
                          color: Colors.white70,
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
                );
              },
            ),
          ),
          const SizedBox(height: 15),
          Expanded(
            child: GridView.builder(
              padding: const EdgeInsets.only(top: 20, left: 10, right: 10),
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2,
                crossAxisSpacing: 8,
                mainAxisSpacing: 8,
              ),
              itemCount: _filteredTattoos.length,
              itemBuilder: (context, index) {
                final tattooUrl = _filteredTattoos[index];
                return GestureDetector(
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) =>
                            PreviewScreen(imagePath: tattooUrl),
                      ),
                    );
                  },
                  child: Container(
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: CachedNetworkImage(
                      imageUrl: tattooUrl,
                      placeholder: (context, url) => const Center(
                        child: CircularProgressIndicator(),
                      ),
                      fit: BoxFit.cover,
                    ),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
