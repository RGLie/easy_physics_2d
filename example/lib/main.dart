import 'dart:math';
import 'package:easy_physics_2d/gravity_field.dart';
import 'package:easy_physics_2d/objects.dart';
import 'package:flutter/material.dart';



void main() {
  runApp(const MyApp());
}

class colorLibrary {
  static Color mainColor2 = const Color.fromARGB(255, 255, 248, 235);
  static Color mapColor = const Color(0xffefe0c3);
  static Color mainColor = const Color.fromARGB(255, 214, 237, 255);
  static Color buttonColor = const Color(0xffffd6a9);
}


class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    final newTextTheme = Theme.of(context).textTheme.apply(
      bodyColor: Colors.white70,
      displayColor: Colors.black87,
    );

    return MaterialApp(
        title: 'Flutter Physics World',
        debugShowCheckedModeBanner: false,
        theme: ThemeData(
            scaffoldBackgroundColor: colorLibrary.mainColor2,
            //primarySwatch: Colors.indigo,
            textTheme: newTextTheme),
        home: HomePage());
  }
}


class HomePage extends StatefulWidget {
  const HomePage({Key? key}) : super(key: key);

  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  double sliderValue = 1000;

  Paint paint1 = Paint()
    ..color = Color(0xff263e63)
    ..style = PaintingStyle.stroke
    ..strokeWidth = 2;

  Paint paint2 = Paint()
    ..color = Color(0xff15693b)
    ..style = PaintingStyle.stroke
    ..strokeWidth = 2;

  List<Paint> paintList = [];
  List<dynamic> objList = [];

  Path draw1 = Path();
  Path draw2 = Path();

  var ball;
  var ball2;


  @override
  void initState() {
    super.initState();

    for (double i = 0; i < 20 - 1; i++) {
      draw1.arcTo(
          Rect.fromCircle(
            radius: i,
            center: Offset(
              0,
              0,
            ),
          ),
          0 ,
          (1.5 * pi),
          true);

      draw2.arcTo(
          Rect.fromCircle(
            radius: i,
            center: Offset(
              0,
              0,
            ),
          ),
          1.5 * pi ,
          0.5 * pi,
          true);
    }

    paintList=[paint1, paint2];
    ball = myBall(
        xPoint: 100,
        yPoint: 200,
        xVelocity: 0,
        yVelocity: 0,
        ballRadius: 30,
        ballMass: 0.5,
        angularVelocity: 0,
        ballPaint: paintList
    );
    ball2 = myBall(
      xPoint: 150,
      yPoint: 100,
      xVelocity: 0,
      yVelocity: 0,
      ballRadius: 20,
      ballMass: 0.5,
      angularVelocity: 0,
      ballPath: [draw1, draw2],
    );
    objList = [ball, ball2];
  }

  @override
  Widget build(BuildContext context) {
    //print(objList.length);

    return Scaffold(
      body: _buldBody(),
    );
  }

  Widget _buldBody() {
    //print(ball.xPos);



    return Container(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          Text(
            "Flutter Physics",
            style: TextStyle(
                fontWeight: FontWeight.w800,
                fontSize: 40,
                color: Colors.black45),
          ),

          Container(
            child: GravityField(
              objects: objList,
              gravity: sliderValue,
              mapX: 350,
              mapY: 350,
              mapColor: colorLibrary.mapColor,

            ),
            padding: EdgeInsets.all(1),
          ),

          Row(mainAxisAlignment: MainAxisAlignment.spaceAround, children: [
            Container(
              height: 60,
              width: 60,
              decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(10),
                  color: colorLibrary.buttonColor),
              child: IconButton(
                icon: Icon(Icons.stop_circle_outlined,
                    color: Colors.white, size: 40),
                onPressed: () {
                  for (int i = 0; i < objList.length; i++) {
                    objList[i].stop();
                  }
                },
              ),
            ),
            Container(
              height: 60,
              width: 60,
              decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(10),
                  color: colorLibrary.buttonColor),
              child: IconButton(
                icon: Icon(Icons.shuffle, color: Colors.white, size: 40),
                onPressed: () {
                  for (int i = 0; i < objList.length; i++) {
                    objList[i].shuffle(100, 1500);
                  }
                },
              ),
            ),

            Row(
              children: [
                Text('Gravity :', style: TextStyle(fontSize: 20, color: Colors.brown),),
                SliderTheme(
                  data: SliderThemeData(
                    activeTrackColor: Colors.brown,
                    thumbColor: Colors.brown,
                    activeTickMarkColor: Colors.brown,
                    valueIndicatorColor: Colors.brown,
                    valueIndicatorShape: PaddleSliderValueIndicatorShape(),
                  ),
                  child: Slider(
                    value: sliderValue,
                    min: 0.0,
                    max: 3000.0,
                    divisions: 50,
                    label: '${sliderValue.toInt()}',
                    onChanged: (double newValue) {
                      setState( () {
                        sliderValue = newValue;
                        ball.yAcc = newValue;
                        ball2.yAcc = newValue;
                      },
                      );
                    },
                  ),
                ),
              ],
            ),
          ])
        ],
      ),
    );
  }
}
