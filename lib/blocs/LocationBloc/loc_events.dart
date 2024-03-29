import '../../Location.dart';

// ces events seront appelés dans la main, quand on fera un 'add' + le nom de l'event au bloc
abstract class LocationEvent {}

class GetLocations extends LocationEvent {}

class AddLocation extends LocationEvent {
  final String name;
  final DateTime date;
  final String note;
  final List<String> imageURLList;
  final double latitude;
  final double longitude;

  AddLocation(this.name, this.date, this.note, this.imageURLList, this.latitude, this.longitude);
}

class UpdateLocation extends LocationEvent {
  final String name;
  final DateTime date;
  final String note;
  final List<String> imageURLList;
  final String id;
  final double latitude;
  final double longitude;

  UpdateLocation(this.name, this.date, this.note, this.imageURLList, this.id, this.latitude, this.longitude);
}

class DeleteLocation extends LocationEvent {
  final Location location;
  final List<String> imageURLList;
  DeleteLocation(this.location, this.imageURLList);
}

class DeleteImageFromFirebaseStorageAndDB extends LocationEvent {
  final String imageURL;
  final List<String> imageURLList;
  final String idLocation;
  DeleteImageFromFirebaseStorageAndDB(this.imageURL, this.imageURLList, this.idLocation);
}

class GetLocationInformation extends LocationEvent {
  final String locationId;
  GetLocationInformation(this.locationId);
}