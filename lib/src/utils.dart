import 'dart:math';
import 'package:flutter/material.dart';

int abgrToArgb(int argbColor) {
  int r = (argbColor >> 16) & 0xFF;
  int b = argbColor & 0xFF;
  return (argbColor & 0xFF00FF00) | (b << 16) | r;
}

/// A widget that applies a grayscale filter to its child.
class GrayscaleFilter extends StatelessWidget {
  final Widget child;

  const GrayscaleFilter({
    super.key,
    required this.child,
  });

  @override
  Widget build(BuildContext context) {
    return ColorFiltered(
      colorFilter: const ColorFilter.matrix(<double>[
        0.2126,
        0.7152,
        0.0722,
        0,
        0,
        0.2126,
        0.7152,
        0.0722,
        0,
        0,
        0.2126,
        0.7152,
        0.0722,
        0,
        0,
        0,
        0,
        0,
        1,
        0,
      ]),
      child: child,
    );
  }
}

Color reverseColor(Color color) {
  return Color((0xFFFFFFFF - color.value) | 0xFF000000);
}

/// An extension on the [Color] class that provides additional functionality.
extension ColorExt on Color {
  /// Returns a new color with the same hue and saturation as this color,
  /// but with the specified [lightness] value.
  Color withLightness(double lightness) {
    final hslColor = HSLColor.fromColor(this);
    return hslColor.withLightness(lightness).toColor();
  }

  Color get reverse => reverseColor(this);
}

/// Returns a color that is more visible against the specified background color.
///
/// If the brightness difference between the foreground and background colors
/// is greater than [percent], the foreground color is returned. Otherwise,
/// a new color is returned with a brightness value that is more
/// visible against the background color.
Color moreVisibleColor(
  Color foregroundColor,
  Color backgroundColor, [
  double percent = 0.2,
]) {
  final foregroundLuminance = foregroundColor.computeLuminance();
  final backgroundLuminance = backgroundColor.computeLuminance();
  final brightnessDiff = foregroundLuminance - backgroundLuminance;

  if (brightnessDiff.abs() >= 0.4) return foregroundColor;

  const desiredBrightnessDiff = 0.4;
  final sign = brightnessDiff.isNegative ? -1 : 1;
  final newBrightness =
      min(max(0, foregroundLuminance + sign * desiredBrightnessDiff), 1);
  return foregroundColor.withLightness(newBrightness.toDouble());
}

/// Returns a color that is closer to the specified color, with a brightness
/// value that is adjusted by [percent].
Color enforceColor(Color color, [double percent = 0.2]) {
  final brightness = color.computeLuminance();
  const threshold = 0.5;

  if (brightness == threshold) return color;

  final newBrightness =
      (brightness + (brightness > threshold ? percent : -percent))
          .clamp(0.0, 1.0);
  return color.withLightness(newBrightness);
}

Color getRandomColor() {
  final random = Random();
  return Color.fromARGB(
    255,
    random.nextInt(256),
    random.nextInt(256),
    random.nextInt(256),
  );
}
