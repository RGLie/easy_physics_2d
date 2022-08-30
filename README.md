## Easy 2D Physics in Flutter
This package makes it easy to use a 2D physical engine in flutter.  You can experience acceleration, collision, and rotation.
## Installation
1.  Add this package to your `pubspec.yaml` file.
	```
		dependencies:
			easy_physics_2d: '^0.0.1'
	```
2. Install it.
   ``` 
	   $ pub get
   ```
3. Import.
	```
	    import 'package:easy_physics_2d/easy_physics_2d.dart';
	```
## Usage
```dart
	List<dynamic> objList = [];
	var ball;
	
	@override
	void initState(){
		super.initState();
		ball = myBall(  
					xPoint: 100,  
					yPoint: 200,  
					xVelocity: 0,  
					yVelocity: 0,  
					ballRadius: 30,  
					ballMass: 0.5,  
					angularVelocity: 0,  
				);
		objList = [ball];
	}

	GravityField(  
		objects: objList,  
		mapX: 350,  
		mapY: 350,  
		mapColor: Colors.white  
	),
```
This is the most basic code for using a package. You can add a `GravityField` widget and add a list of physical objects that you want to put in the field.
```dart
	GravityField(  
		objects: objList,  
		gravity: 1000,  
		mapX: 350,  
		mapY: 350,  
		mapColor: Colors.white,
		gravity: 1500,
		frictionConstant: 0.8,
		elasticConstant: 0.9,
	),
```
You can change the detailed properties of the field by changing `gravity`, `frictionConstant` and `elasticConstant`.

For the ball objects, you can also change designs.
```dart
class _HomePageState extends State<HomePage> {  
	Paint paint1 = Paint()  
	  ..color = Color(0xff263e63)  
	  ..style = PaintingStyle.stroke  
	  ..strokeWidth = 2;  

	Paint paint2 = Paint()  
	  ..color = Color(0xff15693b)  
	  ..style = PaintingStyle.stroke  
	  ..strokeWidth = 2;  

	List<Paint> paintList = [];  

	Path draw1 = Path();  
	Path draw2 = Path();  
  
	var ball;  
	var ball2;  
  
	@override  
	void initState() {  
		super.initState();  
		for (double i = 0; i < 20 - 1; i++) {  
			draw1.arcTo(Rect.fromCircle(radius: i, center: Offset(0, 0,)), 0, (1.5 * pi), true);  
			draw2.arcTo(Rect.fromCircle(radius: i, center: Offset(0, 0,)), 1.5 * pi, 0.5 * pi, true);  
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
				ballPaint: paintList,
				ballPath: [draw1, draw2], 
		  );  
		ball2 = myBall(  
		        xPoint: 150,  
				yPoint: 100,  
				xVelocity: 0,  
				yVelocity: 0,  
				ballRadius: 20,  
				ballMass: 0.5,  
				angularVelocity: 0,  
				 
		);  
		objList = [ball, ball2];  
	}
}
```
with the parameter `ballPath` and `ballPaint`, you can change `Path`  and Colors of the Ball. At this time, the length of `ballPath` List and the length of `ballPaint` List should be the same, and they should be defined in initState.

Each object has the following instance methods, which are easy to use.
```dart
var ball = myBall(  
	        xPoint: 100,  
			yPoint: 200,  
			xVelocity: 0,  
			yVelocity: 0,  
			ballRadius: 30,  
			ballMass: 0.5,  
			angularVelocity: 0,  
		); 
		 
double n;
double m;
int range1 = 100;
int range2 = 1500;
double x, y;

ball.addXpos(n); //return void
ball.subXpos(n); //return void
ball.addYpos(n); //return void
ball.subYpos(n); //return void

ball.addXvel(m); //return void
ball.subXvel(m); //return void
ball.addYvel(m); //return void
ball.subYvel(m); //return void

ball.stop(); //return void
ball.shuffle(range1, range2); //return void : set velocity randomly range1 to range2

ball.setPosition(x, y); //return void
ball.addAngle(n); //return void

ball.isBallRegion(x, y); //return true if (x, y) is in Ball area

ball.updateDraw(); //return void: if you want tochange the position, you should run this method.
```
If you want to move the `Ball`, please use the instance method to control it.