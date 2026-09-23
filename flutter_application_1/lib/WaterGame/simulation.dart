import 'dart:math' as math;

enum Field {
  U_FIELD,
  V_FIELD,
  S_FIELD,
}

class Fluid {
  //fluid simulation translated from 10MinutePhysics

  final double density;
  final int numX;
  final int numY;
  final double h;

  late List<double> u; // x velocity
  late List<double> v; // y velocity

  late List<double> newu;
  late List<double> newv;

  late List<double> p;

  // 0.0 = solid
  // 1.0 = fluid
  late List<double> s;

  // 0.0 = empty
  // 1.0 = full
  late List<double> m;
  late List<double> newm;

  late double overRelaxation;

  Fluid(
    this.density,
    this.numX,
    this.numY,
    this.h,
  ) {
    final int size = numX * numY;

    u = List<double>.filled(size, 0.0);
    v = List<double>.filled(size, 0.0);

    newu = List<double>.filled(size, 0.0);
    newv = List<double>.filled(size, 0.0);

    p = List<double>.filled(size, 0.0);

    s = List<double>.filled(size, 1.0);

    m = List<double>.filled(size, 0.0);
    newm = List<double>.filled(size, 0.0);

    overRelaxation = 1.9;
  }

  int index(int i, int j) {
    return i * numY + j;
  }

  void integrate( //adds gravity to simulation
    double dt,
    double gravityX,
    double gravityY,
  ) {
    final int n = numY;

    for (int i = 1; i < numX - 1; i++) {
      for (int j = 1; j < numY - 1; j++) {
        if (s[i * n + j] != 0.0) {
          v[i * n + j] += gravityY * dt;
          u[i * n + j] += gravityX * dt;
        }
      }
    }
  }

  void solveIncompressibility(
    int iterations,
    double dt,
  ) {
    final int n = numY;

    final double cp = density * h / dt;

    for (int iter = 0; iter < iterations; iter++) {
      for (int i = 1; i < numX - 1; i++) {
        for (int j = 1; j < numY - 1; j++) {
          final int idx = i * n + j;

          if (s[idx] == 0.0) { //if solid
            continue;
          }

          final double sx0 = s[(i - 1) * n + j];
          final double sx1 = s[(i + 1) * n + j];
          final double sy0 = s[i * n + j - 1];
          final double sy1 = s[i * n + j + 1];

          //number of fluid neighbors
          final double neighboringFluid =
              sx0 + sx1 + sy0 + sy1;

          if (neighboringFluid == 0.0) {
            continue;
          }

          //divergence
          //the amount of water in each tile has to remain 1; if too much would flow in
          //or out, it has to find the 'correction' to ensure incompressibility
          final double div =
              u[(i + 1) * n + j] -
              u[i * n + j] +
              v[i * n + j + 1] -
              v[i * n + j];

          double correction =
              -div / neighboringFluid;

          correction *= overRelaxation;

          p[idx] += cp * correction;

          //apply correction
          u[i * n + j] -= sx0 * correction;
          u[(i + 1) * n + j] += sx1 * correction;

          v[i * n + j] -= sy0 * correction;
          v[i * n + j + 1] += sy1 * correction;
        }
      }
    }
  }


  void extrapolate() {
    final int n = numY;

    for (int i = 0; i < numX; i++) {
      u[i * n] = u[i * n + 1];
      u[i * n + numY - 1] =
          u[i * n + numY - 2];
    }

    for (int j = 0; j < numY; j++) {
      v[j] = v[n + j];

      final int last = (numX - 1) * n + j;
      final int secondLast = (numX - 2) * n + j;

      v[last] = v[secondLast];
    }
  }


  double sampleField(
    double x,
    double y,
    Field field,
  ) {
    final int n = numY;

    final double h1 = 1.0 / h;
    final double h2 = 0.5 * h;

    late List<double> f;

    double dx = 0.0;
    double dy = 0.0;

    switch (field) {
      case Field.U_FIELD:
        f = u;
        dy = h2;
        break;

      case Field.V_FIELD:
        f = v;
        dx = h2;
        break;

      case Field.S_FIELD:
        f = m;
        dx = h2;
        dy = h2;
        break;
    }

    x = math.max(
      math.min(x, numX * h),
      h,
    );

    y = math.max(
      math.min(y, numY * h),
      h,
    );

    final double gridX = (x - dx) * h1;
    final double gridY = (y - dy) * h1;

    int x0 = gridX.floor();
    int y0 = gridY.floor();

    x0 = math.max(
      0,
      math.min(x0, numX - 1),
    );

    y0 = math.max(
      0,
      math.min(y0, numY - 1),
    );

    final int x1 = math.min(
      x0 + 1,
      numX - 1,
    );

    final int y1 = math.min(
      y0 + 1,
      numY - 1,
    );

    final double tx = gridX - x0;
    final double ty = gridY - y0;

    final double sx = 1.0 - tx;
    final double sy = 1.0 - ty;

    final double value =
        sx * sy * f[x0 * n + y0] +
        tx * sy * f[x1 * n + y0] +
        tx * ty * f[x1 * n + y1] +
        sx * ty * f[x0 * n + y1];

    return value;
  }

