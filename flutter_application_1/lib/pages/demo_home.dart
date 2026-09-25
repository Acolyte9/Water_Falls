import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_application_1/widgets/sensor_display.dart';
import 'package:flutter_application_1/widgets/modified_snake.dart';
import 'package:sensors_plus/sensors_plus.dart';

class SensorHomePage extends StatefulWidget {
  const SensorHomePage({super.key, this.title});

  final String? title;

  @override
  SensorHomePageState createState() => SensorHomePageState();
}

class SensorHomePageState extends State<SensorHomePage> {
  static const int _snakeRows = 20;
  static const int _snakeColumns = 20;
  static const double _snakeCellSize = 10.0;

  List<double>? _accelerometerValues;
  List<double>? _userAccelerometerValues;
  List<double>? _gyroscopeValues;
  List<double>? _magnetometerValues;
  final _streamSubscriptions = <StreamSubscription<dynamic>>[];

  @override
  void dispose() {
    super.dispose();
    for (final subscription in _streamSubscriptions) {
      subscription.cancel();
    }
  }

  @override
  void initState() {
    super.initState();
    _streamSubscriptions.add(
      accelerometerEvents.listen(
        (AccelerometerEvent event) {
          setState(() {
            _accelerometerValues = <double>[event.x, event.y, event.z];
          });
        },
      ),
    );
    _streamSubscriptions.add(
      gyroscopeEvents.listen(
        (GyroscopeEvent event) {
          setState(() {
            _gyroscopeValues = <double>[event.x, event.y, event.z];
          });
        },
      ),
    );
    _streamSubscriptions.add(
      userAccelerometerEvents.listen(
        (UserAccelerometerEvent event) {
          setState(() {
            _userAccelerometerValues = <double>[event.x, event.y, event.z];
          });
        },
      ),
    );
    _streamSubscriptions.add(
      magnetometerEvents.listen(
        (MagnetometerEvent event) {
          setState(() {
            _magnetometerValues = <double>[event.x, event.y, event.z];
          });
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final accelerometer =
        _accelerometerValues?.map((double v) => v.toStringAsFixed(1)).toList();
    final gyroscope =
        _gyroscopeValues?.map((double v) => v.toStringAsFixed(1)).toList();
    final userAccelerometer = _userAccelerometerValues
        ?.map((double v) => v.toStringAsFixed(1))
        .toList();
    final magnetometer =
        _magnetometerValues?.map((double v) => v.toStringAsFixed(1)).toList();

    Snake snake = Snake(
                    rows: _snakeRows,
                    columns: _snakeColumns,
                    cellSize: _snakeCellSize,
                  );

    return Scaffold(
      appBar: AppBar(
        title: Text(widget.title!),
      ),
      body: Column(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: <Widget>[
          Center(
            child: DecoratedBox(
              decoration: BoxDecoration(
                border: Border.all(width: 1.0, color: Colors.black38),
              ),
              child: SizedBox(
                height: _snakeRows * _snakeCellSize,
                width: _snakeColumns * _snakeCellSize,
                // child: Listener(
                //   // This will report a PointerDownEvent whenever the user presses the screen.
                //   // If you want updates as the user moves their finger across the screen,
                //   // use onPointerMove instead.
                //   onPointerDown: (PointerDownEvent event) {
                //     // Global screen position.
                //     // print("Global position x:${event.position.dx}, y:${event.position.dy}");
                //     // Position relative to where this widget starts.
                //     print("Relative position: x:${event.localPosition.dx}, y:${event.localPosition.dy}");
                //     snake.


                //   },
                child: snake
                // Snake(
                //   rows: _snakeRows,
                //   columns: _snakeColumns,
                //   cellSize: _snakeCellSize,
                // ),
                // ),
              ),
            ),
          ),
          // SensorDisplay(label: "Accelerometer", value: accelerometer),
          // SensorDisplay(label: "UserAccelerometer", value: userAccelerometer),
          // SensorDisplay(label: "Gyroscope", value: gyroscope),
          // SensorDisplay(label: "Magnetometer", value: magnetometer),
          Row(
            children: [
              ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.blue,
                  padding: EdgeInsets.symmetric(horizontal: 50, vertical: 20),
                  textStyle: TextStyle(
                  fontSize: 30,
                  fontWeight: FontWeight.bold)),
                onPressed: () {
                  snake.state.changeinteraction("water");
                },
                child: Text("Water"),
              ),
              ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.brown,
                  padding: EdgeInsets.symmetric(horizontal: 50, vertical: 20),
                  textStyle: TextStyle(
                  fontSize: 30,
                  fontWeight: FontWeight.bold)),
                onPressed: () {
                  snake.state.changeinteraction("solid");
                },
                
                child: Text("Dirt"),
              ),
              ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.grey,
                  padding: EdgeInsets.symmetric(horizontal: 50, vertical: 20),
                  textStyle: TextStyle(
                  fontSize: 30,
                  fontWeight: FontWeight.bold)),
                onPressed: () {
                  snake.state.changeinteraction("air");
                },
                child: Text("Air"),
              ),
            ],
          ),
        ],
      ),
    );
  }
}