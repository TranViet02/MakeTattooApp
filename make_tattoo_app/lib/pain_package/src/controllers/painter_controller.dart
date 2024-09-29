import 'dart:async';
import 'dart:collection';
import 'dart:ui' as ui;

import 'package:collection/collection.dart';
import 'package:flutter/material.dart';
import 'events/selected_object_drawable_removed_event.dart';
import '../views/widgets/painter_controller_widget.dart';
import 'actions/actions.dart';
import 'drawables/image_drawable.dart';
import 'events/events.dart';
import 'drawables/background/background_drawable.dart';
import 'drawables/object_drawable.dart';
import 'settings/settings.dart';
import '../views/painters/painter.dart';

import 'drawables/drawable.dart';

class PainterController extends ValueNotifier<PainterControllerValue> {
  final StreamController<PainterEvent> _eventsSteamController;

  final GlobalKey painterKey;

  final TransformationController transformationController;

  PainterController({
    PainterSettings settings = const PainterSettings(),
    List<Drawable>? drawables = const [],
    BackgroundDrawable? background,
  }) : this.fromValue(PainterControllerValue(
            settings: settings,
            drawables: drawables ?? const [],
            background: background));

  /// Create a [PainterController] from a [PainterControllerValue].
  PainterController.fromValue(PainterControllerValue value)
      : _eventsSteamController = StreamController<PainterEvent>.broadcast(),
        painterKey = GlobalKey(),
        transformationController = TransformationController(),
        super(value);

  /// The stream of [PainterEvent]s dispatched from this controller.
  ///
  /// This stream is for children widgets of [FlutterPainter] to listen to external events.
  /// For example, adding a new text drawable.
  Stream<PainterEvent> get events => _eventsSteamController.stream;

  /// Setting this will notify all the listeners of this [PainterController]
  /// that they need to update (it calls [notifyListeners]). For this reason,
  /// this value should only be set between frames, e.g. in response to user
  /// actions, not during the build, layout, or paint phases.
  set background(BackgroundDrawable? background) =>
      value = value.copyWith(background: background);

  /// Queues used to track the actions performed on drawables in the controller.
  /// This is used to [undo] and [redo] actions.
  Queue<ControllerAction> performedActions = DoubleLinkedQueue(),
      unperformedActions = DoubleLinkedQueue();

  /// Uses the [PainterControllerWidget] inherited widget to fetch the [PainterController] instance in this context.
  /// This is used internally in the library to fetch the controller at different widgets.
  static PainterController of(BuildContext context) {
    return PainterControllerWidget.of(context).controller;
  }

  /// Add the [drawables] to the controller value drawables.
  ///
  /// If [newAction] is `true`, the action is added as an independent action
  /// and can be [undo]ne in the future. If it is `false`, the action is connected to the
  /// previous action and is merged with it.
  ///
  /// Calling this will notify all the listeners of this [PainterController]
  /// that they need to update (it calls [notifyListeners]). For this reason,
  /// this method should only be called between frames, e.g. in response to user
  /// actions, not during the build, layout, or paint phases.
  void addDrawables(Iterable<Drawable> drawables, {bool newAction = true}) {
    final action = AddDrawablesAction(drawables.toList());
    action.perform(this);
    _addAction(action, newAction);
  }

  /// Inserts the [drawables] to the controller value drawables at the provided [index].
  ///
  /// If [newAction] is `true`, the action is added as an independent action
  /// and can be [undo]ne in the future. If it is `false`, the action is connected to the
  /// previous action and is merged with it.
  ///
  /// Calling this will notify all the listeners of this [PainterController]
  /// that they need to update (it calls [notifyListeners]). For this reason,
  /// this method should only be called between frames, e.g. in response to user
  /// actions, not during the build, layout, or paint phases.
  void insertDrawables(int index, Iterable<Drawable> drawables,
      {bool newAction = true}) {
    final action = InsertDrawablesAction(index, drawables.toList());
    action.perform(this);
    _addAction(action, newAction);
  }

  /// Replace [oldDrawable] with [newDrawable] in the controller value.
  ///
  /// Returns `true` if [oldDrawable] was found and replaced, `false` otherwise.
  /// If the return value is `false`, the controller value is unaffected.
  ///
  /// If [newAction] is `true`, the action is added as an independent action
  /// and can be [undo]ne in the future. If it is `false`, the action is connected to the
  /// previous action and is merged with it.
  ///
  /// Calling this will notify all the listeners of this [PainterController]
  /// that they need to update (it calls [notifyListeners]). For this reason,
  /// this method should only be called between frames, e.g. in response to user
  /// actions, not during the build, layout, or paint phases.
  ///
  /// [notifyListeners] will not be called if the return value is `false`.
  bool replaceDrawable(Drawable oldDrawable, Drawable newDrawable,
      {bool newAction = true}) {
    final action = ReplaceDrawableAction(oldDrawable, newDrawable);
    final value = action.perform(this);
    if (value) _addAction(action, newAction);
    return value;
  }

