import 'dart:ui';
import 'package:flutter/rendering.dart';
import 'object_drawable.dart';

class ImageDrawable extends ObjectDrawable {
  final Image image;
  final bool flipped;
  final double opacity;
  final ColorFilter? colorFilter;

  ImageDrawable({
    required Offset position,
    double rotationAngle = 0,
    double scale = 1,
    Set<ObjectDrawableAssist> assists = const <ObjectDrawableAssist>{},
    Map<ObjectDrawableAssist, Paint> assistPaints =
        const <ObjectDrawableAssist, Paint>{},
    bool locked = false,
    bool hidden = false,
    required this.image,
    this.flipped = false,
    this.opacity = 1,
    this.colorFilter,
  }) : super(
            position: position,
            rotationAngle: rotationAngle,
            scale: scale,
            assists: assists,
            assistPaints: assistPaints,
            hidden: hidden,
            locked: locked);

  ImageDrawable.fittedToSize({
    required Offset position,
    required Size size,
    double rotationAngle = 0,
    Set<ObjectDrawableAssist> assists = const <ObjectDrawableAssist>{},
    Map<ObjectDrawableAssist, Paint> assistPaints =
        const <ObjectDrawableAssist, Paint>{},
    bool locked = false,
    bool hidden = false,
    required Image image,
    bool flipped = false,
    double opacity = 1.0,
    ColorFilter? colorFilter,
  }) : this(
          position: position,
          rotationAngle: rotationAngle,
          scale: _calculateScaleFittedToSize(image, size),
          assists: assists,
          assistPaints: assistPaints,
          image: image,
          flipped: flipped,
          hidden: hidden,
          locked: locked,
          opacity: opacity,
          colorFilter: colorFilter,
        );

  @override
  ImageDrawable copyWith({
    bool? hidden,
    Set<ObjectDrawableAssist>? assists,
    Offset? position,
    double? rotation,
    double? scale,
    Image? image,
    bool? flipped,
    bool? locked,
    double? opacity,
    ColorFilter? colorFilter,
  }) {
    return ImageDrawable(
      hidden: hidden ?? this.hidden,
      assists: assists ?? this.assists,
      position: position ?? this.position,
      rotationAngle: rotation ?? rotationAngle,
      scale: scale ?? this.scale,
      image: image ?? this.image,
      flipped: flipped ?? this.flipped,
      locked: locked ?? this.locked,
      opacity: opacity ?? this.opacity,
      colorFilter: colorFilter ?? this.colorFilter,
    );
  }

  @override
  void drawObject(Canvas canvas, Size size) {
    final scaledSize =
        Offset(image.width.toDouble(), image.height.toDouble()) * scale;
    final position = this.position.scale(flipped ? -1 : 1, 1);

    if (flipped) canvas.scale(-1, 1);

    final paint = Paint()
      ..color = Color.fromRGBO(255, 255, 255, opacity)
      ..colorFilter = colorFilter; // Áp dụng ColorFilter

    canvas.drawImageRect(
        image,
        Rect.fromPoints(Offset.zero,
            Offset(image.width.toDouble(), image.height.toDouble())),
        Rect.fromPoints(position - scaledSize / 2, position + scaledSize / 2),
        paint);
  }

  @override
  Size getSize({double minWidth = 0.0, double maxWidth = double.infinity}) {
    return Size(
      image.width * scale,
      image.height * scale,
    );
  }

  static double _calculateScaleFittedToSize(Image image, Size size) {
    if (image.width >= image.height) {
      return size.width / image.width;
    } else {
      return size.height / image.height;
    }
  }
}
