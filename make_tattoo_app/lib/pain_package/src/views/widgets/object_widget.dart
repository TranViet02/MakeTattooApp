part of 'flutter_painter.dart';

class _ObjectWidget extends StatefulWidget {
  final Widget child;
  final bool interactionEnabled;
  final VoidCallback handleOpenEdit;

  const _ObjectWidget({
    Key? key,
    required this.child,
    this.interactionEnabled = true,
    required this.handleOpenEdit,
  }) : super(key: key);

  @override
  _ObjectWidgetState createState() => _ObjectWidgetState();
}

class _ObjectWidgetState extends State<_ObjectWidget> {
  bool isEdit = false;
  static Set<double> assistAngles = <double>{
    0,
    pi / 4,
    pi / 2,
    3 * pi / 4,
    pi,
    5 * pi / 4,
    3 * pi / 2,
    7 * pi / 4,
    2 * pi
  };

  PainterController? controller;
  double transformationScale = 1;
  double get objectPadding => 25 / transformationScale;
  static Duration get controlsTransitionDuration =>
      const Duration(milliseconds: 100);
  double get controlsSize =>
      (settings.enlargeControlsResolver() ? 20 : 10) / transformationScale;

  double get selectedBlurRadius => 2 / transformationScale;
  double get selectedBorderWidth => 1 / transformationScale;
  Map<int, Offset> drawableInitialLocalFocalPoints = {};
  Map<int, ObjectDrawable> initialScaleDrawables = {};
  Map<ObjectDrawableAssist, Set<int>> assistDrawables = {
    for (var e in ObjectDrawableAssist.values) e: <int>{}
  };
  Map<int, bool> controlsAreActive = {
    for (var e in List.generate(8, (index) => index)) e: false
  };
  StreamSubscription<PainterEvent>? controllerEventSubscription;
  List<ObjectDrawable> get drawables => PainterController.of(context)
      .value
      .drawables
      .whereType<ObjectDrawable>()
      .toList();
  bool cancelControlsAnimation = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance?.addPostFrameCallback((timestamp) {
      controllerEventSubscription =
          PainterController.of(context).events.listen((event) {
        if (event is SelectedObjectDrawableRemovedEvent) {
          setState(() {
            cancelControlsAnimation = true;
          });
        }
      });
      PainterController.of(context)
          .transformationController
          .addListener(onTransformUpdated);
    });
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    controller = PainterController.of(context);
  }

  @override
  void dispose() {
    controllerEventSubscription?.cancel();
    controller?.transformationController.removeListener(onTransformUpdated);
    super.dispose();
  }

  void removeDrawable(ObjectDrawable drawable) {
    setState(() {
      PainterController.of(context).removeDrawable(drawable);
    });
  }

  @override
  Widget build(BuildContext context) {
    final drawables = this.drawables;

    return LayoutBuilder(builder: (context, constraints) {
      return Stack(
        children: [
          Positioned.fill(
            child:
                GestureDetector(onTap: onBackgroundTapped, child: widget.child),
          ),
          ...drawables.asMap().entries.map((entry) {
            final drawable = entry.value;
            final selected = drawable == controller?.selectedObjectDrawable;
            final size = drawable.getSize(maxWidth: constraints.maxWidth);
            final widget = Padding(
              padding: EdgeInsets.all(objectPadding),
              child: SizedBox(
                width: size.width,
                height: size.height,
              ),
            );
            return Positioned(
              top: drawable.position.dy - objectPadding - size.height / 2,
              left: drawable.position.dx - objectPadding - size.width / 2,
              child: Transform.rotate(
                angle: drawable.rotationAngle,
                transformHitTests: true,
                child: Container(
                  child: freeStyleSettings.mode != FreeStyleMode.none
                      ? widget
                      : MouseRegion(
                          cursor: drawable.locked
                              ? MouseCursor.defer
                              : SystemMouseCursors.allScroll,
                          child: GestureDetector(
                            behavior: HitTestBehavior.opaque,
                            onTap: () => tapDrawable(drawable),
                            onScaleStart: (details) =>
                                onDrawableScaleStart(entry, details),
                            onScaleUpdate: (details) =>
                                onDrawableScaleUpdate(entry, details),
                            onScaleEnd: (_) => onDrawableScaleEnd(entry),
                            child: AnimatedSwitcher(
                              duration: controlsTransitionDuration,
                              child: selected
                                  ? Stack(
                                      children: [
                                        widget,
                                        Positioned(
                                          top: objectPadding -
                                              (controlsSize / 1.9),
                                          bottom: objectPadding -
                                              (controlsSize / 2),
                                          left: objectPadding -
                                              (controlsSize / 2),
                                          right: objectPadding -
                                              (controlsSize / 2),
                                          child: Builder(
                                            builder: (context) {
                                              return Container(
                                                decoration: BoxDecoration(
                                                  border: Border.all(
                                                      color: Colors.black,
                                                      width:
                                                          selectedBorderWidth),
                                                ),
                                              );
                                            },
                                          ),
                                        ),
                                        if (settings
                                            .showScaleRotationControlsResolver()) ...[
                                          Positioned(
                                            bottom:
                                                objectPadding - (controlsSize),
                                            left:
                                                objectPadding - (controlsSize),
                                            width: controlsSize,
                                            height: controlsSize,
                                            child: MouseRegion(
                                              cursor: SystemMouseCursors
                                                  .resizeDownLeft,
                                              child: GestureDetector(
                                                onTap: () {
                                                  this.widget.handleOpenEdit();
                                                },
                                                onPanStart: (details) =>
                                                    onScaleControlPanStart(
                                                        1, entry, details),
                                                onPanUpdate: (details) =>
                                                    onScaleControlPanUpdate(
                                                        entry,
                                                        details,
                                                        constraints,
                                                        true),
                                                onPanEnd: (details) =>
                                                    onScaleControlPanEnd(
                                                        1, entry, details),
                                                child: _ObjectControlBox(
                                                  active:
                                                      controlsAreActive[1] ??
                                                          false,
                                                  icon: const Icon(
                                                    Icons.edit,
                                                    color: Colors.white,
                                                    size: 20,
                                                  ),
                                                ),
                                              ),
                                            ),
                                          ),
                                          Positioned(
                                            top: objectPadding - (controlsSize),
                                            right:
                                                objectPadding - (controlsSize),
                                            width: controlsSize,
                                            height: controlsSize,
                                            child: MouseRegion(
                                              cursor: initialScaleDrawables
                                                      .containsKey(entry.key)
                                                  ? SystemMouseCursors.grabbing
                                                  : SystemMouseCursors.grab,
                                              child: GestureDetector(
                                                onPanStart: (details) =>
                                                    onRotationControlPanStart(
                                                        2, entry, details),
                                                onPanUpdate: (details) =>
                                                    onRotationControlPanUpdate(
                                                        entry, details, size),
                                                onPanEnd: (details) =>
                                                    onRotationControlPanEnd(
                                                        2, entry, details),
                                                child: _ObjectControlBox(
                                                  shape: BoxShape.circle,
                                                  active:
                                                      controlsAreActive[2] ??
                                                          false,
                                                  onTap: onBackgroundTapped,
                                                  onCancelTap: () {
                                                    removeDrawable(drawable);
                                                  },
                                                  icon: const Icon(
                                                    Icons.cancel,
                                                    color: Colors.white,
                                                    size: 20,
                                                  ),
                                                ),
                                              ),
                                            ),
                                          ),
                                          Positioned(
                                            top: objectPadding - (controlsSize),
                                            left:
                                                objectPadding - (controlsSize),
                                            width: controlsSize,
                                            height: controlsSize,
                                            child: MouseRegion(
                                              cursor: initialScaleDrawables
                                                      .containsKey(entry.key)
                                                  ? SystemMouseCursors.grabbing
                                                  : SystemMouseCursors.grab,
                                              child: GestureDetector(
                                                onTap: () {
                                                  final imageDrawable = controller
                                                      ?.selectedObjectDrawable;
                                                  if (imageDrawable
                                                      is! ImageDrawable) return;
                                                  controller?.replaceDrawable(
                                                    imageDrawable,
                                                    imageDrawable.copyWith(
                                                        flipped: !imageDrawable
                                                            .flipped),
                                                  );
                                                },
                                                child: _ObjectControlBox(
                                                  shape: BoxShape.circle,
                                                  active:
                                                      controlsAreActive[2] ??
                                                          false,
                                                  icon: const Icon(
                                                    Icons.flip,
                                                    color: Colors.white,
                                                    size: 20,
                                                  ),
                                                ),
                                              ),
                                            ),
                                          ),
                                          Positioned(
                                            bottom:
                                                objectPadding - (controlsSize),
                                            right:
                                                objectPadding - (controlsSize),
                                            width: controlsSize,
                                            height: controlsSize,
                                            child: MouseRegion(
                                              cursor: SystemMouseCursors
                                                  .resizeDownRight,
                                              child: GestureDetector(
                                                onPanStart: (details) =>
                                                    onScaleControlPanStart(
                                                        3, entry, details),
                                                onPanUpdate: (details) =>
                                                    onScaleControlPanUpdate(
                                                        entry,
                                                        details,
                                                        constraints,
                                                        false),
                                                onPanEnd: (details) =>
                                                    onScaleControlPanEnd(
                                                        3, entry, details),
                                                child: _ObjectControlBox(
                                                  active:
                                                      controlsAreActive[3] ??
                                                          false,
                                                  icon: const Icon(
                                                    Icons
                                                        .document_scanner_rounded,
                                                    color: Colors.white,
                                                    size: 19,
                                                  ),
                                                ),
                                              ),
                                            ),
                                          ),
                                        ],
                                      ],
                                    )
                                  : widget,
                              transitionBuilder: (child, animation) {
                                return FadeTransition(
                                  opacity: animation,
                                  child: child,
                                );
                              },
                              layoutBuilder: (child, previousChildren) {
                                if (cancelControlsAnimation) {
                                  cancelControlsAnimation = false;
                                  return child ?? const SizedBox();
                                }
                                return AnimatedSwitcher.defaultLayoutBuilder(
                                    child, previousChildren);
                              },
                            ),
                          ),
                        ),
                ),
              ),
            );
          }),
        ],
      );
    });
  }

  ObjectSettings get settings =>
      PainterController.of(context).value.settings.object;
  FreeStyleSettings get freeStyleSettings =>
      PainterController.of(context).value.settings.freeStyle;

  void onBackgroundTapped() {
    SelectedObjectDrawableUpdatedNotification(null).dispatch(context);
    setState(() {
      controller?.deselectObjectDrawable();
    });
  }

  void tapDrawable(ObjectDrawable drawable) {
    if (drawable.locked) return;

    if (controller?.selectedObjectDrawable == drawable) {
      ObjectDrawableReselectedNotification(drawable).dispatch(context);
    } else {
      SelectedObjectDrawableUpdatedNotification(drawable).dispatch(context);
    }
    setState(() {
      controller?.selectObjectDrawable(drawable);
    });
  }

  void onDrawableScaleStart(
      MapEntry<int, ObjectDrawable> entry, ScaleStartDetails details) {
    if (!widget.interactionEnabled) return;

    final index = entry.key;
    final drawable = entry.value;

    if (index < 0 || drawable.locked) return;

    setState(() {
      controller?.selectObjectDrawable(entry.value);
    });

    initialScaleDrawables[index] = drawable;
    final rotateOffset = Matrix4.rotationZ(drawable.rotationAngle)
      ..translate(details.localFocalPoint.dx, details.localFocalPoint.dy)
      ..rotateZ(-drawable.rotationAngle);
    drawableInitialLocalFocalPoints[index] =
        Offset(rotateOffset[12], rotateOffset[13]);

    updateDrawable(drawable, drawable, newAction: true);
  }

  void onDrawableScaleEnd(MapEntry<int, ObjectDrawable> entry) {
    if (!widget.interactionEnabled) return;

    final index = entry.key;
    final drawable = drawables[index];
    drawableInitialLocalFocalPoints.remove(index);
    initialScaleDrawables.remove(index);
    for (final assistSet in assistDrawables.values) {
      assistSet.remove(index);
    }
    final newDrawable = drawable.copyWith(assists: {});

    updateDrawable(drawable, newDrawable);
  }

  void onDrawableScaleUpdate(
      MapEntry<int, ObjectDrawable> entry, ScaleUpdateDetails details) {
    if (!widget.interactionEnabled) return;

    final index = entry.key;
    final drawable = entry.value;
    if (index < 0) return;

    final initialDrawable = initialScaleDrawables[index];
    final initialLocalFocalPoint =
        drawableInitialLocalFocalPoints[index] ?? Offset.zero;

    if (initialDrawable == null) return;

    final initialPosition = initialDrawable.position - initialLocalFocalPoint;
    final initialRotation = initialDrawable.rotationAngle;
    final rotateOffset = Matrix4.identity()
      ..rotateZ(initialRotation)
      ..translate(details.localFocalPoint.dx, details.localFocalPoint.dy)
      ..rotateZ(-initialRotation);
    final position =
        initialPosition + Offset(rotateOffset[12], rotateOffset[13]);
    final scale = initialDrawable.scale * details.scale;
    var rotation = (initialRotation + details.rotation).remainder(pi * 2);
    if (rotation < 0) rotation += pi * 2;
    final center = this.center;

    final double? closestAssistAngle;
    if (settings.layoutAssist.enabled) {
      calculatePositionalAssists(
        settings.layoutAssist,
        index,
        position,
        center,
      );
      closestAssistAngle = calculateRotationalAssist(
        settings.layoutAssist,
        index,
        rotation,
      );
    } else {
      closestAssistAngle = null;
    }
    final assists = settings.layoutAssist.enabled
        ? assistDrawables.entries
            .where((element) => element.value.contains(index))
            .map((e) => e.key)
            .toSet()
        : <ObjectDrawableAssist>{};
    if (details.pointerCount < 2) assists.remove(ObjectDrawableAssist.rotation);
    final assistedPosition = Offset(
      assists.contains(ObjectDrawableAssist.vertical) ? center.dx : position.dx,
      assists.contains(ObjectDrawableAssist.horizontal)
          ? center.dy
          : position.dy,
    );
    final assistedRotation = assists.contains(ObjectDrawableAssist.rotation) &&
            closestAssistAngle != null
        ? closestAssistAngle.remainder(pi * 2)
        : rotation;

    final newDrawable = drawable.copyWith(
      position: assistedPosition,
      scale: scale,
      rotation: assistedRotation,
      assists: assists,
    );

    updateDrawable(drawable, newDrawable);
  }

  void calculatePositionalAssists(ObjectLayoutAssistSettings settings,
      int index, Offset position, Offset center) {
    if ((position.dy - center.dy).abs() < settings.positionalEnterDistance &&
        !(assistDrawables[ObjectDrawableAssist.horizontal]?.contains(index) ??
            false)) {
      assistDrawables[ObjectDrawableAssist.horizontal]?.add(index);
      settings.hapticFeedback.impact();
    } else if ((position.dy - center.dy).abs() >
            settings.positionalExitDistance &&
        (assistDrawables[ObjectDrawableAssist.horizontal]?.contains(index) ??
            false)) {
      assistDrawables[ObjectDrawableAssist.horizontal]?.remove(index);
    }
    if ((position.dx - center.dx).abs() < settings.positionalEnterDistance &&
        !(assistDrawables[ObjectDrawableAssist.vertical]?.contains(index) ??
            false)) {
      assistDrawables[ObjectDrawableAssist.vertical]?.add(index);
      settings.hapticFeedback.impact();
    } else if ((position.dx - center.dx).abs() >
            settings.positionalExitDistance &&
        (assistDrawables[ObjectDrawableAssist.vertical]?.contains(index) ??
            false)) {
      assistDrawables[ObjectDrawableAssist.vertical]?.remove(index);
    }
  }

  double? calculateRotationalAssist(
      ObjectLayoutAssistSettings settings, int index, double rotation) {
    final closeAngles = assistAngles
        .where(
            (angle) => (rotation - angle).abs() < settings.rotationalExitAngle)
        .toList();
    if (closeAngles.isNotEmpty) {
      if (closeAngles.any((angle) =>
              (rotation - angle).abs() < settings.rotationalEnterAngle) &&
          !(assistDrawables[ObjectDrawableAssist.rotation]?.contains(index) ??
              false)) {
        assistDrawables[ObjectDrawableAssist.rotation]?.add(index);
        settings.hapticFeedback.impact();
      }
      return closeAngles[0];
    }
    if (closeAngles.isEmpty &&
        (assistDrawables[ObjectDrawableAssist.rotation]?.contains(index) ??
            false)) {
      assistDrawables[ObjectDrawableAssist.rotation]?.remove(index);
    }

    return null;
  }

  Offset get center {
    final renderBox = PainterController.of(context)
        .painterKey
        .currentContext
        ?.findRenderObject() as RenderBox?;
    final center = renderBox == null
        ? Offset.zero
        : Offset(
            renderBox.size.width / 2,
            renderBox.size.height / 2,
          );
    return center;
  }

  void updateDrawable(ObjectDrawable oldDrawable, ObjectDrawable newDrawable,
      {bool newAction = false}) {
    setState(() {
      PainterController.of(context)
          .replaceDrawable(oldDrawable, newDrawable, newAction: newAction);
    });
  }

  void onRotationControlPanStart(int controlIndex,
      MapEntry<int, ObjectDrawable> entry, DragStartDetails details) {
    setState(() {
      controlsAreActive[controlIndex] = true;
    });
    onDrawableScaleStart(
        entry,
        ScaleStartDetails(
          pointerCount: 2,
          localFocalPoint: entry.value.position,
        ));
  }

  void onRotationControlPanUpdate(MapEntry<int, ObjectDrawable> entry,
      DragUpdateDetails details, Size size) {
    final index = entry.key;
    final initial = initialScaleDrawables[index];
    if (initial == null) return;
    final initialOffset = Offset((size.width / 2), (-size.height / 2));
    final initialAngle = atan2(initialOffset.dx, initialOffset.dy);
    final angle = atan2((details.localPosition.dx + initialOffset.dx),
        (details.localPosition.dy + initialOffset.dy));
    final rotation = initialAngle - angle;
    onDrawableScaleUpdate(
        entry,
        ScaleUpdateDetails(
          pointerCount: 2,
          rotation: rotation,
          scale: 1,
          localFocalPoint: entry.value.position,
        ));
  }

  void onRotationControlPanEnd(int controlIndex,
      MapEntry<int, ObjectDrawable> entry, DragEndDetails details) {
    setState(() {
      controlsAreActive[controlIndex] = false;
    });
    onDrawableScaleEnd(entry);
  }

  void onScaleControlPanStart(int controlIndex,
      MapEntry<int, ObjectDrawable> entry, DragStartDetails details) {
    setState(() {
      controlsAreActive[controlIndex] = true;
    });
    onDrawableScaleStart(
        entry,
        ScaleStartDetails(
          pointerCount: 1,
          localFocalPoint: entry.value.position,
        ));
  }

  void onScaleControlPanUpdate(MapEntry<int, ObjectDrawable> entry,
      DragUpdateDetails details, BoxConstraints constraints,
      [bool isReversed = true]) {
    final index = entry.key;
    final initial = initialScaleDrawables[index];
    if (initial == null) return;
    final length = details.localPosition.dx * (isReversed ? -1 : 1);
    final initialSize = initial.getSize(maxWidth: constraints.maxWidth);
    final initialLength = initialSize.width / 2;
    final double scale = initialLength == 0
        ? (length * 2)
        : ((length + initialLength) / initialLength);
    onDrawableScaleUpdate(
        entry,
        ScaleUpdateDetails(
          pointerCount: 1,
          rotation: 0,
          scale: scale.clamp(ObjectDrawable.minScale, double.infinity),
          localFocalPoint: entry.value.position,
        ));
  }

  void onScaleControlPanEnd(int controlIndex,
      MapEntry<int, ObjectDrawable> entry, DragEndDetails details) {
    setState(() {
      controlsAreActive[controlIndex] = false;
    });
    onDrawableScaleEnd(entry);
  }

  void onResizeControlPanStart(int controlIndex,
      MapEntry<int, ObjectDrawable> entry, DragStartDetails details) {
    setState(() {
      controlsAreActive[controlIndex] = true;
    });
    onDrawableScaleStart(
        entry,
        ScaleStartDetails(
          pointerCount: 1,
          localFocalPoint: entry.value.position,
        ));
  }

  void onResizeControlPanUpdate(MapEntry<int, ObjectDrawable> entry,
      DragUpdateDetails details, BoxConstraints constraints, Axis axis,
      [bool isReversed = true]) {
    final index = entry.key;

    final drawable = entry.value;

    if (drawable is! Sized2DDrawable) return;

    final initial = initialScaleDrawables[index];
    if (initial is! Sized2DDrawable?) return;

    if (initial == null) return;
    final vertical = axis == Axis.vertical;
    final length =
        ((vertical ? details.localPosition.dy : details.localPosition.dx) *
            (isReversed ? -1 : 1));
    final initialLength = vertical ? initial.size.height : initial.size.width;

    final totalLength = (length / initial.scale + initialLength)
        .clamp(0, double.infinity) as double;

    final offsetPosition = Offset(
      vertical ? 0 : (isReversed ? -1 : 1) * length / 2,
      vertical ? (isReversed ? -1 : 1) * length / 2 : 0,
    );

    final rotateOffset = Matrix4.identity()
      ..rotateZ(initial.rotationAngle)
      ..translate(offsetPosition.dx, offsetPosition.dy)
      ..rotateZ(-initial.rotationAngle);
    final position = Offset(rotateOffset[12], rotateOffset[13]);

    final newDrawable = drawable.copyWith(
      size: Size(
        vertical ? drawable.size.width : totalLength,
        vertical ? totalLength : drawable.size.height,
      ),
      position: initial.position + position,
    );

    updateDrawable(drawable, newDrawable);
  }

  void onResizeControlPanEnd(int controlIndex,
      MapEntry<int, ObjectDrawable> entry, DragEndDetails details) {
    setState(() {
      controlsAreActive[controlIndex] = false;
    });
    onDrawableScaleEnd(entry);
  }

  void onTransformUpdated() {
    setState(() {
      final _m4storage =
          PainterController.of(context).transformationController.value;
      transformationScale = math.sqrt(_m4storage[8] * _m4storage[8] +
          _m4storage[9] * _m4storage[9] +
          _m4storage[10] * _m4storage[10]);
    });
  }
}

