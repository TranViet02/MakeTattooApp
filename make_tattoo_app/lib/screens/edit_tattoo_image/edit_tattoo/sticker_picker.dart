import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:get/get.dart';
import 'package:make_tattoo_app/models/photo_models_tattoo.dart';
import 'package:make_tattoo_app/models/remote_config_count_tattoo.dart';
import 'package:make_tattoo_app/utils/style_config.dart';

class StickerPicker extends StatefulWidget {
  final bool isGridView;
  final String selectedCategory;
  final String? selectedTattooPath;
  final void Function(String) onCategorySelected;
  final void Function(String) onTattooSelected;
  final VoidCallback onEditingToggle;
  final VoidCallback onCancel;
  final VoidCallback onGridViewToggle;

  StickerPicker({
    required this.isGridView,
    required this.selectedCategory,
    required this.selectedTattooPath,
    required this.onCategorySelected,
    required this.onTattooSelected,
    required this.onEditingToggle,
    required this.onCancel,
    required this.onGridViewToggle,
  });

  @override
  _StickerPickerState createState() => _StickerPickerState();
}

class _StickerPickerState extends State<StickerPicker> {
  late ImageService _imageService;
  late RemoteConfigService _remoteConfigService;

  @override
  void initState() {
    super.initState();
    _remoteConfigService = RemoteConfigService();
    _imageService = ImageService(
      baseUrl: 'https://hadesgame.studio/tattoo-maker/tattoo',
    );
  }

  Future<List<String>> _getImagesForCategory(String category) async {
    if (category == 'trending') {
      return _getTrendingImages();
    } else {
      final categoryObject = _imageService.getCategories().firstWhere(
            (cat) => cat.category == category,
            orElse: () => ImageCategory(category: category),
          );

      final imageCount = _remoteConfigService.getImageCount(category);
      return List.generate(
        imageCount,
        (index) =>
            '${_imageService.baseUrl}/${category}/${category}_${index + categoryObject.startIndex}.png',
      );
    }
  }

  Future<List<String>> _getTrendingImages() async {
    List<String> trendingImages = [];
    final categories = _imageService.getCategories();

    for (var category
        in categories.where((cat) => cat.category != 'trending')) {
      final numberOfImages =
          _remoteConfigService.getImageCount(category.category);
      if (numberOfImages > 0) {
        final trendingImageUrl =
            '${_imageService.baseUrl}/${category.category}/${category.category}_${category.startIndex}.png';
        trendingImages.add(trendingImageUrl);
      }
    }

    return trendingImages;
  }

