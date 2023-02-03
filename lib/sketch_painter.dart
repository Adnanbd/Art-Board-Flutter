import 'package:flutter/material.dart';

double sizeToStroke(double size) {
  return size * 2;
}

class Sketcher extends CustomPainter {
  final List<Offset> points;
  final List<List<Offset>> pointsList;
  Color color;
  List<Color> colorsList;
  double selectedSize;

  List<double> sizeList;

  Sketcher(
    this.points,
    this.pointsList,
    this.color,
    this.colorsList,
    this.selectedSize,
    this.sizeList,
  );

  @override
  bool shouldRepaint(Sketcher oldDelegate) => true;

  @override
  void paint(Canvas canvas, Size size) {
    Paint paint = Paint()
      ..color = color
      ..strokeCap = StrokeCap.round
      ..strokeWidth = sizeToStroke(selectedSize);

    //Paining current line
    for (int i = 0; i < pointsList.length; i++) {
      for (var j = 0; j < pointsList[i].length - 1; j++) {
        if (pointsList[i][j] != Offset.zero &&
            pointsList[i][j + 1] != Offset.zero) {
          Paint tempP = getPaint(colorsList[i], sizeToStroke(sizeList[i]));
          canvas.drawLine(pointsList[i][j], pointsList[i][j + 1], tempP);
        }
      }
    }

    //Painting all previous lines from saved values
    for (int i = 0; i < points.length - 1; i++) {
      if (points[i] != Offset.zero && points[i + 1] != Offset.zero) {
        canvas.drawLine(points[i], points[i + 1], paint);
      }
    }
  }

  Paint getPaint(Color colorM, double strokeWidth) {
    Paint paint = Paint()
      ..color = colorM
      ..strokeCap = StrokeCap.round
      ..strokeWidth = strokeWidth;

    return paint;
  }
}