  double avgU(int i, int j) {
    final int n = numY;

    return (
      u[i * n + j - 1] +
      u[i * n + j] +
      u[(i + 1) * n + j - 1] +
      u[(i + 1) * n + j]
    ) * 0.25;
  }

  double avgV(int i, int j) {
    final int n = numY;

    return (
      v[(i - 1) * n + j] +
      v[i * n + j] +
      v[(i - 1) * n + j + 1] +
      v[i * n + j + 1]
    ) * 0.25;
  }


  void advectVel(double dt) {
    newu = List<double>.from(u);
    newv = List<double>.from(v);

    final int n = numY;
    final double h2 = 0.5 * h;

    for (int i = 1; i < numX - 1; i++) {
      for (int j = 1; j < numY - 1; j++) {

        if (s[i * n + j] != 0.0 &&
            s[(i - 1) * n + j] != 0.0) {
          double x = i * h;
          double y = j * h + h2;

          final double velocityU =
              u[i * n + j];

          final double velocityV =
              avgV(i, j);

          x -= dt * velocityU;
          y -= dt * velocityV;

          final double sampledU =
              sampleField(
                x,
                y,
                Field.U_FIELD,
              );

          newu[i * n + j] = sampledU;
        }

        if (s[i * n + j] != 0.0 &&
            s[i * n + j - 1] != 0.0) {
          double x = i * h + h2;
          double y = j * h;

          final double velocityU =
              avgU(i, j);

          final double velocityV =
              v[i * n + j];

          x -= dt * velocityU;
          y -= dt * velocityV;

          final double sampledV =
              sampleField(
                x,
                y,
                Field.V_FIELD,
              );

          newv[i * n + j] = sampledV;
        }
      }
    }

    u = newu;
    v = newv;
  }

  void advectSmoke(double dt) {
    newm = List<double>.from(m);

    final int n = numY;
    final double h2 = 0.5 * h;

    for (int i = 1; i < numX - 1; i++) {
      for (int j = 1; j < numY - 1; j++) {
        if (s[i * n + j] == 0.0) {
          continue;
        }
        final double velocityU =
            (
              u[i * n + j] +
              u[(i + 1) * n + j]
            ) * 0.5;

        final double velocityV =
            (
              v[i * n + j] +
              v[i * n + j + 1]
            ) * 0.5;

        double x =
            i * h + h2;

        double y =
            j * h + h2;

        x -= dt * velocityU;
        y -= dt * velocityV;

        newm[i * n + j] =
            sampleField(
              x,
              y,
              Field.S_FIELD,
            );
      }
    }

    m = newm;
  }

  void simulate(
    double dt,
    double gravityX,
    double gravityY,
    int iterations,
  ) {
    integrate(
      dt,
      gravityX,
      gravityY,
    );

    p.fillRange(
      0,
      p.length,
      0.0,
    );

    solveIncompressibility(
      iterations,
      dt,
    );

    extrapolate();

    advectVel(dt);

    advectSmoke(dt);
  }

  void addCircle( //adds air or solid depending on 'solid' parameter
    double x,
    double y,
    double radius,
    bool solid
  ) {
    final int n = numY;

    for (int i = 1; i < numX - 1; i++) {
      for (int j = 1; j < numY - 1; j++) {
        final double dx = (i + 0.5) * h - x;

        final double dy = (j + 0.5) * h - y;

        if (dx * dx + dy * dy <
            radius * radius) {
          final int idx = i * n + j;
          s[idx] = solid? 0.0 : 1.0;

          m[idx] = 0.0;
        }
      }
    }
  }


  void addWater(
    double x,
    double y,
    double radius,
    double amount,
  ) {
    final int n = numY;
    
    for (int i = 1; i < numX - 1; i++) {
      for (int j = 1; j < numY - 1; j++) {
        final double dx = (i + 0.5) * h - x;

        final double dy = (j + 0.5) * h - y;

        if (dx * dx + dy * dy < radius * radius) {
          final int idx = i * n + j;

          s[idx] = 1.0;

          m[idx] = math.min(amount, 1.0);
        }
      }
    }
  }

  bool isCellSolid(int x, int y){
    return s[y * numY + x] == 0.0;
  }
}