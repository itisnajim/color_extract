import 'package:flutter/material.dart';

/// A widget that extracts the average color from a rectangular area defined by
/// the [boundaryKey] in its child's widget tree.
///
/// The [boundaryKey] specifies the key of widget that delimits the rectangular
/// area where the color should be extracted. This widget should be a descendant
/// of the [child] widget. If the [boundaryKey] is not found in the widget tree
/// below the [child] widget, an exception will be thrown.
///
/// The average color of the pixels inside the rectangular area is computed and
/// returned as a [Color] object.
class ColorExtractor extends StatelessWidget {
  const ColorExtractor({
    Key? key,
    required this.boundaryKey,
    required this.child,
  }) : super(key: key);

  /// The child widget that contains the rectangular area from which the color
  /// should be extracted.
  final Widget child;

  /// The key of the widget that delimits the rectangular area from which the
  /// color should be extracted.
  final GlobalKey boundaryKey;

  @override
  Widget build(BuildContext context) {
    return RepaintBoundary(
      key: boundaryKey,
      child: child,
    );
  }
}
