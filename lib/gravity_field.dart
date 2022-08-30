import 'dart:async';
import 'dart:math';
import 'objects.dart';
import 'package:flutter/material.dart';

class GravityField extends StatefulWidget {
  final List<dynamic> objects;
  final double gravity;
  final double mapX;
  final double mapY;
  final Color mapColor;
  final double frictionConstant;
  final double elasticConstant;

  const GravityField({
    Key? key,
    required this.objects,
    this.gravity = 600,
    required this.mapX,
    required this.mapY,
    required this.mapColor,
    this.frictionConstant = 0.7,
    this.elasticConstant = 0.8
  }) : super(key: key);

  @override
  _GravityFieldState createState() => _GravityFieldState();
}

class _GravityFieldState extends State<GravityField> with SingleTickerProviderStateMixin {
  bool isClick = false;
  bool isClickAfter = true;
  double mapY = 0;
  double mapX = 0;
  double elasticConstant = 0.8;
  List objList = [];
  List objPathList = [];
  List objPaintList = [];
  Color map_color = Colors.white;

  List pathList = [];

  late AnimationController _animationController;
  double baseTime = 0.016;
  int milliBaseTime = 16;
  double gravityAccel = 600;
  double frictionC = 0.7;

  List iPos = [];
  List fPos = [];

  double timerMilllisecond = 0;
  int longclickobj = 0;

  bool collapse = false;

