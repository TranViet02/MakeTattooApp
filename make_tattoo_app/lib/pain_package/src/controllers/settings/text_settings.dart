import 'package:flutter/material.dart';

/// Represents settings used to create and draw text.
// @immutable
class TextSettings {
  final TextStyle textStyle;
  final FocusNode? focusNode;

  const TextSettings({
    this.textStyle = const TextStyle(
        fontSize: 14, color: Colors.black, fontFamily: 'Roboto'),
    this.focusNode,
  });
  TextSettings copyWith({TextStyle? textStyle, FocusNode? focusNode}) {
    return TextSettings(
        textStyle: textStyle ?? this.textStyle,
        focusNode: focusNode ?? this.focusNode);
  }
}