  /// Removes the first occurrence of [drawable] from the controller value.
  ///
  /// Returns `true` if [drawable] was in the controller value, `false` otherwise.
  ///
  /// If [newAction] is `true`, the action is added as an independent action
  /// and can be [undo]ne in the future. If it is `false`, the action is connected to the
  /// previous action and is merged with it.
  ///
  /// Calling this will notify all the listeners of this [PainterController]
  /// that they need to update (it calls [notifyListeners]). For this reason,
  /// this method should only be called between frames, e.g. in response to user
  /// actions, not during the build, layout, or paint phases.
  ///
  /// [notifyListeners] will not be called if the return value is `false`.
  bool removeDrawable(Drawable drawable, {bool newAction = true}) {
    final action = RemoveDrawableAction(drawable);
    final value = action.perform(this);
    _addAction(action, newAction);
    return value;
  }

  /// Removes the last drawable from the controller value.
  ///
  /// If [newAction] is `true`, the action is added as an independent action
  /// and can be [undo]ne in the future. If it is `false`, the action is connected to the
  /// previous action and is merged with it.
  ///
  /// Calling this will notify all the listeners of this [PainterController]
  /// that they need to update (it calls [notifyListeners]). For this reason,
  /// this method should only be called between frames, e.g. in response to user
  /// actions, not during the build, layout, or paint phases.
  ///
  /// [notifyListeners] will not be called if there are no drawables in the controller value.
  void removeLastDrawable({bool newAction = true}) {
    removeDrawable(value.drawables.last);
  }

  void clearDrawables({bool newAction = true}) {
    final action = ClearDrawablesAction();
    action.perform(this);
    _addAction(action, newAction);
  }

  void groupDrawables({bool newAction = true}) {
    final action = MergeDrawablesAction();
    action.perform(this);
    _addAction(action, newAction);
  }

  void _addAction(ControllerAction action, bool newAction) {
    performedActions.add(action);
    if (!newAction) _mergeAction();
    unperformedActions.clear();
  }

  /// Whether an [undo] operation can be performed or not.
  bool get canUndo => performedActions.isNotEmpty;

  /// Whether a [redo] operation can be performed or not.
  bool get canRedo => unperformedActions.isNotEmpty;

  /// Undoes the last action performed on drawables. The action can later be [redo]ne.
  ///
  /// If [canUndo] is `false`, nothing happens and [notifyListeners] is not called.
  ///
  /// Calling this will notify all the listeners of this [PainterController]
  /// that they need to update (it calls [notifyListeners]). For this reason,
  /// this method should only be called between frames, e.g. in response to user
  /// actions, not during the build, layout, or paint phases.
  void undo() {
    if (!canUndo) return;
    final action = performedActions.removeLast();
    action.unperform(this);
    unperformedActions.add(action);
  }

  /// Redoes the last [undo]ne action. The redo operation can be [undo]ne.
  ///
  /// If [canRedo] is `false`, nothing happens and [notifyListeners] is not called.
  ///
  /// Calling this will notify all the listeners of this [PainterController]
  /// that they need to update (it calls [notifyListeners]). For this reason,
  /// this method should only be called between frames, e.g. in response to user
  /// actions, not during the build, layout, or paint phases.
  void redo() {
    if (!canRedo) return;
    final action = unperformedActions.removeLast();
    action.perform(this);
    performedActions.add(action);
  }

  /// Merges a newly added action with the previous action.
  void _mergeAction() {
    if (performedActions.length < 2) return;
    final second = performedActions.removeLast();
    final first = performedActions.removeLast();
    final groupedAction = second.merge(first);

    if (groupedAction != null) performedActions.add(groupedAction);
  }

  void addText() {
    _eventsSteamController.add(const AddTextPainterEvent());
  }

  void addImage(ui.Image image, [Size? size, double opacity = 1]) {
    final renderBox =
        painterKey.currentContext?.findRenderObject() as RenderBox?;
    final center = renderBox == null
        ? Offset.zero
        : Offset(
            renderBox.size.width / 2,
            renderBox.size.height / 2,
          );

    final ImageDrawable drawable;

    if (size == null) {
      drawable = ImageDrawable(
        image: image,
        position: center,
        opacity: opacity,
      );
    } else {
      drawable = ImageDrawable.fittedToSize(
        image: image,
        position: center,
        size: size,
        opacity: opacity,
      );
    }

    addDrawables([drawable]);
  }

  Future<ui.Image> renderImage(Size size) async {
    final recorder = ui.PictureRecorder();
    final canvas = Canvas(recorder);
    final painter = Painter(
      drawables: value.drawables,
      scale: painterKey.currentContext?.size ?? size,
      background: value.background,
    );
    painter.paint(canvas, size);
    return await recorder
        .endRecording()
        .toImage(size.width.floor(), size.height.floor());
  }

