import 'package:flutter/material.dart';
import 'package:flutter_phosphor_icons/flutter_phosphor_icons.dart';
import 'package:get/get.dart';
import 'package:make_tattoo_app/pain_package/flutter_painter.dart';
import 'package:make_tattoo_app/utils/style_config.dart';

class EraserPanel extends StatefulWidget {
  final PainterController controller;
  final Function() onEraserToggle;
  final Function() onClose;

  const EraserPanel({
    Key? key,
    required this.controller,
    required this.onEraserToggle,
    required this.onClose,
  }) : super(key: key);

  @override
  _EraserFeaturesState createState() => _EraserFeaturesState();
}

class _EraserFeaturesState extends State<EraserPanel> {
  void initState() {
    super.initState();
    if (widget.controller.freeStyleMode != FreeStyleMode.erase) {
      widget.controller.freeStyleMode = FreeStyleMode.erase;
    }
  }

  void _toggleFreeStyleErase() {
    setState(() {
      widget.controller.freeStyleMode =
          widget.controller.freeStyleMode != FreeStyleMode.erase
              ? FreeStyleMode.erase
              : FreeStyleMode.none;
    });
  }

  void _onConfirm() {
    if (widget.controller.freeStyleMode == FreeStyleMode.erase) {
      widget.controller.freeStyleMode = FreeStyleMode.none;
    }
    widget.onEraserToggle();
  }

  @override
  Widget build(BuildContext context) {
    return Positioned(
      bottom: 0,
      right: 0,
      left: 0,
      child: Container(
        height: MediaQuery.of(context).size.height * 0.16,
        color: const Color.fromARGB(255, 23, 23, 23),
        child: Transform.translate(
          offset: const Offset(0, -16),
          child: Column(
            children: [
              Container(
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    IconButton(
                      icon: const Icon(Icons.close,
                          color: Colors.white, size: 24),
                      onPressed: () {
                        if (widget.controller.freeStyleMode ==
                            FreeStyleMode.erase) {
                          widget.controller.freeStyleMode = FreeStyleMode.none;
                        }
                        widget.onClose();
                      },
                    ),
                    Expanded(
                      child: Center(
                        child: Text(
                          "Eraser".tr,
                          style: TextStyle(color: iconColor, fontSize: 18),
                        ),
                      ),
                    ),
                    IconButton(
                      icon: Icon(Icons.check, color: iconColor, size: 24),
                      onPressed: _onConfirm,
                    ),
                  ],
                ),
              ),
              const Divider(),
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16.0),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      IconButton(
                        icon: Icon(
                          PhosphorIcons.eraser,
                          color: widget.controller.freeStyleMode ==
                                  FreeStyleMode.erase
                              ? Theme.of(context).canvasColor
                              : null,
                        ),
                        onPressed: _toggleFreeStyleErase,
                      ),
                      Expanded(
                        child: Slider.adaptive(
                          min: 2,
                          max: 25,
                          value: widget.controller.freeStyleStrokeWidth,
                          onChanged: (value) {
                            setState(() {
                              widget.controller.freeStyleStrokeWidth = value;
                            });
                          },
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
