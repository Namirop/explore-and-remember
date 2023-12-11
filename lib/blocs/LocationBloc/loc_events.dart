import '../../Location.dart';

// ces events seront appelés dans la main, quand on fera un 'add' + le nom de l'event au bloc
abstract class LocationEvent {}

class GetLocations extends LocationEvent {}

class AddLocation extends LocationEvent {
  final String name;
  final DateTime date;
  final String note;
  final List<String> imageURLList;
  AddLocation(this.name, this.date, this.note, this.imageURLList);
}

class UpdateLocation extends LocationEvent {
  final String name;
  final DateTime date;
  final String note;
  final List<String> imageURLList;
  final String id;
  UpdateLocation(this.name, this.date, this.note, this.imageURLList, this.id);
}

class DeleteLocation extends LocationEvent {
  final Location location;
  DeleteLocation(this.location);
}

class GetLocationName extends LocationEvent {
  final String locationName;
  GetLocationName(this.locationName);
}