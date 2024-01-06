abstract class LocationSearchEvent {}

class SearchLocation extends LocationSearchEvent {
  final String locationQuery;
  SearchLocation(this.locationQuery);
}

