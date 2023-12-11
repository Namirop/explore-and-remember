class Location {

  final String id;
  final String name;
  final String date;
  final String note;
  final List<String> imageURLList;

  Location({
    required this.id,
    required this.name,
    required this.date,
    required this.note,
    required this.imageURLList,
  });

  set setName(String name) => name = name;
  set setDate(String date) => date = date;
  set setNote (String note) => note = note;
  set setImageURLList(List<String> imageURLList) {
    this.imageURLList.clear();
    this.imageURLList.addAll(imageURLList);
  }

  String get getName => name;
  String get getDate => date;
  String get getNote => note;
  String get getID => id;
  List<String> getImageURLs() {
    return List.from(imageURLList);
  }

  String? getFirstImageURL() {
    if (imageURLList.isNotEmpty) {
      return imageURLList[0];
    } else {
      return null;
    }
  }
}