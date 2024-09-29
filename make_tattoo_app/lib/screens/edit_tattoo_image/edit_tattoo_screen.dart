// import 'dart:io';
// import 'package:flutter/material.dart';
// import 'package:flutter/rendering.dart';
// import 'package:flutter/services.dart';
// import 'package:flutter_phosphor_icons/flutter_phosphor_icons.dart';
// import 'package:get/get.dart';
// import 'package:make_tattoo_app/screens/edit_tattoo_image/add_text/fonts.dart';
// import 'package:make_tattoo_app/screens/edit_tattoo_image/button/bottom_button.dart';
// import 'package:make_tattoo_app/screens/edit_tattoo_image/edit_tattoo/blending_mode_panel.dart';
// import 'package:make_tattoo_app/screens/edit_tattoo_image/edit_tattoo/edit_tattoo_actions.dart';
// import 'package:make_tattoo_app/screens/edit_tattoo_image/edit_tattoo/eraser_panel.dart';
// import 'package:make_tattoo_app/utils/matrix_blending.dart';
// import 'package:make_tattoo_app/screens/edit_tattoo_image/edit_tattoo/opacity_panel.dart';
// import 'package:make_tattoo_app/screens/edit_tattoo_image/edit_tattoo/sticker_picker.dart';
// import 'package:make_tattoo_app/screens/edit_tattoo_image/edit_tattoo/edit_photo_options.dart';
// import 'package:make_tattoo_app/screens/edit_tattoo_image/save_image/save_image.dart';
// import 'package:make_tattoo_app/screens/home/home_screen.dart';
// import 'package:path_provider/path_provider.dart';
// import 'dart:ui' as ui;
// import 'package:provider/provider.dart';
// import 'package:make_tattoo_app/pain_package/flutter_painter.dart';
// import 'package:make_tattoo_app/providers/app_image_provider.dart';
// import 'package:make_tattoo_app/utils/style_config.dart';
// import 'package:make_tattoo_app/pain_package/src/controllers/drawables/color_filter.dart';
// import 'package:shared_preferences/shared_preferences.dart';
// import 'package:text_editor/text_editor.dart';
// import 'package:zerg_android_plugin/zerg_android_plugin.dart';
// import 'package:http/http.dart' as http;

// class EditTattooScreen extends StatefulWidget {
//   const EditTattooScreen({super.key, this.imagePath, this.stickerPath});
//   final String? imagePath;
//   final String? stickerPath;

//   @override
//   State<EditTattooScreen> createState() => _EditTattooScreenState();
// }

// class _EditTattooScreenState extends State<EditTattooScreen> {
//   static const Color red = Color.fromARGB(255, 231, 224, 224);
//   FocusNode textFocusNode = FocusNode();
//   late PainterController controller;
//   bool _showStickerPicker = false;
//   bool _showEditOptions = false;
//   bool _isEditing = false;
//   bool _isEraser = false;
//   bool _isBlendingMode = false;
//   bool _isOpacity = false;
//   double _opacity = 1.0;
//   String? _selectedTattooPath;
//   String _selectedCategory = 'trending'.tr;
//   bool _showEditPhotoOptions = false;
//   bool _isGridView = false;
//   String _selectedBlendingMode = 'None'.tr;
//   bool isSelect = false;
//   GlobalKey _repaintKey = GlobalKey();
//   Offset _textPosition = Offset(180, 230);
//   @override
//   void initState() {
//     super.initState();
//     controller = PainterController(
//       settings: PainterSettings(
//         text: TextSettings(
//           focusNode: textFocusNode,
//           textStyle: const TextStyle(
//             fontWeight: FontWeight.bold,
//             color: red,
//             fontSize: 18,
//           ),
//         ),
//         freeStyle: const FreeStyleSettings(
//           color: red,
//           strokeWidth: 5,
//         ),
//         scale: const ScaleSettings(
//           enabled: true,
//           minScale: 1,
//           maxScale: 5,
//         ),
//       ),
//     );
//     textFocusNode.addListener(onFocus);
//     if (widget.stickerPath != null && widget.stickerPath!.isNotEmpty) {
//       addTattoo(widget.stickerPath!);
//     }
//   }

