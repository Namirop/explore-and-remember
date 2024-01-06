abstract class LocationSearchState {}

class LocationSearchInitial extends LocationSearchState {}

class LocationSearchLoading extends LocationSearchState {}

class LocationSearchLoaded extends LocationSearchState {
  final double latitude;
  final double longitude;
  LocationSearchLoaded(this.latitude, this.longitude);
}

class LocationSearchError extends LocationSearchState {
  final String message;
  LocationSearchError(this.message);
}

class LocationSearchIsEmpty extends LocationSearchState {}