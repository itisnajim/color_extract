# color_extract
[![pub package](https://img.shields.io/pub/v/color_extract.svg)](https://pub.dartlang.org/packages/color_extract) [![Build](https://github.com/itisnajim/color_extract/workflows/Main/badge.svg)](https://github.com/itisnajim/color_extract/actions) [![codecov](https://codecov.io/gh/itisnajim/color_extract/branch/main/graph/badge.svg?token=DQTMJA22JQ)](https://codecov.io/gh/itisnajim/color_extract) [![GitHub license](https://img.shields.io/github/license/itisnajim/color_extract)](https://github.com/itisnajim/color_extract/blob/master/LICENSE)  [![GitHub issues](https://img.shields.io/github/issues/itisnajim/color_extract)](https://github.com/itisnajim/color_extract/issues)

Color Extract is a Flutter package that allows you to extract and calculate colors from your app's widgets.
You can use it to change the color of a widget depending/based on the color of the background (the other widget behind).


Preview
------------
(Video player may not show on pub.dev, check github.com)

https://user-images.githubusercontent.com/44414626/220677525-30942250-ceb2-4e85-a8af-1cb2317e4ed5.mp4

Demo
------------
In this demo see how you can make your widget change colors like a chameleon 🦎.

![demo](https://raw.githubusercontent.com/itisnajim/color_extract/main/readme/example-demo.gif)

Installation
------------

Add the following to your `pubspec.yaml`:


```yaml
dependencies:
  color_extract: ^1.0.1
```

Then run `flutter pub get`.

Usage
-----

### ColorExtractor

The `ColorExtractor` it's the widget we want to extract the average color from. It serves as a wrapper for RepaintBoundary, so you can utilize RepaintBoundary as an alternative.

```dart
ColorExtractor(
  boundaryKey: GlobalKey(),
  child: Container(
    width: 200,
    height: 200,
    color: Colors.red,
  ),
);
```

### ColorAverager

The `ColorAverager` widget computes the average color of a specific portion of either `ColorExtractor` or `RepaintBoundary`. Its application is useful in determining the dominant color of a certain area, such as the background behind a logo, image.

```dart
ColorAverager(
  boundaryKey: GlobalKey(),
  child: SizedBox(
    width: 50,
    height: 50,
  ),
  onChanged: (color) {
    // Handle the new average color.
  },
);
```

You can also use the `ColorAveragerController` to calculate the average color programmatically.

```dart
final controller = ColorAveragerController();

// ... render the widget ...

final avgColor = await controller.calculateAvgColor();
```

Example
-------

```dart
import 'package:flutter/material.dart';
import 'package:color_extract/color_extract.dart';

class MyHomePage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          ColorExtractor(
            boundaryKey: boundaryKey,
            child: Container(
              width: 200,
              height: 200,
              color: Colors.blue,
            ),
          ),
          ColorAverager(
            // boundaryKey should be the same one in the above ColorExtractor boundaryKey
            boundaryKey: boundaryKey,
            // You can use the controller (ColorAveragerController) too.
            // controller: controller,
            child: const SizedBox(width: 50, height: 50),
            onChanged: (color) {
                // Do something with the average color.
                // color should be = Colors.blue
            },
          )
        ],
      )
    );
  }
}
```

## Author

itisnajim, itisnajim@gmail.com

## License

color_extract is available under the MIT license. See the LICENSE file for more info.
