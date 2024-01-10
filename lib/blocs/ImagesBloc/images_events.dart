abstract class PickImagesEvent {}

class PickImages extends PickImagesEvent {
  PickImages();
}

class UpdateImages extends PickImagesEvent {
  final List<String> imageURLList;
  UpdateImages(this.imageURLList);
}

class SaveImages extends PickImagesEvent {
  final String imageURL;
  SaveImages(this.imageURL);
}

class GetImagesURLs extends PickImagesEvent {}

class GetSavedImagesURLs extends PickImagesEvent {}