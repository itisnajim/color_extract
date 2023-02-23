import 'package:flutter/material.dart';

/// A widget that wraps its child with a [RepaintBoundary] widget and
/// provides a [GlobalKey] to the boundary. This allows you to extract the
/// colors from the widget using [ColorAverager].
class ColorExtractor extends StatelessWidget {
  const ColorExtractor({
    Key? key,
    required this.boundaryKey,
    required this.child,
  }) : super(key: key);

  /// The child widget whose color is to be extracted.
  final Widget child;

  /// A global key that references the [RepaintBoundary] widget
  /// to be used in calculating the average color.
  final GlobalKey boundaryKey;

  @override
  Widget build(BuildContext context) {
    return RepaintBoundary(
      key: boundaryKey,
      child: child,
    );
  }
}
