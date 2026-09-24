import 'dart:math' as math;
import 'simulation.dart';

enum Tap {
water,
solid,
air,
}

class GameState {
  GameState(this.rows, this.columns) {
    // snakeLength = math.min(rows, columns) - 5;
    // this.rows ?? 0;
    fluid = Fluid(1000, columns, rows, 1/(math.max(rows, columns)));
  }

  int rows;
  int columns;
  // late int snakeLength;
  late Fluid fluid;
  // late int iterations;
  Tap tap = Tap.water;



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

  void changeinteraction(Tap newtype) {
    tap = newtype;
  }

  void alterterrain(double x, double y) {
    if (tap == Tap.water) {
      fluid.addWater(x, y, 1, 1);
    }
    else if (tap == Tap.solid) {
      fluid.addCircle(x, y, 1, true);
    }
    else if (tap == Tap.air) {
      fluid.addCircle(x, y, 1, false);
    }
  }
}