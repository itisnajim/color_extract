# color_extract
[![pub package](https://img.shields.io/pub/v/color_extract.svg)](https://pub.dartlang.org/packages/color_extract) [![Build](https://github.com/itisnajim/color_extract/workflows/Main/badge.svg)](https://github.com/itisnajim/color_extract/actions) [![codecov](https://codecov.io/gh/itisnajim/color_extract/branch/main/graph/badge.svg?token=DQTMJA22JQ)](https://codecov.io/gh/itisnajim/color_extract) [![GitHub stars](https://img.shields.io/github/stars/itisnajim/color_extract)](https://github.com/itisnajim/color_extract/stargazers) [![GitHub license](https://img.shields.io/github/license/itisnajim/color_extract)](https://github.com/itisnajim/color_extract/blob/master/LICENSE)  [![GitHub issues](https://img.shields.io/github/issues/itisnajim/color_extract)](https://github.com/itisnajim/color_extract/issues)

Color Extract is a Flutter package that allows you to extract and calculate colors from your app's background.

Preview
------------

https://user-images.githubusercontent.com/44414626/220677525-30942250-ceb2-4e85-a8af-1cb2317e4ed5.mp4

Demo
------------
in this demo you can see how you can make your widget behave like a Chameleon 🦎

![demo](https://raw.githubusercontent.com/itisnajim/color_extract/main/readme/example-demo.gif)

Installation
------------

Add the following to your `pubspec.yaml`:


```yaml
dependencies:
  color_extract: ^1.0.0
```

Then run `flutter pub get`.

Usage
-----

### ColorExtractor

The `ColorExtractor` it's the widget we want to extract the average color from. 
It's a wrapper for RepaintBoundary so you can use `RepaintBoundary` also instead.


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

The `ColorAverager` widget calculates the average color of a part of the `ColorExtractor` or `RepaintBoundary`. It can be used to determine the overall color of a region of `ColorExtractor` or `RepaintBoundary`, such as the area behind a logo or an image.


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
