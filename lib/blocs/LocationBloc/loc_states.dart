import '../../Location.dart';

abstract class LocationState {}

class LocationInitial extends LocationState {}

class LocationLoading extends LocationState {}

class LocationsLoaded extends LocationState {
  final List<Location> locations;
  LocationsLoaded(this.locations);
}

class LocationLoaded extends LocationState {
  final Location location;
  LocationLoaded(this.location);
}

class LocationError extends LocationState {
  final String message;
  LocationError(this.message);
}