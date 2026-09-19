import 'dart:math' as math;

class Fluid{
  //This fluid sim is translated from Javascript code by 10MinutePhysics with comments by Jack.
  double density;
  int numX;
  int numY;
  double h; //spacing
  late List<double> u; //x velocity
  late List<double> v; //y velocity
  late List<double> newu;
  late List<double> newv;
  late List<double> p; //pressure
  late List<double> s; //whether cell is dirt (0 for dirt, 1 for water)
  late List<double> m; //fullness (technically smoke density)
  late List<double> newm;
  late double overRelaxation;

  Fluid(this.density, this.numX, this.numY, this.h){
    this.u = List.filled(numX * numY, 0.0);
    this.v = List.filled(numX * numY, 0.0);
    this.newu = List.filled(numX * numY, 0.0);
    this.newv = List.filled(numX * numY, 0.0);
    this.p = List.filled(numX * numY, 0.0);
    this.s = List.filled(numX * numY, 1.0);
    this.m = List.filled(numX * numY, 1.0);
    this.newm = List.filled(numX * numY, 0.0);
    this.overRelaxation = 1.9;
  }

  void integrate(double dt, double gravityx, double gravityy){ //adds gravity to fluid
    int n = numY;
    for(int i = 1; i < numX; i++){
      for(int j = 1; j < numY-1; j++){
        if (s[i*n + j] != 0.0 /*&& s[i*n + j-1] != 0.0*/){ //not sure if latter half if needed or needs to be extrapolated to every direction
          v[i*n + j] += gravityy * dt; //because we are using 1d lists, the 'x index' is multiplied by cols
          u[i*n + j] += gravityx * dt; //2d gravity is added by me and is important for the sensor to work both ways
        }
      }
    }
  }

  void solveIncompressibility(int iterations, double dt){
    int n = numY;
    double cp = density * h / dt;
    
    for(int iter = 0; iter < iterations; iter++){
      for(int i = 1; i < numX; i++){
        for(int j = 1; j < numY - 1; j++){

          if(this.s[i*n + j] == 0.0){ //if gridspace is solid
            continue;
          }

          //double s = this.s[i*n +j]; //this is in the JS code but im not sure why
          double sx0 = this.s[(i-1)*n + j];
          double sx1 = this.s[(i+1)*n + j];
          double sy0 = this.s[i*n + j-1];
          double sy1 = this.s[i*n + j+1];
          double s = sx0 + sx1 + sy0 + sy1; //how many neighboring cells are liquid
          if(s == 0.0){
            continue;
          }

          double div = u[(i+1)*n + j] - u[i*n + j] + v[i*n + j+1] - v[i*n + j];
          //divergence is the amount that the fluid will be displaced
          double p = (-1*div) / s;
          //pressure correction; if too much is flowing in/out of the cell,
          //this determines how much the div needs to change to ensure incompressibility
          p *= overRelaxation;
          this.p[i*n + j] += cp * p;

          u[i*n + j] -= sx0 * p;
          u[(i+1)*n + j] += sx1 * p;
          v[i*n + j] -= sy0 * p;
          v[i*n + (j+1)] += sy1 * p;
          //adding velocities such that fluid is not compressed
        }
      }
    }
  }

  void extrapolate(){
    int n = numY;
    for(int i = 0; i < numX; i++){
      u[i*n + 0] = u[i*n + 1];
      u[i*n + numY-1] = u[i*n + numY-2];
    }
    for(int j = 0; j < numY; j++){
      v[j] = v[n + j];
      v[(numX - 1)*n + j] = v[(numX-2)*n + j];
    }
  }


  double sampleField(double x, double y, Field field){
    int n = numY;
    double h = this.h;
    double h1 = 1.0 / h;
    double h2 = 0.5 * h;

    x = math.max(math.min(x, numX * h), h);
    y = math.max(math.min(y, numY * h), h);

    double dx = 0.0;
    double dy = 0.0;

    double x0 = math.min((x-dx) * h1, numX - 1);
    x0.floor();
    double tx = ((x-dx) - x0*h) * h1;
    double x1 = math.min(x0+1, numX-1);

    double y0 = math.min((y-dy)*h1, numY - 1);
    double ty = ((y-dy) - y0*h) * h1;
    double y1 = math.min(y0 + 1, numY-1);
    
    double sx = 1.0 - tx;
    double sy = 1.0 - ty;
    
    var f;
    switch(field){
      case Field.U_FIELD: f = u; dy = h2; break;
      case Field.V_FIELD: f = v; dx = h2; break;
      case Field.S_FIELD: f = m; dx = h2; dy = h2; break;
    }
    double val = sx*sy * f[x0*n + y0] + tx*sy * f[x1*n + y0] + tx*ty * f[x1*n + y1] + sx*ty * f[x0*n + y1];

    return val;
  }
  
  double avgU(i, j){
    int n = numY;
    double uValue = (u[i*n + j-1] + u[i*n + j] + u[(i+1)*n + j-1] + u[(i+1)*n + j]) * 0.25;
    return uValue;
  }
  double avgV(i, j){
    int n = numY;
    double vValue = (v[(i-1)*n + j] + v[i*n + j] + v[(i-1)*n + j+1] + v[i*n + j+1]) * 0.25;
    return vValue;
  }

  void advectVel(var dt){
    newu = u;
    newv = v;

    int n = numY;
    double h = this.h;
    double h2 = 0.5 * h;

    for(int i = 1; i < numX; i++){
      for(int j = 1; j < numY; j++){
        //u
        if(s[i*n + j] != 0.0 && s[(i-1)*n + j] != 0.0 && j < numY -1){
          double x = i*h;
          double y = j*h + h2;
          double u = this.u[i*n + j];
          double v = avgV(i, j);

          x = x - dt*u;
          y = y - dt*v;
          u = sampleField(x, y, Field.U_FIELD);
          newu[i*n + j] = u;
        }
        //v
        if(s[i*n + j] != 0.0 && s[i*n + j-1] != 0.0 && i < numX -1){
          double x = i*h + h2;
          double y = j*h;
          double u = avgU(i, j);
          double v = this.v[i*n + j];

          x = x - dt*u;
          y = y - dt*v;
          v = sampleField(x, y, Field.V_FIELD);
          newv[i*n + j] = v;
        }
      }
    }
    u = newu;
    v = newv;
  }

  void advectSmoke(dt){
    newm = m;
    int n = numY;
    double h = this.h;
    double h2 = 0.5 * h;

    for(int i = 1; i < numX-1; i++){
      for(int j = 1; j < numY-1; j++){
        if(s[i*n + j] != 0.0){
          double u = (this.u[i*n + j] + this.u[(i+1)*n + j]) * 0.5;
          double v = (this.v[i*n + j] + this.v[i*n + j+1]) * 0.5;
          double x = i*h + h2 - dt*u;
          double y = j*h + h2 - dt*v;

          newm[i*n + j] = sampleField(x, y, Field.S_FIELD);
        }
      }
    }
    m = newm;
  }
  // ^ end of simulation components

  void simulate(dt, gravityx, gravityy, iterations){
    integrate(dt, gravityx, gravityy);
    p.fillRange(0, p.length, 0.0);
    solveIncompressibility(iterations, dt);
    extrapolate();
    advectVel(dt);
    advectSmoke(dt);
  }

}