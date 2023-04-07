import 'package:flutter/material.dart';
import 'package:final_project_2023/screen_size_config.dart';
import 'package:final_project_2023/consts.dart';

class CustomChatBar extends ContinuousRectangleBorder {
  @override
  Path getOuterPath(Rect rect, {TextDirection? textDirection}) {
    final double innerCircleRadius = 150.0;

    double x = 150, y = 45, r = 0.5;
    Path path = Path()
      ..addRRect(RRect.fromRectAndCorners(rect))
      ..moveTo(rect.bottomCenter.dx + 77, rect.bottomCenter.dy)
      ..relativeQuadraticBezierTo(
          ((-x / 2) + (x / 6)) * (1 - r), 0, -x / 2 * r, y * r)
      ..relativeQuadraticBezierTo(
          -x / 6 * r, y * (1 - r), -x / 2 * (1 - r), y * (1 - r))
      ..relativeQuadraticBezierTo(
          ((-x / 2) + (x / 6)) * (1 - r), 0, -x / 2 * (1 - r), -y * (1 - r))
      ..relativeQuadraticBezierTo(-x / 6 * r, -y * r, -x / 2 * r, -y * r);
    path.lineTo(rect.width, 0.0);
    path.close();

    return path;
  }
}

class CustomShapeBorder extends ContinuousRectangleBorder {
  @override
  Path getOuterPath(Rect rect, {TextDirection? textDirection}) {
    final double innerCircleRadius = 150.0;

    Path path = Path();
    path.lineTo(0, rect.height);
    path.quadraticBezierTo(rect.width / 2 - (innerCircleRadius / 2) - 30,
        rect.height + 15, rect.width / 2 - 75, rect.height + 50);
    path.cubicTo(
        rect.width / 2 - 40,
        rect.height + innerCircleRadius - 40,
        rect.width / 2 + 40,
        rect.height + innerCircleRadius - 40,
        rect.width / 2 + 75,
        rect.height + 50);
    path.quadraticBezierTo(rect.width / 2 + (innerCircleRadius / 2) + 30,
        rect.height + 15, rect.width, rect.height);
    path.lineTo(rect.width, 0.0);
    path.close();

    return path;
  }
}

class AppBarBorder extends ShapeBorder {
  final bool usePadding;

  AppBarBorder({this.usePadding = true});

  @override
  EdgeInsetsGeometry get dimensions =>
      EdgeInsets.only(bottom: usePadding ? 20 : 0);

  @override
  Path getInnerPath(Rect rect, {TextDirection? textDirection}) => Path();

  @override
  Path getOuterPath(Rect rect, {TextDirection? textDirection}) {
    double x = SizeConfig.blockSizeHorizontal * 39.5,
        y = SizeConfig.blockSizeVertical * 8,
        r = 0.45;
    Path path = Path()
      ..addRRect(RRect.fromRectAndCorners(rect))
      ..moveTo(
          SizeConfig.blockSizeHorizontal *
              69.5 /*+ SizeConfig.blockSizeVertical * 32.2*/,
          rect.bottomCenter.dy)
      ..relativeQuadraticBezierTo(
          ((-x / 2) + (x / 6)) * (1 - r), 0, -x / 2 * r, y * r)
      ..relativeQuadraticBezierTo(
          -x / 6 * r, y * (1 - r), -x / 2 * (1 - r), y * (1 - r))
      ..relativeQuadraticBezierTo(
          ((-x / 2) + (x / 6)) * (1 - r), 0, -x / 2 * (1 - r), -y * (1 - r))
      ..relativeQuadraticBezierTo(-x / 6 * r, -y * r, -x / 2 * r, -y * r);
    path.lineTo(rect.width, 0.0);
    path.close();

    return path;
  }

  @override
  void paint(Canvas canvas, Rect rect, {TextDirection? textDirection}) {}

  @override
  ShapeBorder scale(double t) => this;
}

class ChatAppBar extends ShapeBorder {
  final bool usePadding;

  ChatAppBar({this.usePadding = true});

  @override
  EdgeInsetsGeometry get dimensions =>
      EdgeInsets.only(bottom: usePadding ? 20 : 0);

  @override
  Path getInnerPath(Rect rect, {TextDirection? textDirection}) => Path();

  @override
  Path getOuterPath(Rect rect, {TextDirection? textDirection}) {
    final double innerCircleRadius = 150.0;
    Size size = Size(rect.width, rect.height);
    Path path_0 = Path();
    path_0.moveTo(rect.bottomCenter.dx + 77, rect.bottomCenter.dy);
    path_0.lineTo(size.width * 0.5416667, size.height * 0.2857143);
    path_0.quadraticBezierTo(size.width * 0.5423750, size.height * 0.3519286,
        size.width * 0.5361667, size.height * 0.3465714);
    path_0.cubicTo(
        size.width * 0.5435000,
        size.height * 0.3606429,
        size.width * 0.4668333,
        size.height * 0.3567857,
        size.width * 0.4421667,
        size.height * 0.3571429);
    path_0.quadraticBezierTo(size.width * 0.4340417, size.height * 0.4005000,
        size.width * 0.4163333, size.height * 0.3980000);
    path_0.quadraticBezierTo(size.width * 0.3980833, size.height * 0.3947857,
        size.width * 0.3940000, size.height * 0.3560000);
    path_0.cubicTo(
        size.width * 0.3701667,
        size.height * 0.3560000,
        size.width * 0.2920000,
        size.height * 0.3594286,
        size.width * 0.2966667,
        size.height * 0.3480000);
    path_0.cubicTo(
        size.width * 0.2912917,
        size.height * 0.3586429,
        size.width * 0.2926250,
        size.height * 0.3380714,
        size.width * 0.2925000,
        size.height * 0.2842857);
    path_0.lineTo(rect.width, 0.0);
    path_0.close();

    return path_0;
  }

  @override
  void paint(Canvas canvas, Rect rect, {TextDirection? textDirection}) {}

  @override
  ShapeBorder scale(double t) => this;
}
