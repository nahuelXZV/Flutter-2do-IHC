import 'package:avatar_glow/avatar_glow.dart';

import 'package:flutter/material.dart';

class Microphono extends StatelessWidget {
  final bool onAnimated;
  const Microphono({super.key, this.onAnimated = true});

  @override
  Widget build(BuildContext context) {
    return AvatarGlow(
      animate: onAnimated,
      glowColor: Colors.blue,
      endRadius: 75.0,
      duration: const Duration(milliseconds: 1000),
      repeatPauseDuration: const Duration(milliseconds: 100),
      repeat: true,
      child: FloatingActionButton(
        onPressed: () {},
        child: const Icon(Icons.mic),
        backgroundColor: Colors.blue,
      ),
    );
  }
}
