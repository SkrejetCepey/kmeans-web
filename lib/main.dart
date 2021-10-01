import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:syncfusion_flutter_charts/charts.dart';
import 'package:untitled3/cubits/controller_cubit.dart';
import 'package:untitled3/cubits/system_settings_cubit.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider(create: (context) => ControllerCubit()),
        BlocProvider(create: (context) => SystemSettingsCubit()),
      ],
      child: BlocBuilder<SystemSettingsCubit, SystemSettingsState>(
        builder: (context, state) {
          return MApp();
        },
      ),
    );
  }
}

class MApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      theme: ThemeData(
        brightness: Brightness.light,
      ),
      darkTheme: ThemeData(
        brightness: Brightness.dark,
      ),
      themeMode: BlocProvider.of<SystemSettingsCubit>(context).getThemeData,
      debugShowCheckedModeBanner: false,
      home: HomePage(),
    );
  }
}

class HomePage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(children: [
        Text("KMeans"),
        Row(
          children: [
            Expanded(child: BlocBuilder<ControllerCubit, ControllerState>(
              builder: (context, state) {
                return KMeansPlot();
              },
            )),
            Expanded(
              child:
                  Column(mainAxisAlignment: MainAxisAlignment.start, children: [
                SystemSettingsPanel(),
                SizedBox(height: 50.0),
                PlotSystemPanel(),
              ]),
            ),
          ],
        ),
        Row(
          children: [
            Expanded(child: StatusesPanel()),
          ],
        )
      ]),
    );
  }
}

class SystemSettingsPanel extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return BlocBuilder<SystemSettingsCubit, SystemSettingsState>(
      builder: (context, state) {
        return Container(
          child: Column(
            children: [
              Text("SystemSettings"),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text("Night"),
                  Switch(
                    value: BlocProvider.of<SystemSettingsCubit>(context)
                        .themeState,
                    onChanged: (b) {
                      BlocProvider.of<SystemSettingsCubit>(context)
                          .swapThemeState();
                    },
                  ),
                  Text("Day")
                ],
              ),
            ],
          ),
        );
      },
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
              Text(
                  "Iterations: ${BlocProvider.of<ControllerCubit>(context).iterations}")
            ],
          ),
        );
      },
    );
  }
}

class PlotSystemPanel extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    var controllerCubit = BlocProvider.of<ControllerCubit>(context);

    return BlocBuilder<ControllerCubit, ControllerState>(
      builder: (context, state) {
        return Container(
          alignment: Alignment.center,
          child: Column(
            children: [
              Text("PlotSettings"),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text("PointsCount"),
                  Slider(
                    min: 3,
                    max: 100,
                    divisions: 100,
                    label: controllerCubit.pointsCount.toString(),
                    value: controllerCubit.pointsCount.toDouble(),
                    onChanged: (v) {
                      controllerCubit.changePointsCount(v.toInt());
                    },
                  ),
                ],
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text("CentroidsCount"),
                  Slider(
                    min: 1,
                    max: 10,
                    divisions: 10,
                    label: controllerCubit.countCentroids.toString(),
                    value: controllerCubit.countCentroids.toDouble(),
                    onChanged: (v) {
                      controllerCubit.changeCentroidsCount(v.toInt());
                    },
                  ),
                ],
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Column(
                    children: [
                      Row(
                        children: [
                          Text("x"),
                          RangeSlider(
                            onChanged: (v) {
                              if (v.start != controllerCubit.xMin) {
                                controllerCubit.xMin = v.start;
                              }
                              if (v.end != controllerCubit.xMax) {
                                controllerCubit.xMax = v.end;
                              }
                            },
                            min: -10.0,
                            max: 10.0,
                            values: RangeValues(
                                controllerCubit.xMin, controllerCubit.xMax),
                            divisions: 20,
                            labels: RangeLabels(controllerCubit.xMin.toString(),
                                controllerCubit.xMax.toString()),
                          )
                        ],
                      ),
                      Row(
                        children: [
                          Text("y"),
                          RangeSlider(
                            onChanged: (v) {
                              if (v.start != controllerCubit.yMin) {
                                controllerCubit.yMin = v.start;
                              }
                              if (v.end != controllerCubit.yMax) {
                                controllerCubit.yMax = v.end;
                              }
                            },
                            min: -10.0,
                            max: 10.0,
                            values: RangeValues(
                                controllerCubit.yMin, controllerCubit.yMax),
                            divisions: 20,
                            labels: RangeLabels(controllerCubit.yMin.toString(),
                                controllerCubit.yMax.toString()),
                          )
                        ],
                      ),
                    ],
                  ),
                ],
              ),
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
      },
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
          // args.text = '${args.dataPoints[args.pointIndex.toInt()].x} : ${args.locationY!}';
        },
        tooltipBehavior: TooltipBehavior(
          enable: true,
        ),
        primaryXAxis: NumericAxis(
          visibleMinimum: BlocProvider.of<ControllerCubit>(context).xMin - 1,
          visibleMaximum: BlocProvider.of<ControllerCubit>(context).xMax + 1,
          autoScrollingDelta: 5,
        ),
        primaryYAxis: NumericAxis(
          visibleMinimum: BlocProvider.of<ControllerCubit>(context).yMin - 1,
          visibleMaximum: BlocProvider.of<ControllerCubit>(context).yMax + 1,
          autoScrollingDelta: 5,
        ),
        enableAxisAnimation: true,
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
              dataLabelSettings: const DataLabelSettings(
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
