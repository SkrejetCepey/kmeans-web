import 'dart:math';

import 'package:bloc/bloc.dart';
import 'package:flutter/material.dart';
import 'package:meta/meta.dart';

import '../kmeans.dart';

part 'controller_state.dart';



class ControllerCubit extends Cubit<ControllerState> {

  late KMeans _kmean;

  double xMin, xMax, yMin, yMax;

  ControllerCubit({this.xMin = 1, this.xMax = 5,
    this.yMin = 1, this.yMax = 5}) : super(ControllerInitial()) {
     _kmean = KMeans(
        iteration: 0,
        data: _generateRandomPointsList(50),
        centroids: _generateRandomPointsList(3));
  }

  Random randomGenerator = Random(255);
  Point _generateRandomPoint() => Point(
      xMin + xMax * randomGenerator.nextDouble(),
      yMin + yMax * randomGenerator.nextDouble());

  List<Point> _generateRandomPointsList(int size) => List<Point>.generate(size, (_) => _generateRandomPoint());

  MaterialColor getClusterColor(Point<num> point) {
    return _kmean.getColorOfCluster(point);
  }

  int get iterations => _kmean.iteration;

  void generatePoints() {
    _kmean = KMeans(
        iteration: 0,
        data: _generateRandomPointsList(50),
        centroids: _generateRandomPointsList(3));
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
    return d..addAll(_kmean.centroids)..sort((a, b) => a.x.compareTo(b.x));
  }

  List<Point> get dataWithoutCentroids {
    return _kmean.data;
  }

}
