import 'dart:io';
import 'package:flutter/material.dart';
import 'package:make_tattoo_app/utils/style_config.dart';

class ImageDetailScreen extends StatelessWidget {
  final String imagePath;

  const ImageDetailScreen({Key? key, required this.imagePath})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black12,
      appBar: AppBar(
        backgroundColor: Colors.black12,
        centerTitle: true,
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: textColor),
          onPressed: () {
            Navigator.of(context).pop();
          },
        ),
      ),
      body: Center(
        child: Image.file(
          File(imagePath),
          fit: BoxFit.cover,
        ),
      ),
    );
  }
}