//   void _showLoadingDialog(BuildContext context) {
//     WidgetsBinding.instance.addPostFrameCallback((_) {
//       showDialog(
//         context: context,
//         barrierDismissible: false,
//         builder: (BuildContext context) {
//           return AlertDialog(
//             content: Row(
//               mainAxisSize: MainAxisSize.min,
//               children: [
//                 const CircularProgressIndicator(),
//                 const SizedBox(width: 20),
//                 Text('Adding Tattoo...'.tr),
//               ],
//             ),
//           );
//         },
//       );
//     });
//   }

//   void _hideLoadingDialog(BuildContext context) {
//     Navigator.of(context).pop();
//   }

//   void onFocus() {
//     setState(() {});
//   }

//   void undo() {
//     controller.undo();
//   }

//   void redo() {
//     controller.redo();
//   }

//   void toggleFreeStyleErase() {
//     setState(() {
//       _isEraser = !_isEraser;
//       if (_isEraser) {
//         _isEditing = false;
//       }
//     });
//   }

//   void clearAllTattoo() {
//     controller.clearDrawables();
//     setState(() {
//       _selectedTattooPath = null;
//     });
//   }

//   void toggleEditPhotoOptions() {
//     setState(() {
//       clearAllTattoo();
//       _showEditPhotoOptions = !_showEditPhotoOptions;
//     });
//   }

//   void addTattoo(String? imagePath, [double opacity = 1.0]) async {
//     controller.clearDrawables();
//     if (imagePath == null || imagePath.isEmpty) {
//       return;
//     }
//     _showLoadingDialog(context);
//     final image = await _loadImageFromAssets(imagePath);
//     const size = Size(190, 190);
//     controller.addImage(image, size, opacity);

//     setState(() {
//       _selectedTattooPath = imagePath;
//       _opacity = opacity;
//       _isGridView = false;
//     });
//     _hideLoadingDialog(context);
//   }

//   void setTattooFilter(List<double> matrix) {
//     final colorFilter = createColorFilterFromMatrix(matrix);
//     final selectedDrawable = controller.selectedObjectDrawable;
//     if (selectedDrawable is ImageDrawable) {
//       controller.replaceDrawable(
//         selectedDrawable,
//         selectedDrawable.copyWith(colorFilter: colorFilter),
//       );
//     }
//   }

//   Future<ui.Image> _loadImageFromAssets(String url) async {
//     if (url.isEmpty) {
//       throw ArgumentError('The URL cannot be empty');
//     }
//     final response = await http.get(Uri.parse(url));
//     if (response.statusCode == 200) {
//       final bytes = response.bodyBytes;
//       return decodeImageFromList(bytes);
//     } else {
//       throw Exception('Failed to load image from URL');
//     }
//   }

//   void removeSelectedDrawable() {
//     final selectedDrawable = controller.selectedObjectDrawable;
//     if (selectedDrawable != null) {
//       controller.removeDrawable(selectedDrawable);
//       setState(() {
//         _selectedTattooPath = null;
//       });
//     }
//   }

//   void cancelTattooSelection() {
//     setState(() {
//       _showStickerPicker = false;
//       _showEditOptions = false;
//       _isEditing = false;
//       _showEditPhotoOptions = false;
//     });
//   }

//   void _saveImage() async {
//     RenderRepaintBoundary boundary =
//         _repaintKey.currentContext!.findRenderObject() as RenderRepaintBoundary;
//     ui.Image image = await boundary.toImage(pixelRatio: 3.0);
//     ByteData? byteData = await image.toByteData(format: ui.ImageByteFormat.png);
//     Uint8List uint8List = byteData!.buffer.asUint8List();

