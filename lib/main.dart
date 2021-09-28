import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:syncfusion_flutter_charts/charts.dart';
import 'package:untitled3/cubits/controller_cubit.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: HomePage(),
    );
  }
}

class HomePage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return BlocProvider<ControllerCubit>(
      create: (_) => ControllerCubit(),
      child: Scaffold(
        body: Column(children: [
          Text("Text1"),
          Row(
            children: [
              Expanded(child: BlocBuilder<ControllerCubit, ControllerState>(
                builder: (context, state) {
                  return KMeansPlot();
                },
              )),
              Expanded(child: SystemPanel())
            ],
          ),
          Row(
            children: [
              Expanded(child: StatusesPanel()),
            ],
          )
        ]),
      ),
    );
  }
}

class StatusesPanel extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return BlocBuilder<ControllerCubit, ControllerState>(
      builder: (context, state) {
        return Padding(
          padding: const EdgeInsets.all(10.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text("Statuses:"),
              Text("Iterations: ${BlocProvider.of<ControllerCubit>(context).iterations}")
            ],
          ),
        );
      },
    );
  }
}

class SystemPanel extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      alignment: Alignment.center,
      child: Column(
        children: [
          TextButton(
            child: Text("Calc centroids"),
            onPressed: () {
              BlocProvider.of<ControllerCubit>(context).calcCentroids();
            },
          ),
          TextButton(
            child: Text("Random generate points"),
            onPressed: () {
              BlocProvider.of<ControllerCubit>(context).generatePoints();
            },
          )
        ],
      ),
    );
  }
}

class KMeansPlot extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    var data = BlocProvider.of<ControllerCubit>(context).dataWithoutCentroids;

    return AspectRatio(
      aspectRatio: 1,
      child: SfCartesianChart(
        onTooltipRender: (args) {
          args.header = 'x : y';
          args.text = '${args.locationX!} : ${args.locationY!}';
        },
        tooltipBehavior: TooltipBehavior(
          enable: true,
        ),
        primaryXAxis: NumericAxis(
          visibleMinimum: BlocProvider.of<ControllerCubit>(context).xMin - 1,
          visibleMaximum: BlocProvider.of<ControllerCubit>(context).xMax + BlocProvider.of<ControllerCubit>(context).xMin + 1,
          autoScrollingDelta: 5,
        ),
        primaryYAxis: NumericAxis(
          visibleMinimum: BlocProvider.of<ControllerCubit>(context).yMin - 1,
          visibleMaximum: BlocProvider.of<ControllerCubit>(context).yMax + BlocProvider.of<ControllerCubit>(context).yMin + 1,
          autoScrollingDelta: 5,
        ),
        enableAxisAnimation: true,
        enableSideBySideSeriesPlacement: true,

        onMarkerRender: (markerArgs) {
          int v = markerArgs.pointIndex ?? -1;
          if (v != -1) {
            markerArgs.color = BlocProvider.of<ControllerCubit>(context)
                .getClusterColor(data[v]);

            if (markerArgs.seriesIndex == 1) {
              markerArgs.color = Colors.red;
              markerArgs.shape = DataMarkerType.diamond;
            }
          }
        },
        series: <ScatterSeries<Point<num>, num>>[
          ScatterSeries<Point<num>, num>(
              dataLabelSettings: const DataLabelSettings(
                showCumulativeValues: true,
              ),
              sortingOrder: SortingOrder.ascending,
              dataSource: data,
              xValueMapper: (Point<num> sales, _) => sales.x,
              yValueMapper: (Point<num> sales, _) => sales.y),
          ScatterSeries<Point<num>, num>(
              dataLabelSettings: DataLabelSettings(
                showCumulativeValues: true,
              ),
              sortingOrder: SortingOrder.ascending,
              dataSource: BlocProvider.of<ControllerCubit>(context).centroids,
              xValueMapper: (Point<num> sales, _) => sales.x,
              yValueMapper: (Point<num> sales, _) => sales.y)
        ],
      ),
    );
  }
}
