import 'dart:io';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:make_tattoo_app/screens/select_image_tattoo/details.dart';
import 'package:make_tattoo_app/utils/style_config.dart';
import 'package:shared_preferences/shared_preferences.dart';

class MyWorkScreen extends StatefulWidget {
  const MyWorkScreen({super.key});

  @override
  State<MyWorkScreen> createState() => _MyWorkScreenState();
}

class _MyWorkScreenState extends State<MyWorkScreen> {
  late Future<List<String>> _imagePathsFuture;

  @override
  void initState() {
    super.initState();
    _imagePathsFuture = _loadImagePaths();
  }

  Future<List<String>> _loadImagePaths() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getStringList('saved_image_paths') ?? [];
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black12,
      appBar: AppBar(
        backgroundColor: Colors.black12,
        centerTitle: true,
        leading: BackButtonWidget(),
        title: Text(
          'My Creation'.tr,
          style: TextStyle(color: textColor),
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.only(top: 20, left: 10, right: 10),
        child: FutureBuilder<List<String>>(
          future: _imagePathsFuture,
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Center(
                child: CircularProgressIndicator(),
              );
            } else {
              final imagePaths = snapshot.data!;
              return GridView.builder(
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 2,
                  crossAxisSpacing: 8.0,
                  mainAxisSpacing: 8.0,
                ),
                itemCount: imagePaths.length,
                itemBuilder: (context, index) {
                  return GestureDetector(
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => ImageDetailScreen(
                            imagePath: imagePaths[index],
                          ),
                        ),
                      );
                    },
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(14),
                      child: GridTile(
                        child: Image.file(
                          File(imagePaths[index]),
                          fit: BoxFit.cover,
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
    );
  }
}
