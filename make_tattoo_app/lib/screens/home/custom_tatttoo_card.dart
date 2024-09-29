import 'package:flutter/material.dart';

class CustomTattooCard extends StatelessWidget {
  final String imagePath;
  final String title;
  final VoidCallback onTap;
  final Color textColor;
  final double borderRadius;
  final double heightRatio;

  const CustomTattooCard({
    super.key,
    required this.imagePath,
    required this.title,
    required this.onTap,
    required this.textColor,
    this.borderRadius = 16,
    this.heightRatio = 0.9,
  });

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: GestureDetector(
        onTap: onTap,
        child: LayoutBuilder(
          builder: (context, constraints) {
            return Container(
              height: constraints.maxWidth * heightRatio,
              decoration: BoxDecoration(
                color: Colors.grey,
                borderRadius: BorderRadius.circular(borderRadius),
                border: Border.all(
                  color: Colors.black87,
                  width: 1,
                ),
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(borderRadius - 1),
                child: Stack(
                  fit: StackFit.expand,
                  children: [
                    Image.asset(
                      imagePath,
                      fit: BoxFit.cover,
                    ),
                    Positioned(
                      bottom: 0,
                      left: 0,
                      right: 0,
                      child: Container(
                        decoration: BoxDecoration(
                          color: Colors.black54,
                          borderRadius: BorderRadius.vertical(
                            bottom: Radius.circular(borderRadius - 1),
                          ),
                        ),
                        padding: const EdgeInsets.all(8),
                        child: Text(
                          title,
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            color: textColor,
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                          overflow: TextOverflow.ellipsis,
                          maxLines: 1,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}
