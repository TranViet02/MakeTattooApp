import 'dart:async';
import 'dart:math';
import 'package:flutter/foundation.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/widgets.dart';
import 'package:make_tattoo_app/pain_package/src/controllers/drawables/image_drawable.dart';
import '../../controllers/events/selected_object_drawable_removed_event.dart';
import '../../extensions/painter_controller_helper_extension.dart';
import '../../controllers/drawables/drawable.dart';
import '../../controllers/notifications/notifications.dart';
import '../../controllers/drawables/sized2ddrawable.dart';
import '../../controllers/drawables/object_drawable.dart';
import '../../controllers/events/events.dart';
import '../../controllers/drawables/text_drawable.dart';
import '../../controllers/drawables/path/path_drawables.dart';
import '../../controllers/settings/settings.dart';
import '../painters/painter.dart';
import '../../controllers/painter_controller.dart';
import 'painter_controller_widget.dart';
import 'dart:math' as math;
part 'free_style_widget.dart';
part 'text_widget.dart';
part 'object_widget.dart';

typedef DrawableCreatedCallback = Function(Drawable drawable);
typedef DrawableDeletedCallback = Function(Drawable drawable);
typedef FlutterPainterBuilderCallback = Widget Function(
    BuildContext context, Widget painter);

class FlutterPainter extends StatelessWidget {
  final PainterController controller;
  final DrawableCreatedCallback? onDrawableCreated;
  final DrawableDeletedCallback? onDrawableDeleted;
  final ValueChanged<ObjectDrawable?>? onSelectedObjectDrawableChanged;
  final ValueChanged<PainterSettings>? onPainterSettingsChanged;
  final FlutterPainterBuilderCallback _builder;
  final VoidCallback handleOpenEdit;

  const FlutterPainter({
    Key? key,
    required this.controller,
    required this.handleOpenEdit,
    this.onDrawableCreated,
    this.onDrawableDeleted,
    this.onSelectedObjectDrawableChanged,
    this.onPainterSettingsChanged,
  })  : _builder = _defaultBuilder,
        super(key: key);

  const FlutterPainter.builder({
    Key? key,
    required this.controller,
    required this.handleOpenEdit,
    required FlutterPainterBuilderCallback builder,
    this.onDrawableCreated,
    this.onDrawableDeleted,
    this.onSelectedObjectDrawableChanged,
    this.onPainterSettingsChanged,
  })  : _builder = builder,
        super(key: key);

  @override
  Widget build(BuildContext context) {
    return PainterControllerWidget(
      controller: controller,
      child: ValueListenableBuilder<PainterControllerValue>(
        valueListenable: controller,
        builder: (context, value, child) {
          return _builder(
            context,
            _FlutterPainterWidget(
              key: controller.painterKey,
              controller: controller,
              onDrawableCreated: onDrawableCreated,
              onDrawableDeleted: onDrawableDeleted,
              onPainterSettingsChanged: onPainterSettingsChanged,
              onSelectedObjectDrawableChanged: onSelectedObjectDrawableChanged,
              handleOpenEdit: handleOpenEdit,
            ),
          );
        },
      ),
    );
  }

  static Widget _defaultBuilder(BuildContext context, Widget painter) {
    return painter;
  }
}

class _FlutterPainterWidget extends StatelessWidget {
  final PainterController controller;
  final VoidCallback handleOpenEdit;
  final DrawableCreatedCallback? onDrawableCreated;
  final DrawableDeletedCallback? onDrawableDeleted;
  final ValueChanged<ObjectDrawable?>? onSelectedObjectDrawableChanged;
  final ValueChanged<PainterSettings>? onPainterSettingsChanged;

  const _FlutterPainterWidget({
    Key? key,
    required this.controller,
    required this.handleOpenEdit,
    this.onDrawableCreated,
    this.onDrawableDeleted,
    this.onSelectedObjectDrawableChanged,
    this.onPainterSettingsChanged,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Navigator(
      onGenerateRoute: (settings) => PageRouteBuilder(
        settings: settings,
        opaque: false,
        pageBuilder: (context, animation, secondaryAnimation) {
          final controller = PainterController.of(context);
          return NotificationListener<FlutterPainterNotification>(
            onNotification: onNotification,
            child: InteractiveViewer(
              transformationController: controller.transformationController,
              minScale: controller.settings.scale.enabled
                  ? controller.settings.scale.minScale
                  : 1,
              maxScale: controller.settings.scale.enabled
                  ? controller.settings.scale.maxScale
                  : 1,
              panEnabled: controller.settings.scale.enabled &&
                  (controller.freeStyleSettings.mode == FreeStyleMode.none),
              scaleEnabled: controller.settings.scale.enabled,
              child: _FreeStyleWidget(
                child: _TextWidget(
                  child: _ObjectWidget(
                    interactionEnabled: true,
                    handleOpenEdit: handleOpenEdit,
                    child: CustomPaint(
                      painter: Painter(
                        drawables: controller.value.drawables,
                        background: controller.value.background,
                      ),
                    ),
                  ),
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  bool onNotification(FlutterPainterNotification notification) {
    if (notification is DrawableCreatedNotification) {
      onDrawableCreated?.call(notification.drawable);
    } else if (notification is DrawableDeletedNotification) {
      onDrawableDeleted?.call(notification.drawable);
    } else if (notification is SelectedObjectDrawableUpdatedNotification) {
      onSelectedObjectDrawableChanged?.call(notification.drawable);
    } else if (notification is SettingsUpdatedNotification) {
      onPainterSettingsChanged?.call(notification.settings);
    }
    return true;
  }
}
