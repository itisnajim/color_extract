import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:color_extract/color_extract.dart';

void main() {
  testWidgets('ColorAverager should calculate the correct average color',
      (WidgetTester tester) async {
    await tester.runAsync(() async {
      // Create a container with a RepaintBoundary widget
      //that has a red background color.
      final colorToTest = getRandomColor();
      final boundaryKey = GlobalKey();
      final controller = ColorAveragerController();
      final content = Stack(
        children: [
          ColorExtractor(
            boundaryKey: boundaryKey,
            child: Container(
              width: 200,
              height: 200,
              color: colorToTest,
            ),
          ),
          ColorAverager(
            boundaryKey: boundaryKey,
            controller: controller,
            child: const SizedBox(width: 50, height: 50),
            onChanged: (_) {},
          )
        ],
      );

      // Render the container and pump the frame to ensure
      //that the RepaintBoundary is painted.
      await tester.pumpWidget(MaterialApp(home: content));
      await tester.pumpAndSettle(const Duration(seconds: 1));
      final avgColor = await controller.calculateAvgColor(false);
      await tester.pumpAndSettle();

      // Ensure that the average color is calculated correctly.
      debugPrint(colorToTest.toString());
      expect(avgColor, colorToTest);
    });
  });

  testWidgets(
      'GrayscaleFilter should convert the blue child widget '
      'to grayscale of the color 0xff848484', (WidgetTester tester) async {
    await tester.runAsync(() async {
      const colorToTest = Color(0xFF2196F3);
      final childWidget = GrayscaleFilter(
        child: Container(
          color: colorToTest,
          width: 100,
          height: 100,
        ),
      );

      final boundaryKey = GlobalKey();
      final controller = ColorAveragerController();

      final content = Stack(
        children: [
          ColorExtractor(
            boundaryKey: boundaryKey,
            child: childWidget,
          ),
          ColorAverager(
            boundaryKey: boundaryKey,
            controller: controller,
            child: const SizedBox(width: 50, height: 50),
            onChanged: (_) {},
          )
        ],
      );

      await tester.pumpWidget(MaterialApp(home: content));

      final avgColor = await controller.calculateAvgColor(false);

      expect(avgColor, const Color(0xff848484));
    });
  });

  test('reverseColor returns the expected value', () {
    const originalColor = Color(0xFF2196F3);
    final reversedColor = reverseColor(originalColor);
    expect(reversedColor, const Color(0xFFDE690C));
    expect(reversedColor, originalColor.reverse);
  });

  test('withLightness method returns correct color', () {
    const originalColor = Colors.blue;
    final newColor = originalColor.withLightness(0.5);
    final expectedColor =
        HSLColor.fromColor(originalColor).withLightness(0.5).toColor();

    expect(newColor, expectedColor);
  });

  test('moreVisibleColor returns a more visible color', () {
    final originalColor =
        const Color(0xFF2196F3).withLightness(0.8); // light gray
    const backgroundColor = Color(0xFF000000); // black
    final newColor = moreVisibleColor(originalColor, backgroundColor);
    const expectedColor = Color(0xFF9ED1FA);

    expect(newColor, isNot(const Color(0xFF2196F3)));
    expect(newColor, expectedColor);
  });

  test('enforceColor returns a color with adjusted brightness', () {
    const originalColor = Color(0xFF1A237E);
    // Because the color is darker, enforceColor will make it even more darker!
    final enforcedColor = enforceColor(originalColor, 0.2);

    expect(enforcedColor, isNot(equals(originalColor)));
    expect(enforcedColor.computeLuminance(),
        lessThan(originalColor.computeLuminance()));
  });
}
