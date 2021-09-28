
import 'dart:math';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:collection/collection.dart';

enum ColorsClusters {
  Cluster1,
  Cluster2,
  Cluster3
}

class KMeans {

  int iteration;
  List<Point> centroids;
  final List<Point> data;
  Function _eq = const ListEquality().equals;

  late List<int> _dataCluster;

  KMeans({required this.iteration, required this.data, required this.centroids}) {
    _dataCluster = _findClusters(data, centroids);
  }

  int calculateClusterIndexOfElement(Point<num> point) {

    var indexOfElement = data.indexOf(point);
    if (indexOfElement == -1) {
      return 3;
    }
    final List<double> distancesFromCentroids = List.generate(
      centroids.length,
          (centroidIndex) => data[indexOfElement].distanceTo(centroids[centroidIndex]),
    );

    return (distancesFromCentroids.indexOf(distancesFromCentroids.reduce(min)) > 0) ? distancesFromCentroids.indexOf(distancesFromCentroids.reduce(min)) : 3;
  }

  MaterialColor getClusterColor(ColorsClusters cc){
    switch(cc){
      case ColorsClusters.Cluster1: return Colors.yellow;
      case ColorsClusters.Cluster2: return Colors.green;
      case ColorsClusters.Cluster3: return Colors.cyan;
      default: return Colors.blue;
    }
  }

  MaterialColor getColorOfCluster(Point<num> point) {
    switch(calculateClusterIndexOfElement(point)){
      case 0: return Colors.yellow;
      case 1: return Colors.green;
      case 2: return Colors.cyan;
      default: return Colors.blue;
    }
    // return getClusterColor(calculateClusterIndexOfElement(point) as ColorsClusters);
  }

  List<num> get dataCluster => _dataCluster;

  static List<int> _findClusters(List<Point> data, List<Point> centroids) {
    return List.generate(data.length, (dataIndex) {
      final List<double> distancesFromCentroids = List.generate(
        centroids.length,
            (centroidIndex) => data[dataIndex].distanceTo(centroids[centroidIndex]),
      );
      final ordered = [...distancesFromCentroids]..sort();
      return distancesFromCentroids.indexOf(ordered[0]);
    });
  }

  void fit() {
    // print(centroids);
    List<int> counters = List<int>.generate(centroids.length, (_) => 0);
    List<Point> newMeans = List<Point>.generate(
      centroids.length,
          (_) => const Point(0.0, 0.0),
    );

    for (int index = 0; index < data.length; index++) {
      newMeans[_dataCluster[index]] += data[index];
      counters[_dataCluster[index]]++;
    }
    for (int index = 0; index < centroids.length; index++) {
      newMeans[index] = (counters[index] > 0) ? newMeans[index] * (1 / counters[index]) : const Point<num>(0, 0);
    }

    if (!_eq(centroids, newMeans)) {
      iteration++;
      centroids = newMeans;
      _dataCluster = _findClusters(data, centroids);
    }

  }

  KMeans next() {
    List<int> counters = List<int>.generate(centroids.length, (_) => 0);
    List<Point> newMeans = List<Point>.generate(
      centroids.length,
          (_) => const Point(0.0, 0.0),
    );
    for (int index = 0; index < data.length; index++) {
      newMeans[_dataCluster[index]] += data[index];
      counters[_dataCluster[index]]++;
    }
    for (int index = 0; index < centroids.length; index++) {
      newMeans[index] = (counters[index] > 0) ? newMeans[index] * (1 / counters[index]) : const Point<num>(0, 0);
    }
    // final newDataClusters = _findClusters(data, newMeans);
    return KMeans(
        data: data,
        iteration: iteration + 1,
        // _dataCluster: newDataClusters,
        centroids: newMeans);
  }

}