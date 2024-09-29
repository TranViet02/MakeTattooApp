import 'package:flutter/material.dart';
import 'package:flutter_phosphor_icons/flutter_phosphor_icons.dart';
import 'package:get/get.dart';
import 'package:make_tattoo_app/providers/app_image_provider.dart';
import 'package:make_tattoo_app/screens/edit_tattoo_image/edit_tattoo_screen.dart';
import 'package:make_tattoo_app/utils/style_config.dart';
import 'package:provider/provider.dart';
import 'package:zerg_android_plugin/zerg_android_plugin.dart';

class MockupScreen extends StatefulWidget {
  const MockupScreen({super.key, required this.stickerPath});
  final String stickerPath;

  @override
  _MockupScreenState createState() => _MockupScreenState();
}

class _MockupScreenState extends State<MockupScreen> {
  final Map<String, List<String>> mockupCategories = {
    'Back': [
      'assets/mockup/body1.jpg',
      'assets/mockup/body2.jpg',
      'assets/mockup/body3.jpg',
    ],
    'Hand': [
      'assets/mockup/body4.jpg',
      'assets/mockup/body5.jpg',
    ],
  };

  String _selectedCategory = 'Back';

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
          "Select Photo".tr,
          style: TextStyle(color: textColor),
        ),
      ),
      body: Column(
        children: [
          Container(
            padding: const EdgeInsets.symmetric(vertical: 8),
            color: backgroundColor,
            child: SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Row(
                children: mockupCategories.keys.map((String category) {
                  return Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 8.0),
                    child: ElevatedButton(
                      onPressed: () {
                        setState(() {
                          _selectedCategory = category;
                        });
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: _selectedCategory == category
                            ? iconColor
                            : Colors.grey,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8.0),
                        ),
                      ),
                      child: Text(category),
                    ),
                  );
                }).toList(),
              ),
            ),
          ),
          Expanded(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: GridView.builder(
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 2,
                  crossAxisSpacing: 8.0,
                  mainAxisSpacing: 8.0,
                ),
                itemCount: mockupCategories[_selectedCategory]?.length ?? 0,
                itemBuilder: (context, index) {
                  final imagePath = mockupCategories[_selectedCategory]![index];
                  return GestureDetector(
                    onTap: () {
                      ZergAndroidPlugin.showIntersAd(
                        onFinished: () {
                          final imageProvider = Provider.of<AppImageProvider>(
                              context,
                              listen: false);
                          imageProvider.changeImageFromAssets(imagePath);
                          Navigator.of(context).pushReplacement(
                            MaterialPageRoute(
                              builder: (context) => EditTattooScreen(
                                imagePath: imagePath,
                                stickerPath: widget.stickerPath,
                              ),
                            ),
                          );
                        },
                      );
                    },
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(8.0),
                      child: Image.asset(imagePath, fit: BoxFit.cover),
                    ),
                  );
                },
              ),
            ),
          ),
        ],
      ),
    );
  }
}
