import 'dart:io';
import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class AppImageProvider extends ChangeNotifier {
  Uint8List? currentImage;
  double rotationAngle = 0.0;
  bool flipVertical = false;
  String? selectedMockup;

  void changeImageFile(File image) {
    currentImage = image.readAsBytesSync();
    rotationAngle = 0.0; // Đặt lại góc xoay
    flipVertical = false;
    notifyListeners();
  }

  void changeImage(Uint8List image) {
    currentImage = image;
    rotationAngle = 0.0;
    flipVertical = false;
    notifyListeners();
  }

  void setRotationAngle(double angle) {
    rotationAngle = angle;
    notifyListeners();
  }

  void setFlipVertical(bool flip) {
    flipVertical = flip;
    notifyListeners();
  }

  void reset() {
    rotationAngle = 0.0;
    flipVertical = false;
    notifyListeners();
  }

  Future<void> changeImageFromAssets(String assetPath) async {
    rotationAngle = 0.0; // Đặt lại góc xoay
    flipVertical = false;
    final ByteData data = await rootBundle.load(assetPath);
    currentImage = data.buffer.asUint8List();
    notifyListeners();
  }
}
