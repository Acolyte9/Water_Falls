import 'dart:math' as math;
import 'simulation.dart';

class GameState {
  GameState(this.rows, this.columns) {
    // snakeLength = math.min(rows, columns) - 5;
    // this.rows ?? 0;
    Fluid fluid = Fluid(1000, columns, rows, 1/(math.max(rows, columns)));
    
  }

  int rows;
  int columns;
  // late int snakeLength;
  late Fluid fluid;
  // late int iterations;

  // List<math.Point<double>> body = <math.Point<double>>[const math.Point<double>(0, 0)];
  math.Point<double> direction = const math.Point<double>(0, 0);

  void step(math.Point<double>? newDirection) {
    // var next = body.last + direction;
    // next = math.Point<double>(next.x % columns, next.y % rows);

    // body.add(next);
    // if (body.length > snakeLength) body.removeAt(0);
    direction = newDirection ?? direction;
    
    fluid.simulate(0.2, direction.x, direction.y, 5);
    // iterations += 1;
  }
}