import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

class PlatformAvatar extends StatelessWidget {
  final String svgData;
  final double size;

  const PlatformAvatar({super.key, required this.svgData, required this.size});

  @override
  Widget build(BuildContext context) {
    if (!kIsWeb) {
      return SvgPicture.string(svgData, width: size, height: size);
    }

    final hash = svgData.hashCode & 0x7fffffff;
    final background = HSLColor.fromAHSL(
      1,
      (hash % 360).toDouble(),
      0.52,
      0.48,
    ).toColor();
    final accent = HSLColor.fromAHSL(
      1,
      ((hash ~/ 7) % 360).toDouble(),
      0.68,
      0.72,
    ).toColor();

    return SizedBox.square(
      dimension: size,
      child: DecoratedBox(
        decoration: BoxDecoration(color: background, shape: BoxShape.circle),
        child: Stack(
          alignment: Alignment.center,
          children: [
            Icon(Icons.person_rounded, color: Colors.white, size: size * 0.62),
            Positioned(
              right: size * 0.08,
              bottom: size * 0.08,
              child: DecoratedBox(
                decoration: BoxDecoration(
                  color: accent,
                  shape: BoxShape.circle,
                  border: Border.all(color: Colors.white, width: 1.5),
                ),
                child: SizedBox.square(dimension: size * 0.22),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
