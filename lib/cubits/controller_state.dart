part of 'controller_cubit.dart';

@immutable
abstract class ControllerState {}

class ControllerInitial extends ControllerState {}

class ControllerGeneratePoints extends ControllerState {}

class ControllerCalcCentroids extends ControllerState {}