//     final directory = await getApplicationDocumentsDirectory();
//     final imagePath =
//         '${directory.path}/image_${DateTime.now().millisecondsSinceEpoch}.png';
//     File imageFile = File(imagePath);
//     await imageFile.writeAsBytes(uint8List);
//     final prefs = await SharedPreferences.getInstance();
//     List<String>? imagePaths = prefs.getStringList('saved_image_paths');
//     if (imagePaths == null) {
//       imagePaths = [];
//     }
//     imagePaths.add(imagePath);
//     await prefs.setStringList('saved_image_paths', imagePaths);
//     Navigator.push(
//       context,
//       MaterialPageRoute(
//         builder: (context) => const ImageSaveScreen(),
//       ),
//     );
//   }

//   void isTogleEdit() {
//     setState(() {
//       _isEditing = !_isEditing;
//       if (_isEditing) {
//         _showStickerPicker = false;
//       }
//     });
//   }

//   void _addCustomText() {
//     _handleTextEditing(
//       _text,
//       _textStyle,
//       _textAlign,
//     );
//   }

//   void _handleTextEditing(
//       String text, TextStyle textStyle, TextAlign textAlign) {
//     showGeneralDialog(
//       context: context,
//       barrierDismissible: false,
//       transitionDuration: const Duration(
//         milliseconds: 400,
//       ),
//       pageBuilder: (_, __, ___) {
//         return Container(
//           color: Colors.black.withOpacity(0.3),
//           child: Scaffold(
//             backgroundColor: Colors.transparent,
//             body: SafeArea(
//               child: Container(
//                 child: TextEditor(
//                   fonts: fonts,
//                   text: text,
//                   textStyle: textStyle,
//                   textAlingment: textAlign,
//                   minFontSize: 10,
//                   onEditCompleted: (style, align, text) {
//                     setState(() {
//                       _text = text;
//                       _textStyle = style;
//                       _textAlign = align;
//                     });
//                     Navigator.of(context).pop();
//                   },
//                 ),
//               ),
//             ),
//           ),
//         );
//       },
//     );
//   }

