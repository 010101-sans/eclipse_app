import 'package:flutter/material.dart';
import 'dart:math';
import 'dart:async';


void main() {
  runApp(MyApp());
}

double? screenHeight;

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Nasa App',
      theme: ThemeData(
        brightness: Brightness.dark,
      ),
      home: MyHomePage(),
    );
  }
}

class MyHomePage extends StatefulWidget {
  @override
  _MyHomePageState createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  List<Widget> _randomDots = [];

  @override
  void initState() {
    super.initState();
  }

  void _generateRandomDots() {
    final random = Random();
    final numDots = 200;
    final dotSize = 2.0;

    for (int i = 0; i < numDots; i++) {
      final x = random.nextDouble() * MediaQuery.of(context).size.width;
      final y = random.nextDouble() * MediaQuery.of(context).size.height;

      final dot = Positioned(
        left: x,
        top: y,
        child: Container(
          width: dotSize,
          height: dotSize,
          decoration: BoxDecoration(
            color: Colors.white,
            shape: BoxShape.circle,
          ),
        ),
      );

      setState(() {
        _randomDots.add(dot);
      });
    }
  }

  void _showInfoBottomSheet(BuildContext context) {
    showModalBottomSheet(
      context: context,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16.0)),
      ),
      builder: (BuildContext context) {
        return Container(
          height: MediaQuery.of(context).size.height * 0.75,
          child: PageView(
            children: [
              ExplanationPage(
                title: 'Lunar Eclipse',
                explanation: '''
A lunar eclipse occurs when the Earth comes directly between the Sun and the Moon, causing the Earth's shadow to be cast on the Moon. This can only happen during a full moon.


During a lunar eclipse:
    
    - The Earth blocks sunlight from reaching the Moon.

    - The Moon can appear to turn a reddish color due to the Earth's atmosphere.

    - Lunar eclipses are safe to view with the naked eye.
''',
              ),
              ExplanationPage(
                title: 'Solar Eclipse',
                explanation: '''
A solar eclipse occurs when the Moon comes directly between the Sun and the Earth, blocking out the Sun's light. This can only happen during a new moon.


During a solar eclipse:

    - The Moon's shadow is cast on the Earth's surface.

    - There are different types of solar eclipses, including total, partial, and annular.

    - It's important to use proper eye protection when viewing a solar eclipse to avoid eye damage.
''',
              ),
            ],
          ),
        );
      },
    );
  }


  @override
  Widget build(BuildContext context) {
    screenHeight = MediaQuery.of(context).size.height;

    _generateRandomDots();

    return SafeArea(
      child: Scaffold(
        appBar: PreferredSize(
          preferredSize: Size.fromHeight(60.0),
          child: AppBar(
            backgroundColor: Colors.transparent, // Make the app bar transparent
        elevation: 0, // Remove the elevation shadow
            centerTitle: true,
            title: Text('Eclipse Demo'),
            actions: [
              Container(
                  margin: EdgeInsets.only(right: 10),
                child: IconButton(
                  icon: Icon(Icons.info),
                  onPressed: () {
                    _showInfoBottomSheet(context);
                  },
                ),
              ),
            ],
            flexibleSpace: Container(
              decoration: BoxDecoration(
                borderRadius: BorderRadius.only(
                  bottomLeft: Radius.circular(16.0),
                  bottomRight: Radius.circular(16.0),
                ),
                color: Colors.black
                    .withOpacity(0.3), // Transparent glass-like background
              ),
              margin: EdgeInsets.all(8.0), // Margin from all sides
            ),
          ),
        ),
        body: Stack(
          children: <Widget>[
            Container(
              color: Colors.black,
            ),
            ..._randomDots,
            SunWidget(),
            Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: <Widget>[
                  EarthMoonWidget(),
                  SizedBox(height: 20),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class SunWidget extends StatefulWidget {
  @override
  _SunWidgetState createState() => _SunWidgetState();
}

class _SunWidgetState extends State<SunWidget> {
  double _rotationAngle = 0.0;

  @override
  void initState() {
    super.initState();
    _startRotation();
  }

  void _startRotation() {
    Timer.periodic(Duration(milliseconds: 50), (_) {
      setState(() {
        _rotationAngle += 0.001;
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    double sunPositionTop = screenHeight! * 0.38;

    return Positioned(
      left: -120.0,
      top: sunPositionTop,
      child: RotationTransition(
        turns: AlwaysStoppedAnimation(_rotationAngle),
        child: Container(
          width: 180.0,
          height: 150.0,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            image: DecorationImage(
              image: AssetImage('assets/images/sun.png'),
              fit: BoxFit.fill,
            ),
          ),
        ),
      ),
    );
  }

  @override
  void dispose() {
    super.dispose();
  }
}

class EarthMoonWidget extends StatefulWidget {
  @override
  _EarthMoonWidgetState createState() => _EarthMoonWidgetState();
}

class _EarthMoonWidgetState extends State<EarthMoonWidget> {
  double _earthRotation = 0.0;
  double _moonRotation = 0.0;
  double _earthRadius = 80.0;
  double _moonRadius = 25.0;
  double _moonOrbitRadius = 120.0;
  double _earthRotationSpeed = 0.01;
  double _moonRotationSpeed = 0.05;
  bool _isRotating = true;
  Timer? _rotationTimer;

  @override
  void initState() {
    super.initState();
    _startRotation();
  }

  void _startRotation() {
    if (_isRotating) {
      _rotationTimer = Timer.periodic(Duration(milliseconds: 50), (_) {
        setState(() {
          _moonRotation += _moonRotationSpeed;
          _earthRotation += _earthRotationSpeed;
        });
      });
    }
  }

  void _handleTouch() {
    setState(() {
      _isRotating = !_isRotating;
      if (_isRotating) {
        _startRotation();
      } else {
        _rotationTimer?.cancel();
        _rotationTimer = null;
      }
    });
  }

  void _handleDrag(details) {
    if (_isRotating) {
      _isRotating = false;
      _rotationTimer?.cancel();
      _rotationTimer = null;
    }
    setState(() {
      double dx = details.localPosition.dx - _earthRadius;
      double dy = details.localPosition.dy - _earthRadius;
      double angle = atan2(dy, dx);
      double oppositeAngle = angle + pi;
      double orbitX = _moonOrbitRadius * cos(oppositeAngle);
      double orbitY = _moonOrbitRadius * sin(oppositeAngle);
      _moonRotation = oppositeAngle;
      _earthRotation = angle;
    });
  }

  double _calculateShadowPosition(double positionX, double radius,
      double orbitRadius, double rotationSpeed) {
    double direction = rotationSpeed >= 0 ? 1.0 : -1.0;

    if (direction == -1.0) {
      return (positionX + radius) / (radius * 2 + orbitRadius);
    } else {
      return (radius - positionX) / (radius * 2 + orbitRadius);
    }
  }

  double _calculateEarthShadowPosition(double positionX, double radius,
      double orbitRadius, double rotationSpeed) {
    double direction = rotationSpeed >= 0 ? 1.0 : -1.0;

    if (direction == 1.0) {
      double factor = 2.0;
      return (radius - positionX) / (radius * 2 + orbitRadius) * factor;
    } else {
      return ((positionX + radius) / (radius * 2 + orbitRadius));
    }
  }

  @override
  Widget build(BuildContext context) {
    double moonPositionX = _moonOrbitRadius * cos(_moonRotation);
    double moonPositionY = _moonOrbitRadius * sin(_moonRotation);

    double _earthShadowPosition = _calculateEarthShadowPosition(
      _moonOrbitRadius - moonPositionX,
      _earthRadius,
      _moonOrbitRadius,
      _earthRotationSpeed,
    );

    double _moonShadowPosition = _calculateShadowPosition(
      moonPositionX + _moonRadius,
      _moonRadius,
      _earthRadius * 2,
      _moonRotationSpeed,
    );

    return GestureDetector(
      onTap: _handleTouch,
      onPanUpdate: _handleDrag,
      onPanEnd: (details) {
        _isRotating = true;
        _startRotation();
      },
      child: Container(
        width: _earthRadius * 3,
        height: _earthRadius * 3,
        child: Stack(
          alignment: Alignment.center,
          children: [
            Transform.rotate(
              angle: _earthRotation,
              child: Container(
                width: _earthRadius * 2,
                height: _earthRadius * 2,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  image: DecorationImage(
                    image: AssetImage('assets/images/earth.png'),
                    fit: BoxFit.fill,
                  ),
                ),
              ),
            ),
            Container(
              width: _earthRadius * 2,
              height: _earthRadius * 2,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: LinearGradient(
                  begin: Alignment.centerLeft,
                  end: Alignment.centerRight,
                  stops: [0.0, _earthShadowPosition, 1.0],
                  colors: [
                    Colors.transparent,
                    Color.fromARGB(210, 0, 0, 0),
                    Colors.black,
                  ],
                ),
              ),
            ),
            Transform.translate(
              offset: Offset(moonPositionX, moonPositionY),
              child: Stack(
                alignment: Alignment.center,
                children: [
                  Transform.rotate(
                    angle: _moonRotation,
                    child: Container(
                      width: _moonRadius * 2,
                      height: _moonRadius * 2,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        image: DecorationImage(
                          image: AssetImage('assets/images/moon.png'),
                          fit: BoxFit.fill,
                        ),
                      ),
                    ),
                  ),
                  Container(
                    width: _moonRadius * 2,
                    height: _moonRadius * 2,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      gradient: LinearGradient(
                        begin: Alignment.centerLeft,
                        end: Alignment.centerRight,
                        stops: [0.0, _moonShadowPosition, 1.0],
                        colors: [
                          Colors.transparent,
                          Color.fromARGB(210, 0, 0, 0),
                          Colors.black,
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  void dispose() {
    _rotationTimer?.cancel();
    super.dispose();
  }
}

class ExplanationPage extends StatelessWidget {
  final String title;
  final String explanation;

  ExplanationPage({required this.title, required this.explanation});

  @override
  Widget build(BuildContext context) {
    return ListView(
      children: [
        Padding(
          padding: const EdgeInsets.all(16.0),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              if (title == "Solar Eclipse") Icon(Icons.arrow_left),
              SizedBox(width: 10),
              Text(
                title,
                style: TextStyle(
                  fontSize: 24.0,
                  fontWeight: FontWeight.bold,
                ),
              ),
              SizedBox(width: 10),
              if (title == "Lunar Eclipse") Icon(Icons.arrow_right),
            ],
          ),
        ),
        Padding(
          padding: const EdgeInsets.all(16.0),
          child: Text(
            explanation,
            style: TextStyle(
              fontSize: 20.0,
            ),
          ),
        ),
      ],
    );
  }
}
