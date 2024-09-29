part of 'flutter_painter.dart';

class _FreeStyleWidget extends StatefulWidget {
  final Widget child;

  const _FreeStyleWidget({
    Key? key,
    required this.child,
  }) : super(key: key);

  @override
  _FreeStyleWidgetState createState() => _FreeStyleWidgetState();
}

class _FreeStyleWidgetState extends State<_FreeStyleWidget> {
  PathDrawable? drawable;

  @override
  Widget build(BuildContext context) {
    if (settings.mode == FreeStyleMode.none || shapeSettings.factory != null) {
      return widget.child;
    }

    return RawGestureDetector(
      behavior: HitTestBehavior.opaque,
      gestures: {
        _DragGestureDetector:
            GestureRecognizerFactoryWithHandlers<_DragGestureDetector>(
          () => _DragGestureDetector(
            onHorizontalDragDown: _handleHorizontalDragDown,
            onHorizontalDragUpdate: _handleHorizontalDragUpdate,
            onHorizontalDragUp: _handleHorizontalDragUp,
          ),
          (_) {},
        ),
      },
      child: widget.child,
    );
  }

  FreeStyleSettings get settings =>
      PainterController.of(context).value.settings.freeStyle;

  ShapeSettings get shapeSettings =>
      PainterController.of(context).value.settings.shape;

  void _handleHorizontalDragDown(Offset globalPosition) {
    if (this.drawable != null) return;

    final PathDrawable drawable;
    if (settings.mode == FreeStyleMode.draw) {
      drawable = FreeStyleDrawable(
        path: [_globalToLocal(globalPosition)],
        color: settings.color,
        strokeWidth: settings.strokeWidth,
      );

      PainterController.of(context).addDrawables([drawable]);
    } else if (settings.mode == FreeStyleMode.erase) {
      drawable = EraseDrawable(
        path: [_globalToLocal(globalPosition)],
        strokeWidth: settings.strokeWidth,
      );
      PainterController.of(context).groupDrawables();

      PainterController.of(context).addDrawables([drawable], newAction: false);
    } else {
      return;
    }

    this.drawable = drawable;
  }

  void _handleHorizontalDragUpdate(Offset globalPosition) {
    final drawable = this.drawable;
    if (drawable == null) return;

    final newDrawable = drawable.copyWith(
      path: List<Offset>.from(drawable.path)
        ..add(_globalToLocal(globalPosition)),
    );
    PainterController.of(context)
        .replaceDrawable(drawable, newDrawable, newAction: false);
    this.drawable = newDrawable;
  }

  void _handleHorizontalDragUp() {
    DrawableCreatedNotification(drawable).dispatch(context);
    drawable = null;
  }

  Offset _globalToLocal(Offset globalPosition) {
    final getBox = context.findRenderObject() as RenderBox;

    return getBox.globalToLocal(globalPosition);
  }
}

class _DragGestureDetector extends OneSequenceGestureRecognizer {
  _DragGestureDetector({
    required this.onHorizontalDragDown,
    required this.onHorizontalDragUpdate,
    required this.onHorizontalDragUp,
  });

  final ValueSetter<Offset> onHorizontalDragDown;
  final ValueSetter<Offset> onHorizontalDragUpdate;
  final VoidCallback onHorizontalDragUp;

  bool _isTrackingGesture = false;

  @override
  void addPointer(PointerEvent event) {
    if (!_isTrackingGesture) {
      resolve(GestureDisposition.accepted);
      startTrackingPointer(event.pointer);
      _isTrackingGesture = true;
    } else {
      stopTrackingPointer(event.pointer);
    }
  }

  @override
  void handleEvent(PointerEvent event) {
    if (event is PointerDownEvent) {
      onHorizontalDragDown(event.position);
    } else if (event is PointerMoveEvent) {
      onHorizontalDragUpdate(event.position);
    } else if (event is PointerUpEvent) {
      onHorizontalDragUp();
      stopTrackingPointer(event.pointer);
      _isTrackingGesture = false;
    }
  }

  @override
  String get debugDescription => '_DragGestureDetector';

  @override
  void didStopTrackingLastPointer(int pointer) {}
}