//   TextAlign _textAlign = TextAlign.center;
//   String _text = '';
//   TextStyle _textStyle = const TextStyle(
//     fontSize: 30,
//     color: Colors.white,
//     fontFamily: 'Billabong',
//   );

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(
//         backgroundColor: Colors.black,
//         automaticallyImplyLeading: false,
//         leading: _isEraser
//             ? null
//             : IconButton(
//                 icon:
//                     Icon(PhosphorIcons.arrow_left, color: textColor, size: 20),
//                 onPressed: () {
//                   Navigator.push(
//                     context,
//                     MaterialPageRoute(
//                       builder: (context) => const HomeScreen(),
//                     ),
//                   );
//                 },
//               ),
//         actions: _isEraser
//             ? null
//             : [
//                 TextButton(
//                   onPressed: () async {
//                     controller.deselectObjectDrawable();
//                     await Future.delayed(const Duration(milliseconds: 300));
//                     _saveImage();
//                   },
//                   child: Text(
//                     "Save".tr,
//                     style: TextStyle(color: iconColor, fontSize: 19),
//                   ),
//                 ),
//               ],
//         flexibleSpace: _isEraser && _isEraser
//             ? Stack(
//                 children: [
//                   Align(
//                     alignment: Alignment.center,
//                     child: Row(
//                       mainAxisSize: MainAxisSize.min,
//                       children: [
//                         IconButton(
//                           icon: const Icon(
//                             Icons.redo,
//                             color: Colors.white,
//                             size: 28,
//                           ),
//                           onPressed: controller.canRedo ? redo : null,
//                         ),
//                         IconButton(
//                           icon: const Icon(
//                             Icons.undo,
//                             color: Colors.white,
//                             size: 28,
//                           ),
//                           onPressed: controller.canUndo ? undo : null,
//                         ),
//                       ],
//                     ),
//                   ),
//                 ],
//               )
//             : null,
//       ),
//       backgroundColor: backgroundColor,
//       resizeToAvoidBottomInset: false,
//       body: Column(
//         children: [
//           Expanded(
//             child: Stack(
//               children: [
//                 RepaintBoundary(
//                   key: _repaintKey,
//                   child: Consumer<AppImageProvider>(
//                     builder: (BuildContext context, value, Widget? child) {
//                       if (value.currentImage != null) {
//                         return Stack(
//                           children: [
//                             Padding(
//                               padding: const EdgeInsets.only(bottom: 80),
//                               child: Center(
//                                 child: Transform(
//                                   alignment: Alignment.center,
//                                   transform: Matrix4.identity()
//                                     ..rotateZ(value.rotationAngle)
//                                     ..scale(
//                                         value.flipVertical ? -1.0 : 1.0, 1.0),
//                                   child: Image.memory(
//                                     value.currentImage!,
//                                     width: MediaQuery.of(context).size.width,
//                                     fit: BoxFit.cover,
//                                   ),
//                                 ),
//                               ),
//                             ),
//                             Positioned(
//                               child: FlutterPainter(
//                                   controller: controller,
//                                   handleOpenEdit: () {
//                                     this.isTogleEdit();
//                                   }),
//                             ),
//                             Positioned(
//                               left: _textPosition.dx,
//                               top: _textPosition.dy,
//                               child: GestureDetector(
//                                 onPanUpdate: (details) {
//                                   setState(() {
//                                     _textPosition = Offset(
//                                       _textPosition.dx + details.delta.dx,
//                                       _textPosition.dy + details.delta.dy,
//                                     );
//                                   });
//                                 },
//                                 onTap: () {
//                                   controller.deselectObjectDrawable();
//                                   _handleTextEditing(
//                                       _text, _textStyle, _textAlign);
//                                 },
//                                 child: Text(
//                                   _text,
//                                   style: _textStyle,
//                                   textAlign: _textAlign,
//                                 ),
//                               ),
//                             ),
//                           ],
//                         );
//                       }
//                       return const SizedBox.shrink();
//                     },
//                   ),
//                 ),
//                 if (!_showStickerPicker &&
//                     !_isEditing &&
//                     !_showEditPhotoOptions)
//                   Positioned(
//                     bottom: 0,
//                     right: 0,
//                     left: 0,
//                     child: Container(
//                       height: MediaQuery.of(context).size.height * 0.12,
//                       color: const Color.fromARGB(255, 23, 23, 23),
//                       child: Row(
//                         mainAxisAlignment: MainAxisAlignment.spaceAround,
//                         children: [
//                           buildBottomButton(
//                             icon: Icons.add_photo_alternate_outlined,
//                             text: 'Add Tattoo',
//                             onPressed: () {
//                               setState(() {
//                                 _showStickerPicker = !_showStickerPicker;
//                                 if (_showStickerPicker) {
//                                   _selectedCategory = 'trending'.tr;
//                                 }
//                               });
//                             },
//                           ),
//                           buildBottomButton(
//                             icon: PhosphorIcons.image,
//                             text: 'Edit Photo',
//                             onPressed: toggleEditPhotoOptions,
//                           ),
//                           buildBottomButton(
//                             icon: PhosphorIcons.text_aa_bold,
//                             text: 'Custom Text',
//                             onPressed: _addCustomText,
//                           ),
//                         ],
//                       ),
//                     ),
//                   ),
//                 if (_showStickerPicker)
//                   StickerPicker(
//                     isGridView: _isGridView,
//                     selectedCategory: _selectedCategory,
//                     selectedTattooPath: _selectedTattooPath,
//                     onCategorySelected: (category) {
//                       setState(() {
//                         _selectedCategory = category;
//                       });
//                     },
//                     onTattooSelected: (imagePath) {
//                       addTattoo(imagePath);
//                       setState(() {
//                         _showStickerPicker = true;
//                       });
//                     },
//                     onEditingToggle: () {
//                       isTogleEdit();
//                     },
//                     onCancel: cancelTattooSelection,
//                     onGridViewToggle: () {
//                       setState(() {
//                         _isGridView = !_isGridView;
//                       });
//                     },
//                   ),
//                 if (_showEditPhotoOptions)
//                   EditPhotoOptions(
//                     showEditPhotoOptions: _showEditPhotoOptions,
//                     onCancel: () {
//                       setState(() {
//                         _showEditPhotoOptions = false;
//                       });
//                     },
//                   ),
//                 if (_isEditing)
//                   EditTattooActions(
//                     isEditing: _isEditing,
//                     onReplaceTattoo: () {
//                       setState(() {
//                         _showStickerPicker = true;
//                         _isEditing = false;
//                       });
//                     },
//                     onToggleBlendingMode: () {
//                       setState(() {
//                         _isBlendingMode = !_isBlendingMode;
//                         _isEditing = false;
//                       });
//                     },
//                     onToggleOpacity: () {
//                       setState(() {
//                         _isOpacity = !_isOpacity;
//                         if (_isEditing) {
//                           _showStickerPicker = false;
//                         }
//                       });
//                     },
//                     onToggleEraser: () {
//                       setState(() {
//                         _isEraser = !_isEraser;
//                         if (_isEditing) {
//                           _showStickerPicker = false;
//                         }
//                       });
//                     },
//                     onCancel: () {
//                       setState(() {
//                         _isEditing = false;
//                       });
//                     },
//                   ),
//                 if (_isOpacity)
//                   OpacityPanel(
//                     opacity: _opacity,
//                     onOpacityChanged: (value) {
//                       setState(() {
//                         _opacity = value;
//                         final selectedDrawable =
//                             controller.selectedObjectDrawable;
//                         if (selectedDrawable is ImageDrawable) {
//                           controller.replaceDrawable(
//                             selectedDrawable,
//                             selectedDrawable.copyWith(opacity: _opacity),
//                           );
//                         }
//                       });
//                     },
//                     onClose: () {
//                       setState(() {
//                         _isEditing = true;
//                         _isOpacity = false;
//                       });
//                     },
//                     onSave: () {
//                       setState(() {
//                         _isEditing = false;
//                         _isOpacity = false;
//                       });
//                     },
//                   ),
//                 if (_isEraser)
//                   EraserPanel(
//                     controller: controller,
//                     onEraserToggle: toggleFreeStyleErase,
//                     onClose: () {
//                       setState(() {
//                         _isEditing = true;
//                         _isEraser = false;
//                       });
//                     },
//                   ),
//                 if (_isBlendingMode)
//                   BlendingModePanel(
//                     onClose: () {
//                       setState(() {
//                         _isEditing = true;
//                         _isBlendingMode = false;
//                       });
//                     },
//                     onSave: () {
//                       setState(() {
//                         _isEditing = false;
//                         _isBlendingMode = false;
//                       });
//                     },
//                     blendingModes: [
//                       BlendingModeButton(
//                         icon: Icons.no_encryption_rounded,
//                         label: "None".tr,
//                         isSelected: _selectedBlendingMode == 'None',
//                         onPressed: () {
//                           setTattooFilter(blendingModeNone);
//                           setState(() {
//                             _selectedBlendingMode = 'None';
//                           });
//                         },
//                       ),
//                       BlendingModeButton(
//                         icon: Icons.filter_1,
//                         label: "Add".tr,
//                         isSelected: _selectedBlendingMode == 'Mode 1',
//                         onPressed: () {
//                           setTattooFilter(blendingMode1);
//                           setState(() {
//                             _selectedBlendingMode = 'Mode 1';
//                           });
//                         },
//                       ),
//                       BlendingModeButton(
//                         icon: Icons.filter_2,
//                         label: "Darken".tr,
//                         isSelected: _selectedBlendingMode == 'Mode 2',
//                         onPressed: () {
//                           setTattooFilter(blendingMode2);
//                           setState(() {
//                             _selectedBlendingMode = 'Mode 2';
//                           });
//                         },
//                       ),
//                       BlendingModeButton(
//                         icon: Icons.filter_5,
//                         label: "Overlay".tr,
//                         isSelected: _selectedBlendingMode == 'Mode 5',
//                         onPressed: () {
//                           setTattooFilter(blendingMode5);
//                           setState(() {
//                             _selectedBlendingMode = 'Mode 5';
//                           });
//                         },
//                       ),
//                     ],
//                   ),
//               ],
//             ),
//           ),
//           ZergAndroidPlugin.getSmallBannerView(
//             alignment: Alignment.bottomCenter,
//           ),
//         ],
//       ),
//     );
//   }
// }

import 'package:flutter/material.dart';
import 'package:flutter_phosphor_icons/flutter_phosphor_icons.dart';
import 'package:get/get.dart';
import 'package:lindi_sticker_widget/lindi_controller.dart';
import 'package:make_tattoo_app/screens/edit_tattoo_image/add_text/fonts.dart';
import 'package:make_tattoo_app/screens/edit_tattoo_image/button/bottom_button.dart';
import 'package:make_tattoo_app/screens/edit_tattoo_image/edit_tattoo/sticker_picker.dart';
import 'package:make_tattoo_app/screens/edit_tattoo_image/edit_tattoo/edit_photo_options.dart';
import 'package:make_tattoo_app/screens/home/home_screen.dart';
import 'dart:ui' as ui;
import 'package:provider/provider.dart';
import 'package:make_tattoo_app/pain_package/flutter_painter.dart';
import 'package:make_tattoo_app/providers/app_image_provider.dart';
import 'package:make_tattoo_app/utils/style_config.dart';
import 'package:make_tattoo_app/pain_package/src/controllers/drawables/color_filter.dart';
import 'package:text_editor/text_editor.dart';
import 'package:zerg_android_plugin/zerg_android_plugin.dart';
import 'package:http/http.dart' as http;

class EditTattooScreen extends StatefulWidget {
  const EditTattooScreen({super.key, this.imagePath, this.stickerPath});
  final String? imagePath;
  final String? stickerPath;

  @override
  State<EditTattooScreen> createState() => _EditTattooScreenState();
}

class _EditTattooScreenState extends State<EditTattooScreen> {
  static const Color red = Color.fromARGB(255, 231, 224, 224);
  FocusNode textFocusNode = FocusNode();
  late PainterController controller;
  bool _showStickerPicker = false;
  bool _isEditing = false;
  bool _isEraser = false;
  String? _selectedTattooPath;
  String _selectedCategory = 'trending'.tr;
  bool _showEditPhotoOptions = false;
  bool _isGridView = false;
  bool isSelect = false;
  GlobalKey _repaintKey = GlobalKey();
  Offset _textPosition = Offset(180, 230);
  @override
  void initState() {
    super.initState();
    controller = PainterController(
      settings: PainterSettings(
        text: TextSettings(
          focusNode: textFocusNode,
          textStyle: const TextStyle(
            fontWeight: FontWeight.bold,
            color: red,
            fontSize: 18,
          ),
        ),
        freeStyle: const FreeStyleSettings(
          color: red,
          strokeWidth: 5,
        ),
        scale: const ScaleSettings(
          enabled: true,
          minScale: 1,
          maxScale: 5,
        ),
      ),
    );
    textFocusNode.addListener(onFocus);
    if (widget.stickerPath != null && widget.stickerPath!.isNotEmpty) {
      addTattoo(widget.stickerPath!);
    }
  }

  void _hideLoadingDialog(BuildContext context) {
    Navigator.of(context).pop();
  }

  void onFocus() {
    setState(() {});
  }

  void undo() {
    controller.undo();
  }

  void redo() {
    controller.redo();
  }

  void toggleFreeStyleErase() {
    setState(() {
      _isEraser = !_isEraser;
      if (_isEraser) {
        _isEditing = false;
      }
    });
  }

  void clearAllTattoo() {
    controller.clearDrawables();
    setState(() {
      _selectedTattooPath = null;
    });
  }

  void toggleEditPhotoOptions() {
    setState(() {
      clearAllTattoo();
      _showEditPhotoOptions = !_showEditPhotoOptions;
    });
  }

  void addTattoo(String? imagePath, [double opacity = 1.0]) async {
    controller.clearDrawables();
    if (imagePath == null || imagePath.isEmpty) {
      return;
    }

    final image = await _loadImageFromAssets(imagePath);
    const size = Size(190, 190);
    controller.addImage(image, size, opacity);

    setState(() {
      _selectedTattooPath = imagePath;

      _isGridView = false;
    });
    _hideLoadingDialog(context);
  }

  void setTattooFilter(List<double> matrix) {
    final colorFilter = createColorFilterFromMatrix(matrix);
    final selectedDrawable = controller.selectedObjectDrawable;
    if (selectedDrawable is ImageDrawable) {
      controller.replaceDrawable(
        selectedDrawable,
        selectedDrawable.copyWith(colorFilter: colorFilter),
      );
    }
  }

  Future<ui.Image> _loadImageFromAssets(String url) async {
    if (url.isEmpty) {
      throw ArgumentError('The URL cannot be empty');
    }
    final response = await http.get(Uri.parse(url));
    if (response.statusCode == 200) {
      final bytes = response.bodyBytes;
      return decodeImageFromList(bytes);
    } else {
      throw Exception('Failed to load image from URL');
    }
  }

  void removeSelectedDrawable() {
    final selectedDrawable = controller.selectedObjectDrawable;
    if (selectedDrawable != null) {
      controller.removeDrawable(selectedDrawable);
      setState(() {
        _selectedTattooPath = null;
      });
    }
  }

  void cancelTattooSelection() {
    setState(() {
      _showStickerPicker = false;

      _isEditing = false;
      _showEditPhotoOptions = false;
    });
  }

  void isTogleEdit() {
    setState(() {
      _isEditing = !_isEditing;
      if (_isEditing) {
        _showStickerPicker = false;
      }
    });
  }

  void _addCustomText() {
    _handleTextEditing(
      _text,
      _textStyle,
      _textAlign,
    );
  }

  LindiController lController = LindiController();
  void _handleTextEditing(
      String text, TextStyle textStyle, TextAlign textAlign) {
    showGeneralDialog(
      context: context,
      barrierDismissible: false,
      transitionDuration: const Duration(
        milliseconds: 400,
      ),
      pageBuilder: (_, __, ___) {
        return Container(
          color: Colors.black.withOpacity(0.3),
          child: Scaffold(
            backgroundColor: Colors.transparent,
            body: SafeArea(
              child: Container(
                child: TextEditor(
                  fonts: fonts,
                  text: text,
                  textStyle: textStyle,
                  textAlingment: textAlign,
                  minFontSize: 10,
                  onEditCompleted: (style, align, text) {
                    lController.addWidget(Text("àdasdfasdfasdf"));
                  },
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  TextAlign _textAlign = TextAlign.center;
  String _text = '';
  TextStyle _textStyle = const TextStyle(
    fontSize: 30,
    color: Colors.white,
    fontFamily: 'Billabong',
  );

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.black,
        automaticallyImplyLeading: false,
        leading: _isEraser
            ? null
            : IconButton(
                icon:
                    Icon(PhosphorIcons.arrow_left, color: textColor, size: 20),
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const HomeScreen(),
                    ),
                  );
                },
              ),
        actions: _isEraser
            ? null
            : [
                TextButton(
                  onPressed: () async {},
                  child: Text(
                    "Save".tr,
                    style: TextStyle(color: iconColor, fontSize: 19),
                  ),
                ),
              ],
        flexibleSpace: _isEraser && _isEraser
            ? const Stack(
                children: [
                  Align(),
                ],
              )
            : null,
      ),
      backgroundColor: backgroundColor,
      resizeToAvoidBottomInset: false,
      body: Column(
        children: [
          Expanded(
            child: Stack(
              children: [
                RepaintBoundary(
                  key: _repaintKey,
                  child: Consumer<AppImageProvider>(
                    builder: (BuildContext context, value, Widget? child) {
                      if (value.currentImage != null) {
                        return Stack(
                          children: [
                            Padding(
                              padding: const EdgeInsets.only(bottom: 80),
                              child: Center(
                                child: Transform(
                                  alignment: Alignment.center,
                                  transform: Matrix4.identity()
                                    ..rotateZ(value.rotationAngle)
                                    ..scale(
                                        value.flipVertical ? -1.0 : 1.0, 1.0),
                                  child: Image.memory(
                                    value.currentImage!,
                                    width: MediaQuery.of(context).size.width,
                                    fit: BoxFit.cover,
                                  ),
                                ),
                              ),
                            ),
                            Positioned(
                              child: FlutterPainter(
                                  controller: controller,
                                  handleOpenEdit: () {
                                    this.isTogleEdit();
                                  }),
                            ),
                            Positioned(
                              left: _textPosition.dx,
                              top: _textPosition.dy,
                              child: GestureDetector(
                                onPanUpdate: (details) {
                                  setState(() {
                                    _textPosition = Offset(
                                      _textPosition.dx + details.delta.dx,
                                      _textPosition.dy + details.delta.dy,
                                    );
                                  });
                                },
                                onTap: () {
                                  controller.deselectObjectDrawable();
                                  _handleTextEditing(
                                      _text, _textStyle, _textAlign);
                                },
                                child: Text(
                                  _text,
                                  style: _textStyle,
                                  textAlign: _textAlign,
                                ),
                              ),
                            ),
                          ],
                        );
                      }
                      return const SizedBox.shrink();
                    },
                  ),
                ),
                if (!_showStickerPicker &&
                    !_isEditing &&
                    !_showEditPhotoOptions)
                  Positioned(
                    bottom: 0,
                    right: 0,
                    left: 0,
                    child: Container(
                      height: MediaQuery.of(context).size.height * 0.12,
                      color: const Color.fromARGB(255, 23, 23, 23),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceAround,
                        children: [
                          buildBottomButton(
                            icon: Icons.add_photo_alternate_outlined,
                            text: 'Add Tattoo',
                            onPressed: () {
                              setState(() {
                                _showStickerPicker = !_showStickerPicker;
                                if (_showStickerPicker) {
                                  _selectedCategory = 'trending'.tr;
                                }
                              });
                            },
                          ),
                          buildBottomButton(
                            icon: PhosphorIcons.image,
                            text: 'Edit Photo',
                            onPressed: toggleEditPhotoOptions,
                          ),
                          buildBottomButton(
                            icon: PhosphorIcons.text_aa_bold,
                            text: 'Custom Text',
                            onPressed: _addCustomText,
                          ),
                        ],
                      ),
                    ),
                  ),
                if (_showStickerPicker)
                  StickerPicker(
                    isGridView: _isGridView,
                    selectedCategory: _selectedCategory,
                    selectedTattooPath: _selectedTattooPath,
                    onCategorySelected: (category) {
                      setState(() {
                        _selectedCategory = category;
                      });
                    },
                    onTattooSelected: (imagePath) {
                      addTattoo(imagePath);
                      setState(() {
                        _showStickerPicker = true;
                      });
                    },
                    onEditingToggle: () {
                      isTogleEdit();
                    },
                    onCancel: cancelTattooSelection,
                    onGridViewToggle: () {
                      setState(() {
                        _isGridView = !_isGridView;
                      });
                    },
                  ),
                if (_showEditPhotoOptions)
                  EditPhotoOptions(
                    showEditPhotoOptions: _showEditPhotoOptions,
                    onCancel: () {
                      setState(() {
                        _showEditPhotoOptions = false;
                      });
                    },
                  ),
              ],
            ),
          ),
          ZergAndroidPlugin.getSmallBannerView(
            alignment: Alignment.bottomCenter,
          ),
        ],
      ),
    );
  }
}
