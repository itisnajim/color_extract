import 'dart:math';
import 'package:flutter/material.dart';

/// Converts an ABGR color format to ARGB by swapping R and B values.
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

/// Inverts the RGB values of the input color and sets the alpha value to
/// 255 (fully opaque) to produce the resulting color.
/// The input color should have an alpha value of 255.
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

  // Returns a new color by reversing the color value
  // of the current [Color] instance.
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
  // percent is the desired brightness diff.
  double percent = 0.4,
]) {
  final foregroundLuminance = foregroundColor.computeLuminance();
  final backgroundLuminance = backgroundColor.computeLuminance();
  final brightnessDiff = foregroundLuminance - backgroundLuminance;

  if (brightnessDiff.abs() >= percent) return foregroundColor;

  final sign = brightnessDiff.isNegative ? -1 : 1;
  final newBrightness = min(max(0, foregroundLuminance + sign * percent), 1);
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

/// Returns a random color generated using the dart:math library. The color
/// has an alpha value of 255 and random red, green, and blue values.
Color getRandomColor() {
  final random = Random();
  return Color.fromARGB(
    255,
    random.nextInt(256),
    random.nextInt(256),
    random.nextInt(256),
  );
}