class _ObjectControlBox extends StatelessWidget {
  final BoxShape shape;
  final bool active;
  final Color inactiveColor;
  final Color? activeColor;
  final Color shadowColor;
  final Icon? icon;
  final VoidCallback? onTap;
  final VoidCallback? onCancelTap;

  const _ObjectControlBox({
    Key? key,
    this.shape = BoxShape.circle,
    this.active = false,
    this.inactiveColor = Colors.black,
    this.activeColor,
    this.shadowColor = Colors.black,
    this.icon,
    this.onTap,
    this.onCancelTap,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    ThemeData? theme = Theme.of(context);
    if (theme == ThemeData.fallback()) theme = null;

    return GestureDetector(
      onTap: onTap,
      child: Stack(
        alignment: Alignment.center,
        children: [
          AnimatedContainer(
            duration: const Duration(milliseconds: 1000),
            decoration: BoxDecoration(
              color: active ? activeColor : inactiveColor,
              shape: shape,
            ),
          ),
          if (icon != null) ...[
            Positioned.fill(
              child: Align(
                alignment: Alignment.center,
                child: icon,
              ),
            ),
          ],
          if (icon?.icon == Icons.cancel) ...[
            Positioned(
              bottom: 1,
              right: 10,
              child: IconButton(
                icon: Icon(
                  Icons.cancel,
                ),
                onPressed: onCancelTap,
              ),
            ),
          ],
        ],
      ),
    );
  }
}
