import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'dart:math';


class physicsObject {
  double before_xPos = 0;
  double before_yPos = 0;
  double xPos = 0;
  double yPos = 0;
  double xVel = 0;
  double yVel = 0;
  double xAcc = 0;
  double yAcc = 0;
  double angle = 0;
  double angularVel = 0;
  double angularAcc = 0;

  double mass = 1;
  double rMass = 1;
  double baseTime = 0.016;
  double elasticConstant = 1;
  bool isClick = false;
  bool isClickAfter = true;
  bool isLongClick = false;

  void addXpos(double x) {
    before_xPos = xPos;
    xPos += x;
  }

  void subXpos(double x) {
    before_xPos = xPos;
    xPos -= x;
  }

  void addYpos(double y) {
    before_yPos = yPos;
    yPos += y;
  }

  void subYpos(double y) {
    before_yPos = yPos;
    yPos -= y;
  }

  void addXvel(double x) {
    xVel += x;
  }

  void subXvel(double x) {
    xVel -= x;
  }

  void addYvel(double y) {
    yVel += y;
  }

  void subYvel(double y) {
    yVel -= y;
  }

  void mulXvel(double v) {
    xVel *= v;
  }

  void mulYvel(double v) {
    yVel *= v;
  }

  void stop() {
    xVel = 0;
    yVel = 0;
  }

  void shuffle(int range1, int range2) {
    List vec = [1, -1];
    xVel =
        vec[Random().nextInt(2)] * (Random().nextInt(range2 - range1) + range1);
    yVel =
        vec[Random().nextInt(2)] * (Random().nextInt(range2 - range1) + range1);
  }

  void outVel() {
    if (yVel.abs() < 6.6) {
      yVel = 0;
    }
    if (xVel.abs() < 6.6) {
      xVel = 0;
    }
  }

  void setPosition(double x, double y) {
    before_xPos = xPos;
    before_yPos = yPos;
    xPos = x;
    yPos = y;
  }

  void addAngle(double ang) {
    angle += ang;
  }
}

class myBall extends physicsObject {
  late double ballRad;
  List<Path> draws = [];
  List<Path> backup_draws = [];
  List<Paint> paints = [];

  String objType = 'ball';
  late double momentI;

  double xPoint;
  double yPoint;
  double xVelocity;
  double yVelocity;
  double ballRadius;
  double ballMass;
  double angularVelocity;
  List<Path> ballPath = [];
  List<Paint> ballPaint = [];

  myBall(
      {Key? key,
        required this.xPoint,
        required this.yPoint,
        required this.xVelocity,
        required this.yVelocity,
        required this.ballRadius,
        required this.ballMass,
        required this.angularVelocity,
        this.ballPath = const [],
        this.ballPaint = const [],
      }) {
    before_xPos = xPos;
    before_yPos = yPos;
    super.xPos = xPoint;
    super.yPos = yPoint;
    super.xVel = xVelocity;
    super.yVel = yVelocity;
    super.mass = ballMass;
    super.rMass = 1 / ballMass;
    ballRad = ballRadius;

    if(ballPath.length == 0){
      Path draw1 = Path();
      Path draw2 = Path();
      for (double i = 0; i < ballRad - 1; i++) {
        draw1.arcTo(
            Rect.fromCircle(
              radius: i,
              center: Offset(
                0,
                0,
              ),
            ),
            0 ,
            (1.9 * pi),
            true);

        draw2.arcTo(
            Rect.fromCircle(
              radius: i,
              center: Offset(
                0,
                0,
              ),
            ),
            1.9 * pi ,
            0.1 * pi,
            true);
      }


      draws.add(draw1);
      draws.add(draw2);

      backup_draws.add(draw1);
      backup_draws.add(draw2);
    }
    else{
      draws=ballPath;
      backup_draws=ballPath.toList();
    }


    if(ballPaint.length == 0) {
      Paint paint1 = Paint()
        ..color = Color(0xffcce0ff)
        ..style = PaintingStyle.stroke
        ..strokeWidth = 2;

      Paint paint2 = Paint()
        ..color = Color(0xffb0cfff)
        ..style = PaintingStyle.stroke
        ..strokeWidth = 2;

      paints.add(paint1);
      paints.add(paint2);
    }
    else{
      paints=ballPaint;
    }

    angularVel = angularVelocity;
    momentI = 0.5 * mass * ballRad * ballRad;


  }

  bool isBallRegion(double checkX, double checkY) {
    if ((pow(super.xPos - checkX, 2) + pow(super.yPos - checkY, 2)) <=
        pow(ballRad, 2)) {
      return true;
    }
    return false;
  }


  void updateDraw() {
    var translationMatrix = Float64List.fromList([
      cos(angle), sin(angle), 0, 0,
      -sin(angle), cos(angle), 0, 0,
      0, 0, 1, 0,
      0, 0, 0, 1
    ]);

    for(int i=0; i<draws.length; i++){
      draws[i] = backup_draws[i].transform(translationMatrix);
      draws[i] = draws[i].shift(Offset(xPos, yPos));
    }

  }
}
