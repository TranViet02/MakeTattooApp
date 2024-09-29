import 'dart:ui';
import 'package:flutter/material.dart';

import 'drawable.dart';

import 'dart:math';

abstract class ObjectDrawable extends Drawable {
  static final Paint defaultAssistPaint = Paint()
    ..strokeWidth = 1.5
    ..color = Colors.blue;
  static final defaultRotationAssistPaint = Paint()
    ..strokeWidth = 1.5
    ..color = Colors.pink;
  static const double minScale = 0.001;

  @Deprecated(
      "min_scale is deprecated to conform with flutter_lints, use minScale instead")
  double get min_scale => minScale;
  final Offset position;
  final double scale;

  final double rotationAngle;
  final Set<ObjectDrawableAssist> assists;
  final Map<ObjectDrawableAssist, Paint> assistPaints;
  final bool locked;
  const ObjectDrawable({
    required this.position,
    this.rotationAngle = 0,
    double scale = 1,
    this.assists = const <ObjectDrawableAssist>{},
    this.assistPaints = const <ObjectDrawableAssist, Paint>{},
    this.locked = false,
    bool hidden = false,
  })  : scale = scale < minScale ? minScale : scale,
        super(hidden: hidden);
  void drawAssists(Canvas canvas, Size size) {
    if (assists.contains(ObjectDrawableAssist.rotation)) {
      final angleTan = tan(rotationAngle);
      final intersections =
          _calculateBoxIntersections(position, angleTan, size);

      if (intersections.length == 2) {
        canvas.drawLine(
          intersections[0],
          intersections[1],
          assistPaints[ObjectDrawableAssist.rotation] ??
              defaultRotationAssistPaint,
        );
      }
    }
    if (assists.contains(ObjectDrawableAssist.horizontal)) {
      canvas.drawLine(Offset(0, position.dy), Offset(size.width, position.dy),
          assistPaints[ObjectDrawableAssist.horizontal] ?? defaultAssistPaint);
    }

    if (assists.contains(ObjectDrawableAssist.vertical)) {
      canvas.drawLine(Offset(position.dx, 0), Offset(position.dx, size.height),
          assistPaints[ObjectDrawableAssist.horizontal] ?? defaultAssistPaint);
    }
  }

  @override
  void draw(Canvas canvas, Size size) {
    drawAssists(canvas, size);
    canvas.save();
    canvas.translate(position.dx, position.dy);
    canvas.rotate(rotationAngle);
    canvas.translate(-position.dx, -position.dy);
    drawObject(canvas, size);
    canvas.restore();
  }

  void drawObject(Canvas canvas, Size size);
  Size getSize({double minWidth = 0.0, double maxWidth = double.infinity});

  ObjectDrawable copyWith({
    bool? hidden,
    Set<ObjectDrawableAssist>? assists,
    Offset? position,
    double? rotation,
    double? scale,
    bool? locked,
  });
  List<Offset> _calculateBoxIntersections(
      Offset point, double angleTan, Size size) {
    final intersections = <Offset>[];
    double coordinate = point.dx - (point.dy / angleTan);
    if (coordinate >= 0 && coordinate <= size.width) {
      intersections.add(Offset(coordinate, 0));
    }
    coordinate = (size.height - point.dy) / angleTan + point.dx;
    if (coordinate >= 0 && coordinate <= size.width) {
      intersections.add(Offset(coordinate, size.height));
    }
    coordinate = point.dy - angleTan * point.dx;
    if (coordinate >= 0 && coordinate <= size.height) {
      intersections.add(Offset(0, coordinate));
    }
    coordinate = angleTan * (size.width - point.dx) + point.dy;
    if (coordinate >= 0 && coordinate <= size.height) {
      intersections.add(Offset(size.width, coordinate));
    }
    return intersections;
  }
}

enum ObjectDrawableAssist {
  horizontal,
  vertical,
  rotation,
}
