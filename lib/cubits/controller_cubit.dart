import 'dart:math';

import 'package:bloc/bloc.dart';
import 'package:flutter/material.dart';
import 'package:meta/meta.dart';

import '../kmeans.dart';

part 'controller_state.dart';

class ControllerCubit extends Cubit<ControllerState> {
  late KMeans _kmean;

  late double _xMin, _xMax, _yMin, _yMax;

  int pointsCount;
  int countCentroids;

  ControllerCubit(
      {this.pointsCount = 50, this.countCentroids = 3})
      : super(ControllerInitial()) {
    _xMin = 1;
    _xMax = 5;
    _yMin = 1;
    _yMax = 5;
    _kmean = KMeans(
        iteration: 0,
        data: _generateRandomPointsList(pointsCount),
        centroids: _generateRandomPointsList(countCentroids));
  }

  Random randomGenerator = Random(255);

  Point _generateRandomPoint() => Point(
      randomGenerator.nextDouble() * (xMax - xMin) + xMin,
      randomGenerator.nextDouble() * (yMax - yMin) + yMin);

  List<Point> _generateRandomPointsList(int size) =>
      List<Point>.generate(size, (_) => _generateRandomPoint());

  MaterialColor getClusterColor(Point<num> point) {
    return _kmean.getColorOfCluster(point);
  }

  int get iterations => _kmean.iteration;

  set xMin(double xMin) {

    if (xMin > xMax) {
      _xMin = xMax;
    } else {
      _xMin = xMin;
    }
    emit(ControllerChangeXMin());
  }
  set xMax(double xMax) {

    if (xMax < xMin) {
      _xMax = xMin;
    } else {
      _xMax = xMax;
    }
    emit(ControllerChangeXMax());
  }

  set yMin(double yMin) {

    if (yMin > yMax) {
      _yMin = yMax;
    } else {
      _yMin = yMin;
    }
    emit(ControllerChangeYMin());
  }

  set yMax(double yMax) {

    if (yMax < yMin) {
      _yMax = yMin;
    } else {
      _yMax = yMax;
    }
    emit(ControllerChangeYMax());
  }

  double get xMin => _xMin;
  double get xMax => _xMax;
  double get yMin => _yMin;
  double get yMax => _yMax;

  void changePointsCount(int newValue) {
    pointsCount = newValue;
    emit(ControllerChangePointsCount());
  }

  void changeCentroidsCount(int newValue) {
    countCentroids = newValue;
    emit(ControllerChangeCentroidsCount());
  }

  void generatePoints() {
    if (countCentroids > pointsCount) {
      changeCentroidsCount(pointsCount);
    }
    _kmean = KMeans(
        iteration: 0,
        data: _generateRandomPointsList(pointsCount),
        centroids: _generateRandomPointsList(countCentroids));
    emit(ControllerGeneratePoints());
  }

  void calcCentroids() {
    _kmean.fit();
    emit(ControllerCalcCentroids());
  }

  bool isCentroid(Point<num> point) => _kmean.centroids.contains(point);

  List<num> get dataCluster => _kmean.dataCluster;

  List<Point> get centroids => _kmean.centroids;

  List<Point> get data {
    var d = List<Point<num>>.from(_kmean.data);
    return d
      ..addAll(_kmean.centroids)
      ..sort((a, b) => a.x.compareTo(b.x));
  }

  List<Point> get dataWithoutCentroids {
    return _kmean.data;
  }
}
