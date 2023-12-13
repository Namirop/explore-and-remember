class Location {

  final String id;
  final String name;
  final String date;
  final String note;
  final List<String> imageURLList;
  final double latitude;
  final double longitude;

  Location({
    required this.id,
    required this.name,
    required this.date,
    required this.note,
    required this.imageURLList,
    required this.latitude,
    required this.longitude,
  });

  String get getName => name;
  String get getDate => date;
  String get getNote => note;
  String get getID => id;
  double get getLongitude => longitude;
  double get getLatitude => latitude;
  List<String> getImageURLs() {
    return List.from(imageURLList);
  }

  String? getFirstImage() {
    if (imageURLList.isNotEmpty) {
      return imageURLList[0];
    } else {
      return null;
    }
  }
}