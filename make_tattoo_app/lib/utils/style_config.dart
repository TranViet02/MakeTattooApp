import 'package:flutter/material.dart';

class BackButtonWidget extends StatelessWidget {
  final VoidCallback? onPressed;

  const BackButtonWidget({Key? key, this.onPressed}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return IconButton(
      icon: const Icon(Icons.arrow_back, color: Colors.white),
      onPressed: onPressed ?? () => Navigator.of(context).pop(),
    );
  }
}

Color backgroundColor = const Color.fromARGB(255, 58, 57, 57);
Color textColor = Colors.white;
Color iconColor = const Color.fromARGB(255, 250, 134, 33);
