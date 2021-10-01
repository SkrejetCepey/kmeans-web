part of 'controller_cubit.dart';

@immutable
abstract class ControllerState {}

class ControllerInitial extends ControllerState {}

class ControllerGeneratePoints extends ControllerState {}

class ControllerCalcCentroids extends ControllerState {}

class ControllerChangePointsCount extends ControllerState {}

class ControllerChangeCentroidsCount extends ControllerState {}

class ControllerChangeXMin extends ControllerState {}
class ControllerChangeXMax extends ControllerState {}
class ControllerChangeYMin extends ControllerState {}
class ControllerChangeYMax extends ControllerState {}