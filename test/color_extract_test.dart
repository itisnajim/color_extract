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
}