  @override
  void initState() {
    // TODO: implement initState
    super.initState();

    _animationController =
        AnimationController(vsync: this, duration: Duration(milliseconds: 1));
    _animationController.repeat();

    objList = widget.objects;
    gravityAccel = widget.gravity;
    mapX = widget.mapX;
    mapY = widget.mapY;
    map_color = widget.mapColor;
    elasticConstant = widget.elasticConstant;
    frictionC = widget.frictionConstant;

    objList.forEach((e) {
      objPaintList.add(e.paints);
      objPathList.add(e.draws);
      e.yAcc=gravityAccel;
    });

  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onVerticalDragDown: (details) {
        for (var i = 0; i < objList.length; i++) {
          setState(() {
            if (objList[i].isBallRegion(
                details.localPosition.dx, details.localPosition.dy)) {
              objList[i].isClick = true;

              objList[i].stop();

            }
          });
        }
      },
      onVerticalDragEnd: (details) {
        for (var i = 0; i < objList.length; i++) {
          if (objList[i].isClick) {
            setState(() {
              objList[i].isClick = false;
              objList[i].isClickAfter = true;
            });
          }
        }
      },
      onLongPressDown: (details) {
        for (var i = 0; i < objList.length; i++) {
          setState(() {
            if (objList[i].isBallRegion(
                details.localPosition.dx, details.localPosition.dy)) {
              iPos.add(details.localPosition.dx);
              iPos.add(details.localPosition.dy);
              objList[i].isLongClick = true;
              longclickobj = i;
            }
          });
        }
      },
      onLongPressEnd: (details) {
        if (objList[longclickobj].isLongClick) {
          setState(() {
            objList[longclickobj].xVel =
                3 * (details.localPosition.dx - iPos[0]) / (0.7);
            objList[longclickobj].yVel =
                3 * (details.localPosition.dy - iPos[1]) / (0.7);

            objList[longclickobj].isLongClick = false;
            objList[longclickobj].isClick = false;
            objList[longclickobj].isClickAfter = true;
          });
        }

        iPos = [];
        fPos = [];
      },
      onVerticalDragUpdate: (details) {
        for (var i = 0; i < objList.length; i++) {
          if (objList[i].isClick) {
            setState(() {
              objList[i].setPosition(
                  details.localPosition.dx, details.localPosition.dy);
              objList[i].updateDraw();
            });
          }
        }
      },
      child: AnimatedBuilder(
          animation: _animationController,
          builder: (context, child) {
            int wallInt = 0;
            bool Collapse = false;
            bool flag = false;

            for (var i = 0; i < objList.length; i++) {
              if (!objList[i].isClick) {
                objList[i].addYvel(baseTime * objList[i].yAcc);
                objList[i].addXvel(baseTime * objList[i].xAcc);

                checkCollapse(objList, baseTime);

                wallInt = checkIsWall(objList[i]);

                if (checkIsWall(objList[i]) == 1) {

                  flag = true;

                  double wallCorrection = objList[i].yVel * baseTime +
                      objList[i].yPos +
                      objList[i].ballRad -
                      mapY -
                      1;
                  objList[i].subYpos(wallCorrection);


                  double vxi = objList[i].xVel;
                  double vyi = objList[i].yVel;

                  double xi = objList[i].xPos;
                  double yi = objList[i].yPos;

                  List<double> iPos = [xi, yi];

                  List<double> pPos = [xi, mapY];
                  List<double> ripVec = [pPos[0] - iPos[0], pPos[1] - iPos[1]];
                  List<double> ripNorVec = [
                    ripVec[0] /
                        sqrt(ripVec[0] * ripVec[0] + ripVec[1] * ripVec[1]),
                    ripVec[1] /
                        sqrt(ripVec[0] * ripVec[0] + ripVec[1] * ripVec[1])
                  ];

                  List<double> vipVec = [vxi, vyi];
                  List<double> vjpVec = [0, 0];
                  List<double> vijVec = [
                    vipVec[0] - vjpVec[0],
                    vipVec[1] - vjpVec[1]
                  ];


                  double pulse = (-(1 + elasticConstant) *
                      innerProduct(vijVec, ripNorVec)) /
                      ((objList[i].rMass) * innerProduct(ripNorVec, ripNorVec) +
                          (innerProduct(ripVec, ripNorVec) *
                              innerProduct(ripVec, ripNorVec)) /
                              objList[i].momentI);

                  double wi = objList[i].angularVel;


                  objList[i].mulYvel(-elasticConstant);
                  objList[i].mulXvel(elasticConstant);
                  objList[i].angularVel *= frictionC;
                }
                if (checkIsWall(objList[i]) == 2) {
                  flag = true;
                  objList[i].mulYvel(-elasticConstant);
                  objList[i].mulXvel(elasticConstant);
                  objList[i].angularVel *= frictionC;
                }
                if (checkIsWall(objList[i]) == 3) {
                  flag = true;
                  double wallCorrection =
                      objList[i].xPos + objList[i].ballRad - mapX + 1;
                  objList[i].subXpos(wallCorrection);
                  objList[i].mulXvel(-elasticConstant);
                  objList[i].mulYvel(elasticConstant);
                  objList[i].angularVel *= frictionC;
                }
                if (checkIsWall(objList[i]) == 4) {
                  flag = true;
                  double wallCorrection =
                      -objList[i].xPos + objList[i].ballRad + 1;
                  objList[i].addXpos(wallCorrection);
                  objList[i].mulXvel(-elasticConstant);
                  objList[i].mulYvel(elasticConstant);
                  objList[i].angularVel *= frictionC;
                }
                if (!flag && (checkIsWall(objList[i]) == 0)) {
                  //print(objList[i].yVel);
                  objList[i].addYpos(objList[i].yVel * baseTime);
                  objList[i].addXpos(objList[i].xVel * baseTime);
                }

                objList[i].angularVel += baseTime * objList[i].angularAcc;
                objList[i].addAngle(baseTime * objList[i].angularVel);

                flag = false;
              }

              objList[i].updateDraw();
            }


            return Container(
              width: mapX,
              height: mapY,
              color: map_color,
              child: CustomPaint(
                //painter: _paint(pathList: [ball.draw, newball.draw]),
                painter: _paint(
                  //pathList: [objList[0].draws, objList[1].draws] objPathList,
                  pathList: objPathList,
                  paintList: objPaintList,
                  //paintList: [objList[0].paints, objList[1].paints] objPaintList,
                ),
              ),
            );
          }),
    );
  }

  void checkCollapse(List<dynamic> objList, double baseTime) {
    for (int i = 0; i < objList.length; i++) {
      for (int j = i + 1; j < objList.length; j++) {
        if (getDistance(objList[i], objList[j]) <
            (objList[i].ballRad + objList[j].ballRad)) {
          double correctDistance = 0.5 *
              ((objList[i].ballRad + objList[j].ballRad) -
                  getDistance(objList[i], objList[j]) +
                  2);

          double eConstant = elasticConstant;

          double vxi = objList[i].xVel;
          double vyi = objList[i].yVel;
          double vxj = objList[j].xVel;
          double vyj = objList[j].yVel;

          double xi = objList[i].xPos;
          double yi = objList[i].yPos;
          double xj = objList[j].xPos;
          double yj = objList[j].yPos;

          double ri = objList[i].ballRad;
          double rj = objList[j].ballRad;

          List<double> iPos = [xi, yi];
          List<double> jPos = [xj, yj];

          List<double> pPos = [
            (ri * xj + rj * xi) / (ri + rj),
            (ri * yj + rj * yi) / (ri + rj)
          ];
          List<double> ripVec = [pPos[0] - iPos[0], pPos[1] - iPos[1]];
          List<double> ripNorVec = [
            ripVec[0] / sqrt(ripVec[0] * ripVec[0] + ripVec[1] * ripVec[1]),
            ripVec[1] / sqrt(ripVec[0] * ripVec[0] + ripVec[1] * ripVec[1])
          ];
          List<double> rjpVec = [pPos[0] - jPos[0], pPos[1] - jPos[1]];
          List<double> rjpNorVec = [
            rjpVec[0] / sqrt(rjpVec[0] * rjpVec[0] + rjpVec[1] * rjpVec[1]),
            rjpVec[1] / sqrt(rjpVec[0] * rjpVec[0] + rjpVec[1] * rjpVec[1])
          ];

          List<double> vipVec = [vxi, vyi];
          List<double> vjpVec = [vxj, vyj];
          List<double> vijVec = [vipVec[0] - vjpVec[0], vipVec[1] - vjpVec[1]];


          double viScala = sqrt(vxi * vxi + vyi * vyi);
          double vjScala = sqrt(vxj * vxj + vyj * vyj);


          objList[i].subXpos((viScala / (viScala + vjScala)) * correctDistance * ripNorVec[0]);
          objList[i].subYpos((viScala / (viScala + vjScala)) * correctDistance * ripNorVec[1]);


          objList[j].subXpos((vjScala / (viScala + vjScala)) * correctDistance * rjpNorVec[0]);
          objList[j].subYpos((vjScala / (viScala + vjScala)) * correctDistance * rjpNorVec[1]);


          double pulse = (-(1 + eConstant) * innerProduct(vijVec, ripNorVec)) /
              ((objList[i].rMass + objList[j].rMass) *
                  innerProduct(ripNorVec, ripNorVec) +
                  (innerProduct(ripVec, rjpNorVec) *
                      innerProduct(ripVec, rjpNorVec)) /
                      objList[i].momentI +
                  (innerProduct(rjpVec, rjpNorVec) *
                      innerProduct(rjpVec, rjpNorVec)) /
                      objList[j].momentI);

          double wi = objList[i].angularVel;
          double wj = objList[j].angularVel;
          //
          objList[i].xVel = vipVec[0] + pulse * objList[i].rMass * ripNorVec[0];
          objList[i].yVel = vipVec[1] + pulse * objList[i].rMass * ripNorVec[1];
          objList[j].xVel = vjpVec[0] + pulse * objList[j].rMass * rjpNorVec[0];
          objList[j].yVel = vjpVec[1] + pulse * objList[j].rMass * rjpNorVec[1];

          objList[i].angularVel = wi +
              pulse *
                  innerProduct([ripVec[1], ripVec[0]], ripNorVec) /
                  (objList[i].momentI);
          objList[j].angularVel = wj -
              pulse *
                  innerProduct([rjpVec[1], rjpVec[0]], ripNorVec) /
                  (objList[j].momentI);
        }
      }
    }
  }

  int checkIsWall(var obj) {
    if (obj.yVel * baseTime + obj.yPos + obj.ballRad >= mapY) {
      return 1;
    } else if (obj.yVel * baseTime + obj.yPos - obj.ballRad <= 0) {
      return 2;
    } else if (obj.xVel * baseTime + obj.xPos + obj.ballRad >= mapX) {
      return 3;
    } else if (obj.xVel * baseTime + obj.xPos - obj.ballRad <= 0) {
      return 4;
    }

    return 0;
  }
}

double getL2norm(List vec) {
  return vec[0] * vec[0] + vec[1] * vec[1];
}

double innerProduct(List vec1, List vec2) {
  return vec1[0] * vec2[0] + vec1[1] * vec2[1];
}

double getDistance(physicsObject obj1, physicsObject obj2) {
  return sqrt((obj1.xPos - obj2.xPos) * (obj1.xPos - obj2.xPos) +
      (obj1.yPos - obj2.yPos) * (obj1.yPos - obj2.yPos));
}

class _paint extends CustomPainter {
  final List pathList;
  final List paintList;

  _paint({
    required this.pathList,
    required this.paintList,
  });

  @override
  void paint(Canvas canvas, Size size) {
    Path path = Path();

    for (var i = 0; i < pathList.length; i++) {
      //canvas.drawShadow(pathList[i][0], Colors.grey, sqrt(10), false);
      //path.addPath(pathList[i], Offset.zero);
      canvas.drawPath(pathList[i][0], paintList[i][0]);
      canvas.drawPath(pathList[i][1], paintList[i][1]);
    }
    //canvas.drawPath(path, paintList[i][0]);
  }

  @override
  bool shouldRepaint(CustomPainter oldDelegate) => true;
}
