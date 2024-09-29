import 'package:flutter/material.dart';

// ignore: camel_case_types
class buildBottomButton extends StatelessWidget {
  final IconData icon;
  final String text;
  final VoidCallback? onPressed;

  const buildBottomButton({
    super.key,
    required this.icon,
    required this.text,
    this.onPressed,
  });

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: GestureDetector(
        onTap: onPressed,
        child: Container(
          margin: const EdgeInsets.all(8),
          padding: const EdgeInsets.symmetric(vertical: 10),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(10),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.2),
                blurRadius: 4,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(icon, size: 24, color: Colors.white),
              const SizedBox(height: 4),
              Text(
                text,
                style: const TextStyle(fontSize: 16, color: Colors.white),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
