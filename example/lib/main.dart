import 'dart:math';

import 'package:color_extract/color_extract.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/scheduler.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: const MyHomePage(),
    );
  }
}

class PosColor {
  Offset offset;
  Size size;
  Color color;

  PosColor({
    required this.offset,
    required this.size,
    required this.color,
  });
}

List<PosColor> generatePosColors() {
  List<PosColor> posColors = [];
  final random = Random();

  for (int i = 0; i < 20; i++) {
    double width = random.nextDouble() * 200 + 100;
    double height = random.nextDouble() * 200 + 100;
    double x = random.nextDouble() * 300 + 50;
    double y = random.nextDouble() * 800 + 50;

    posColors.add(
      PosColor(
        offset: Offset(x, y),
        size: Size(width, height),
        color: getRandomColor(),
      ),
    );
  }

  for (int i = 0; i < 5; i++) {
    double size = random.nextDouble() * 100 + 50;
    double x = 250 - size / 2;
    double y = 400 - size / 2;

    posColors.add(
      PosColor(
        offset: Offset(x, y),
        size: Size(size, size),
        color: Colors.white,
      ),
    );
  }

  for (int i = 0; i < 5; i++) {
    double size = random.nextDouble() * 100 + 50;
    double x = 250 - size / 2;
    double y = 550 - size / 2;

    posColors.add(
      PosColor(
        offset: Offset(x, y),
        size: Size(size, size),
        color: Colors.black,
      ),
    );
  }
  for (int i = 0; i < 20; i++) {
    double width = random.nextDouble() * 200 + 100;
    double height = random.nextDouble() * 200 + 100;
    double x = random.nextDouble() * 300 + 50;
    double y = random.nextDouble() * 800 + 600;

    posColors.add(
      PosColor(
        offset: Offset(x, y),
        size: Size(width, height),
        color: getRandomColor(),
      ),
    );
  }

  return posColors;
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key});

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  final boundaryKey = GlobalKey();
  final _scrollController = ScrollController();
  final _controller = ColorAveragerController();

  final recsInfo = ValueNotifier(generatePosColors());
  final draggableInfo = ValueNotifier(
    PosColor(
        offset: const Offset(30, 30),
        color: Colors.blue,
        size: const Size(50, 50)),
  );

  Future<Color> calcAvgColor([bool reverse = false]) async {
    var color = (await _controller.calculateAvgColor()) ?? Colors.blue;
    if (reverse) color = color.reverse;
    return color;
  }

  bool isReversedColor = false;

  @override
  void initState() {
    _scrollController.addListener(() {
      if (_scrollController.hasClients) {
        if (_scrollController.position.userScrollDirection !=
            ScrollDirection.idle) {
          SchedulerBinding.instance.addPostFrameCallback((_) {
            _controller.calculateAvgColor();
          });
        }
      }
    });

    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          ColorExtractor(
            boundaryKey: boundaryKey,
            child: SingleChildScrollView(
              controller: _scrollController,
              child: SizedBox(
                height: 2000,
                child: Stack(
                    children: recsInfo.value
                        .map((posColor) => Positioned(
                              left: posColor.offset.dx,
                              top: posColor.offset.dy,
                              child: Container(
                                width: posColor.size.width,
                                height: posColor.size.height,
                                color: posColor.color,
                              ),
                            ))
                        .toList()),
              ),
            ),
          ),
          ValueListenableBuilder(
            valueListenable: draggableInfo,
            builder: (_, __, ___) {
              return Positioned(
                left: draggableInfo.value.offset.dx,
                top: draggableInfo.value.offset.dy,
                child: Draggable(
                  feedback: Opacity(
                    opacity: 0.6,
                    child: Container(
                      width: draggableInfo.value.size.width,
                      height: draggableInfo.value.size.height,
                      decoration: BoxDecoration(
                        color: draggableInfo.value.color,
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(color: Colors.grey.withOpacity(0.4)),
                      ),
                    ),
                  ),
                  onDragEnd: (dragDetails) async {
                    draggableInfo.value = PosColor(
                      color: await calcAvgColor(isReversedColor),
                      offset: Offset(
                        dragDetails.offset.dx,
                        dragDetails.offset.dy -
                            MediaQuery.of(context).padding.top,
                      ),
                      size: draggableInfo.value.size,
                    );
                    WidgetsBinding.instance.addPostFrameCallback((_) async {
                      draggableInfo.value = PosColor(
                        color: await calcAvgColor(isReversedColor),
                        offset: Offset(
                          dragDetails.offset.dx,
                          dragDetails.offset.dy -
                              MediaQuery.of(context).padding.top,
                        ),
                        size: draggableInfo.value.size,
                      );
                    });
                  },
                  child: ColorAverager(
                    boundaryKey: boundaryKey,
                    controller: _controller,
                    fillerColor: Theme.of(context).scaffoldBackgroundColor,
                    child: AnimatedContainer(
                      duration: const Duration(milliseconds: 300),
                      width: draggableInfo.value.size.width,
                      height: draggableInfo.value.size.height,
                      decoration: BoxDecoration(
                        color: draggableInfo.value.color,
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(color: Colors.grey.withOpacity(0.4)),
                      ),
                    ),
                    onChanged: (value) {
                      //debugPrint('value $value');
                      final color = value ?? Colors.blue;
                      draggableInfo.value = PosColor(
                        color: isReversedColor ? color.reverse : color,
                        offset: draggableInfo.value.offset,
                        size: draggableInfo.value.size,
                      );
                    },
                  ),
                ),
              );
            },
          ),
          Positioned(
              bottom: 0,
              left: 0,
              right: 0,
              child: ColoredBox(
                color:
                    Theme.of(context).scaffoldBackgroundColor.withOpacity(0.8),
                child: CheckboxListTile(
                  controlAffinity: ListTileControlAffinity.trailing,
                  title: const Text('Reverse Color'),
                  value: isReversedColor,
                  onChanged: (_) {
                    setState(() {
                      isReversedColor = !isReversedColor;
                      WidgetsBinding.instance.addPostFrameCallback((_) async {
                        draggableInfo.value = PosColor(
                          color: await calcAvgColor(isReversedColor),
                          offset: draggableInfo.value.offset,
                          size: draggableInfo.value.size,
                        );
                      });
                    });
                  },
                ),
              ))
        ],
      ),
    );
  }
}
