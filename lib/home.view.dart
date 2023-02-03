import 'dart:io';

import 'package:art_book/sketch_painter.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_colorpicker/flutter_colorpicker.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:path_provider/path_provider.dart';

import 'package:permission_handler/permission_handler.dart';
import 'package:screenshot/screenshot.dart';
import 'package:share_plus/share_plus.dart';

class HomeView2 extends StatefulWidget {
  const HomeView2({Key? key}) : super(key: key);

  @override
  _HomeView2State createState() => _HomeView2State();
}

Directory findRoot(FileSystemEntity entity) {
  final Directory parent = entity.parent;
  if (parent.path == entity.path) return parent;
  return findRoot(parent);
}

class _HomeView2State extends State<HomeView2> {
  //final GlobalKey _globalKey = GlobalKey();
  bool isSliderActive = false;
  List<Offset> points = <Offset>[];
  List<List<Offset>> pointsList = [];

  //Create an instance of ScreenshotController
  ScreenshotController screenshotController = ScreenshotController();

  List<Color> colorsList = [];

  Color color = const Color.fromARGB(255, 61, 51, 255);
  Color currentColor = const Color.fromARGB(255, 61, 51, 255);

  Color tempColor = const Color.fromARGB(255, 255, 0, 0);

  double selectedSize = 2;

  List<double> sizeList = [];

  List<BoxShadow> boxS = [
    BoxShadow(
      color: const Color.fromARGB(255, 76, 69, 69).withOpacity(0.3),
      spreadRadius: 2,
      blurRadius: 3,
      offset: const Offset(0, 0), // changes position of shadow
    ),
  ];

  Future<void> save() async {
    String fileName = '${DateTime.now().microsecondsSinceEpoch}.png';

    var path = '/storage/emulated/0/Pictures/ArtBoard';

    screenshotController
        .captureAndSave(
      path,
      fileName: fileName,
    )
        .onError((error, stackTrace) {
      Fluttertoast.showToast(
        msg: error.toString(),
        toastLength: Toast.LENGTH_SHORT,
        gravity: ToastGravity.BOTTOM,
        timeInSecForIosWeb: 1,
        backgroundColor: Colors.red,
        textColor: Colors.white,
        fontSize: 16.0,
      );
      return null;
    }).then((value) {
      //print(value);
      Fluttertoast.showToast(
        msg: "Saved in the gallery",
        toastLength: Toast.LENGTH_SHORT,
        gravity: ToastGravity.BOTTOM,
        timeInSecForIosWeb: 1,
        backgroundColor: Colors.green,
        textColor: Colors.white,
        fontSize: 16.0,
      );
    });
  }

  shareImage() async {
    await screenshotController
        .capture(delay: const Duration(milliseconds: 10))
        .then((Uint8List? image) async {
      if (image != null) {
        final directory = await getApplicationDocumentsDirectory();
        final imagePath = await File('${directory.path}/image.png').create();
        await imagePath.writeAsBytes(image);

        XFile imgFile = XFile(imagePath.path);

        /// Share Plugin
        await Share.shareXFiles([imgFile]);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final Widget sketchArea = Screenshot(
      controller: screenshotController,
      child: Container(
        margin: const EdgeInsets.all(1.0),
        alignment: Alignment.topLeft,
        color: Colors.white,
        child: CustomPaint(
          painter: Sketcher(
            points,
            pointsList,
            color,
            colorsList,
            selectedSize,
            sizeList,
          ),
        ),
      ),
    );

    return Scaffold(
      appBar: AppBar(
        backgroundColor: color == Colors.white ? tempColor : color,
        title: Text(
          'Art Board +',
          style: GoogleFonts.anaheim(
            color: Colors.white,
          ),
        ),
        actions: [
          IconButton(
            onPressed: () async {
              Permission.storage.request().then((value) {
                if (value.isGranted) {
                  save();
                } else {
                  Fluttertoast.showToast(
                    msg: "Give Permission to Save",
                    toastLength: Toast.LENGTH_SHORT,
                    gravity: ToastGravity.BOTTOM,
                    timeInSecForIosWeb: 1,
                    backgroundColor: Colors.red,
                    textColor: Colors.white,
                    fontSize: 16.0,
                  );
                }
              });
            },
            icon: const Icon(
              Icons.save,
              color: Colors.white,
            ),
          ),
          IconButton(
            onPressed: () {
              shareImage();
            },
            icon: const Icon(
              Icons.share,
              color: Colors.white,
            ),
          ),
        ],
      ),
      body: Stack(
        alignment: Alignment.center,
        children: [
          GestureDetector(
            onPanUpdate: (DragUpdateDetails details) {
              setState(() {
                RenderBox box = context.findRenderObject() as RenderBox;
                Offset point = box.globalToLocal(details.globalPosition);
                point = point.translate(0.0, -(AppBar().preferredSize.height));

                points = List.from(points)
                  ..add(Offset(point.dx, point.dy - 30));
              });
            },
            onPanEnd: (DragEndDetails details) {
              points.add(Offset.zero);

              setState(() {
                pointsList.add(points);
                points = [];
                colorsList.add(color);
                sizeList.add(selectedSize);
              });
            },
            child: sketchArea,
          ),
          Positioned(
            bottom: 20,
            left: 20,
            child: FloatingActionButton(
              tooltip: 'Change Color',
              backgroundColor: color == Colors.white ? tempColor : color,
              child: const Icon(Icons.color_lens),
              onPressed: () {
                showDialog(
                  context: context,
                  builder: ((context) {
                    return AlertDialog(
                      title: const Text('Pick a color!'),
                      content: SingleChildScrollView(
                        child: MaterialPicker(
                          pickerColor: color,
                          onColorChanged: (colorX) {
                            setState(() => color = colorX);
                          },
                        ),
                      ),
                      actions: <Widget>[
                        ElevatedButton(
                          child: const Text('Got it'),
                          onPressed: () {
                            setState(() => currentColor = color);
                            Navigator.of(context).pop();
                          },
                        ),
                      ],
                    );
                  }),
                );
              },
            ),
          ),
          Positioned(
            bottom: 20,
            child: Slider(
              activeColor: color == Colors.white ? tempColor : color,
              onChangeStart: (value) {
                setState(() {
                  isSliderActive = true;
                });
              },
              onChangeEnd: ((value) {
                setState(() {
                  isSliderActive = false;
                });
              }),
              min: 2.0,
              max: 26.0,
              divisions: 6,
              value: selectedSize,
              label: 'Brush Stroke : $selectedSize',
              onChanged: (value) {
                setState(() {
                  selectedSize = value;
                });
              },
            ),
          ),
          AnimatedOpacity(
            opacity: isSliderActive ? 1.0 : 0.0,
            duration: const Duration(milliseconds: 500),
            child: Container(
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(
                  color: color == Colors.white
                      ? Colors.black
                      : const Color.fromARGB(255, 255, 255, 255),
                  width: 1,
                ),
                boxShadow: boxS,
              ),
              child: Container(
                height: selectedSize * 2,
                width: selectedSize * 2,
                decoration: BoxDecoration(
                  color: color,
                  shape: BoxShape.circle,
                ),
              ),
            ),
          ),
          Positioned(
            right: 20,
            bottom: 20,
            child: FloatingActionButton(
              tooltip: 'Undo',
              backgroundColor: Colors.red,
              child: const Icon(Icons.refresh),
              onPressed: () {
                setState(() {
                  pointsList.removeLast();
                  colorsList.removeLast();
                  sizeList.removeLast();
                });
              },
            ),
          ),
        ],
      ),
    );
  }
}
