import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';

import 'utils.dart';

/// This widget calculates the average color of the overlapping area between
/// its child and a specified ColorExtractor or RepaintBoundary widget,
/// identified by its GlobalKey boundaryKey.
class ColorAverager extends StatefulWidget {
  /// Creates a new ColorAverager widget.
  const ColorAverager({
    Key? key,
    required this.boundaryKey,
    required this.child,
    this.onChanged,
    this.controller,
    this.fillerColor,
  })  : assert(onChanged != null || controller != null),
        super(key: key);

  /// The `GlobalKey` of the `RepaintBoundary` or `ColorExtractor` widget
  /// to calculate the average color from.
  final GlobalKey boundaryKey;

  /// The child widget whose intersection with
  /// the `RepaintBoundary` or `ColorExtractor` widget will be used
  /// to calculate the average color.
  final Widget child;

  /// The callback function that returns the calculated average color.
  final ValueChanged<Color?>? onChanged;

  /// An optional `ColorAveragerController` object that can be used
  /// to programmatically calculate the average color.
  final ColorAveragerController? controller;

  /// An optional color to use for pixels with an alpha value of 0.
  final Color? fillerColor;

  @override
  State<ColorAverager> createState() => _ColorAveragerState();
}

class _ColorAveragerState extends State<ColorAverager> {
  Color? _avgColor;
  Color? _lastAvgColor;

  @override
  void initState() {
    super.initState();
    widget.controller?._addState(this);

    // Calculate the initial average color.
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Future.delayed(const Duration(milliseconds: 500), _calculateAvgColor);
    });
  }

  @override
  void didUpdateWidget(ColorAverager oldWidget) {
    super.didUpdateWidget(oldWidget);
    // Recalculate the average color if the boundary key has changed.
    if (oldWidget.boundaryKey != widget.boundaryKey) {
      _calculateAvgColor();
    }
  }

  /// Calculates the average color from the intersection between
  /// the child widget and the `RepaintBoundary` widget.
  ///
  /// If `notify` is `true`, this function will also call the `onChanged`
  /// callback function and update the widget state.
  Future<Color?> _calculateAvgColor([bool notify = true]) async {
    final backgroundBoundary = widget.boundaryKey.currentContext
        ?.findRenderObject() as RenderRepaintBoundary?;
    if (backgroundBoundary == null) return null;

    final childBox = context.findRenderObject() as RenderBox;
    final childOffset = childBox.localToGlobal(Offset.zero);

    final childBoundary = childOffset & childBox.size;
    final backgroundBoundaryBox =
        backgroundBoundary.localToGlobal(Offset.zero) & backgroundBoundary.size;
    final intersection = childBoundary.intersect(backgroundBoundaryBox);

    // If there is no intersection between the child
    //and the background boundary, return null.
    if (intersection.width <= 0 || intersection.height <= 0) return null;

    // Get the image bytes from the background boundary.
    final image = await backgroundBoundary.toImage();
    final bytes = await image.toByteData();
    if (bytes == null) return null;

    // Get the pixel values for the intersection of the child
    //and the background boundary.
    final pixels = bytes.buffer.asUint32List();
    int red = 0, green = 0, blue = 0, alpha = 0, count = 0;
    for (var y = intersection.top.toInt();
        y < intersection.bottom.toInt();
        y++) {
      final pixelRowOffset = y * image.width;
      for (var x = intersection.left.toInt();
          x < intersection.right.toInt();
          x++) {
        final pixelOffset = pixelRowOffset + x;

        final pixel = pixels[pixelOffset];
        final argbColor = abgrToArgb(pixel);
        final pixelAlpha = pixel >> 24 & 0xFF;
        final color = pixelAlpha == 0 && widget.fillerColor != null
            ? widget.fillerColor!
            : Color(argbColor);
        red += color.red;
        green += color.green;
        blue += color.blue;
        alpha += color.alpha;
        count++;
      }
    }

    // Calculate the average color from the pixel values.
    if (count == 0) return null;

    final avgRed = red ~/ count;
    final avgGreen = green ~/ count;
    final avgBlue = blue ~/ count;
    final avgAlpha = alpha ~/ count;

    final avgColor = Color.fromRGBO(avgRed, avgGreen, avgBlue, avgAlpha / 255);
    if (_lastAvgColor == avgColor) return avgColor;

    if (notify) {
      // Update the state with the new average color and notify the callback.
      setState(() {
        _avgColor = avgColor;
        _lastAvgColor = avgColor;
        widget.onChanged?.call(_avgColor);
      });
    }

    return avgColor;
  }

  @override
  Widget build(BuildContext context) {
    return widget.child;
  }
}

/// Controller class for [ColorAverager].
class ColorAveragerController {
  _ColorAveragerState? _widgetState;
  void _addState(_ColorAveragerState widgetState) {
    _widgetState = widgetState;
  }

  /// Calculates the average color and updates the [ColorAverager] object state.
  ///
  /// If notify is true, it notifies the [onChanged] callback function
  /// with the calculated average color.
  Future<Color?> calculateAvgColor([bool notify = true]) {
    return _widgetState!._calculateAvgColor(notify);
  }
}
