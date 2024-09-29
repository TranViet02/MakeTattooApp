import 'dart:ui';

/// Abstract class to define a drawable object.
abstract class Drawable {
  final bool hidden;

  const Drawable({this.hidden = false});

  void draw(Canvas canvas, Size size);

  bool get isHidden => hidden;

  bool get isNotHidden => !hidden;
}
