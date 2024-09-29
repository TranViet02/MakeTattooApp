class ImageService {
  final String baseUrl;

  ImageService({required this.baseUrl});

  List<ImageCategory> getCategories() {
    return [
      ImageCategory(category: 'trending'),
      ImageCategory(category: 'traditional'),
      ImageCategory(category: 'japanese'),
      ImageCategory(category: 'light'),
      ImageCategory(category: 'realistic'),
      ImageCategory(category: 'blackwork', startIndex: 1),
    ];
  }
}

class ImageCategory {
  final String category;
  final int startIndex;

  ImageCategory({
    required this.category,
    this.startIndex = 0,
  });
}
