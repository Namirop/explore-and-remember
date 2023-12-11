class Location {

  final String id;
  final String name;
  final String date;
  final String note;
  final List<String> imageURLList;
  final double longitude;
  final double latitude;

  Location({
    required this.id,
    required this.name,
    required this.date,
    required this.note,
    required this.imageURLList,
    required this.longitude,
    required this.latitude,
  });

  String get getName => name;
  String get getDate => date;
  String get getNote => note;
  String get getID => id;
  List<String> getImageURLs() {
    return List.from(imageURLList);
  }
  double get getLongitude => longitude;
  double get getLatitude => latitude;

  String? getFirstImage() {
    if (imageURLList.isNotEmpty) {
      return imageURLList[0];
    } else {
      return null;
    }
  }
}