import 'package:flutter/material.dart';

/// Two overlapping chat bubbles in teal and blue.
class AppLogo extends StatelessWidget {
  const AppLogo({super.key, this.size = 96});

  final double size;

  @override
  Widget build(BuildContext context) {
    final bubble = size * 0.72;
    return SizedBox(
      width: size,
      height: size,
      child: Stack(
        children: [
          Positioned(
            left: 0,
            top: 0,
            child: Icon(Icons.chat_bubble, size: bubble, color: Colors.teal),
          ),
          Positioned(
            right: 0,
            bottom: 0,
            child: Transform.flip(
              flipX: true,
              child: Icon(
                Icons.chat_bubble,
                size: bubble,
                color: Colors.blue.withValues(alpha: 0.9),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