  @override
  Widget build(BuildContext context) {
    return Positioned(
      bottom: 0,
      left: 0,
      right: 0,
      child: Container(
        color: Colors.black.withOpacity(0.6),
        height: MediaQuery.of(context).size.height *
            (widget.isGridView ? 0.65 : 0.20),
        child: Column(
          children: [
            Container(
              padding: const EdgeInsets.only(top: 8, right: 5),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  GestureDetector(
                    onTap: widget.onEditingToggle,
                    child: Row(
                      children: [
                        TextButton.icon(
                          onPressed: widget.onEditingToggle,
                          icon: Icon(
                            Icons.edit,
                            color: textColor,
                            size: 18,
                          ),
                          label: Text(
                            "Edit".tr,
                            style: TextStyle(color: textColor, fontSize: 15),
                          ),
                        )
                      ],
                    ),
                  ),
                  Transform.translate(
                    offset: const Offset(-12, 0),
                    child: GestureDetector(
                      onTap: widget.onGridViewToggle,
                      child: Row(
                        children: [
                          Text(
                            widget.isGridView
                                ? 'Add Tattoo'.tr
                                : 'Add Tattoo'.tr,
                            style: TextStyle(color: iconColor, fontSize: 16),
                          ),
                          Icon(
                              widget.isGridView
                                  ? Icons.keyboard_arrow_down
                                  : Icons.keyboard_arrow_up,
                              color: Colors.white),
                        ],
                      ),
                    ),
                  ),
                  GestureDetector(
                    onTap: widget.onCancel,
                    child: Icon(
                      Icons.check,
                      color: iconColor,
                      size: 22,
                    ),
                  ),
                ],
              ),
            ),
            Container(
              height: 26,
              margin: const EdgeInsets.only(top: 3, left: 4),
              child: SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: Row(
                  children: _imageService.getCategories().map((category) {
                    return GestureDetector(
                      onTap: () => widget.onCategorySelected(category.category),
                      child: Container(
                        margin: const EdgeInsets.symmetric(horizontal: 4),
                        padding: const EdgeInsets.symmetric(horizontal: 12),
                        decoration: BoxDecoration(
                          color: widget.selectedCategory == category.category
                              ? iconColor
                              : const Color.fromARGB(255, 138, 127, 127),
                          borderRadius: BorderRadius.circular(20),
                        ),
                        alignment: Alignment.center,
                        child: Text(
                          category.category.capitalize1(),
                          style: TextStyle(
                            color: widget.selectedCategory == category.category
                                ? Colors.black
                                : Colors.white,
                            fontSize: 13,
                          ),
                        ),
                      ),
                    );
                  }).toList(),
                ),
              ),
            ),
            const SizedBox(height: 12),
            Expanded(
              child: FutureBuilder<List<String>>(
                future: _getImagesForCategory(widget.selectedCategory),
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return Center(child: CircularProgressIndicator());
                  } else if (snapshot.hasError) {
                    return Center(child: Text('Error: ${snapshot.error}'));
                  } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
                    return const Center(child: Text('No images available'));
                  } else {
                    final imagePaths = snapshot.data!;
                    return widget.isGridView
                        ? GridView.builder(
                            gridDelegate:
                                const SliverGridDelegateWithFixedCrossAxisCount(
                              crossAxisCount: 2,
                              crossAxisSpacing: 8,
                              mainAxisSpacing: 8,
                            ),
                            itemCount: imagePaths.length,
                            itemBuilder: (context, index) {
                              return GestureDetector(
                                onTap: () =>
                                    widget.onTattooSelected(imagePaths[index]),
                                child: Container(
                                  decoration: BoxDecoration(
                                    color: Colors.white,
                                    borderRadius: BorderRadius.circular(12),
                                    border: Border.all(
                                      color: widget.selectedTattooPath ==
                                              imagePaths[index]
                                          ? iconColor
                                          : Colors.transparent,
                                      width: 1.3,
                                    ),
                                  ),
                                  child: ClipRRect(
                                    borderRadius: BorderRadius.circular(8),
                                    child: CachedNetworkImage(
                                      imageUrl: imagePaths[index],
                                      placeholder: (context, url) =>
                                          const Center(
                                              child:
                                                  CircularProgressIndicator()),
                                      errorWidget: (context, url, error) =>
                                          const Center(
                                        child: Icon(Icons.error,
                                            color: Colors.red, size: 50),
                                      ),
                                      fit: BoxFit.cover,
                                    ),
                                  ),
                                ),
                              );
                            },
                          )
                        : ListView.builder(
                            scrollDirection: Axis.horizontal,
                            itemCount: imagePaths.length,
                            itemBuilder: (context, index) {
                              return GestureDetector(
                                onTap: () =>
                                    widget.onTattooSelected(imagePaths[index]),
                                child: Padding(
                                  padding: const EdgeInsets.only(left: 10),
                                  child: Container(
                                    width: 48,
                                    height: 58,
                                    decoration: BoxDecoration(
                                      color: Colors.white,
                                      borderRadius: BorderRadius.circular(12),
                                      border: Border.all(
                                        color: widget.selectedTattooPath ==
                                                imagePaths[index]
                                            ? iconColor
                                            : Colors.transparent,
                                        width: 1.3,
                                      ),
                                    ),
                                    child: ClipRRect(
                                      borderRadius: BorderRadius.circular(8),
                                      child: CachedNetworkImage(
                                        imageUrl: imagePaths[index],
                                        placeholder: (context, url) =>
                                            const Center(
                                          child: CircularProgressIndicator(),
                                        ),
                                        errorWidget: (context, url, error) =>
                                            const Center(
                                                child: Icon(Icons.error,
                                                    color: Colors.red,
                                                    size: 50)),
                                        fit: BoxFit.cover,
                                      ),
                                    ),
                                  ),
                                ),
                              );
                            },
                          );
                  }
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}

extension CapitalizeFirstLetterOfList on String {
  String capitalize1() {
    if (isEmpty) {
      return this;
    }
    return this[0].toUpperCase() + substring(1);
  }
}