  ObjectDrawable? get selectedObjectDrawable => value.selectedObjectDrawable;

  void selectObjectDrawable(ObjectDrawable? drawable) {
    if (drawable == value.selectedObjectDrawable) return;
    if (drawable != null && !value.drawables.contains(drawable)) return;
    value = value.copyWith(
      selectedObjectDrawable: drawable,
    );
  }

  void deselectObjectDrawable({bool isRemoved = false}) {
    if (selectedObjectDrawable != null && isRemoved) {
      _eventsSteamController.add(const SelectedObjectDrawableRemovedEvent());
    }
    selectObjectDrawable(null);
  }
}

@immutable
class PainterControllerValue {
  /// The current paint mode of the widget.
  final PainterSettings settings;

  /// The list of drawables currently present to be painted.
  final List<Drawable> _drawables;

  /// The current background drawable of the widget.
  final BackgroundDrawable? background;

  /// The currently selected object drawable.
  final ObjectDrawable? selectedObjectDrawable;

  /// Creates a new [PainterControllerValue] with the provided [settings] and [background].
  ///
  /// The user can pass a list of initial [drawables] which will be drawn without user interaction.
  const PainterControllerValue({
    required this.settings,
    List<Drawable> drawables = const [],
    this.background,
    this.selectedObjectDrawable,
  }) : _drawables = drawables;

  /// Getter for the current drawables.
  ///
  /// The returned list is unmodifiable.
  List<Drawable> get drawables => List.unmodifiable(_drawables);

  /// Creates a copy of this value but with the given fields replaced with the new values.
  PainterControllerValue copyWith({
    PainterSettings? settings,
    List<Drawable>? drawables,
    BackgroundDrawable? background =
        _NoBackgroundPassedBackgroundDrawable.instance,
    ObjectDrawable? selectedObjectDrawable =
        _NoObjectPassedBackgroundDrawable.instance,
  }) {
    return PainterControllerValue(
      settings: settings ?? this.settings,
      drawables: drawables ?? _drawables,
      background: background == _NoBackgroundPassedBackgroundDrawable.instance
          ? this.background
          : background,
      selectedObjectDrawable:
          selectedObjectDrawable == _NoObjectPassedBackgroundDrawable.instance
              ? this.selectedObjectDrawable
              : selectedObjectDrawable,
    );
  }

  /// Checks if two [PainterControllerValue] objects are equal or not.
  @override
  bool operator ==(Object other) {
    return other is PainterControllerValue &&
        (const ListEquality().equals(_drawables, other._drawables) &&
            background == other.background &&
            settings == other.settings &&
            selectedObjectDrawable == other.selectedObjectDrawable);
  }

  @override
  int get hashCode => hashValues(
      hashList(_drawables), background, settings, selectedObjectDrawable);
}

/// Private class that is used internally to represent no
/// [BackgroundDrawable] argument passed for [PainterControllerValue.copyWith].
class _NoBackgroundPassedBackgroundDrawable extends BackgroundDrawable {
  /// Single instance.
  static const _NoBackgroundPassedBackgroundDrawable instance =
      _NoBackgroundPassedBackgroundDrawable._();

  /// Private constructor.
  const _NoBackgroundPassedBackgroundDrawable._() : super();

  /// Unimplemented implementation of the draw method.
  @override
  void draw(ui.Canvas canvas, ui.Size size) {
    throw UnimplementedError(
        "This background drawable is only to hold the default value in the PainterControllerValue copyWith method, and must not be used otherwise.");
  }
}

/// Private class that is used internally to represent no
/// [BackgroundDrawable] argument passed for [PainterControllerValue.copyWith].
class _NoObjectPassedBackgroundDrawable extends ObjectDrawable {
  /// Single instance.
  static const _NoObjectPassedBackgroundDrawable instance =
      _NoObjectPassedBackgroundDrawable._();

  /// Private constructor.
  const _NoObjectPassedBackgroundDrawable._()
      : super(
          position: const Offset(0, 0),
        );

  @override
  ObjectDrawable copyWith(
      {bool? hidden,
      Set<ObjectDrawableAssist>? assists,
      ui.Offset? position,
      double? rotation,
      double? scale,
      bool? locked}) {
    throw UnimplementedError(
        "This object drawable is only to hold the default value in the PainterControllerValue copyWith method, and must not be used otherwise.");
  }

  @override
  void drawObject(ui.Canvas canvas, ui.Size size) {
    throw UnimplementedError(
        "This object drawable is only to hold the default value in the PainterControllerValue copyWith method, and must not be used otherwise.");
  }

  @override
  ui.Size getSize({double minWidth = 0.0, double maxWidth = double.infinity}) {
    throw UnimplementedError(
        "This object drawable is only to hold the default value in the PainterControllerValue copyWith method, and must not be used otherwise.");
  }
}
