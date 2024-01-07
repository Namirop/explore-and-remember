abstract class PickImagesState {}

class InitialState extends PickImagesState {}

class LoadingState extends PickImagesState {}

class PickImagesLoaded extends PickImagesState {
  final List<String> imageURLList;
  PickImagesLoaded(this.imageURLList);
}

class SaveImagesLoaded extends PickImagesState {
  final String imageURL;
  SaveImagesLoaded(this.imageURL);
}

class GetImagesURLsLoaded extends PickImagesState {
  final List<String> imageURLList;
  GetImagesURLsLoaded(this.imageURLList);
}

class GetSavedImagesURLsLoaded extends PickImagesState {
  final List<String> savedImageURLList;
  GetSavedImagesURLsLoaded(this.savedImageURLList);
}

class PickImagesError extends PickImagesState {
  final String message;
  PickImagesError(this.message);
}

class SavedImagesListIsEmpty extends PickImagesState {}

class ImagesListIsEmpty extends PickImagesState {}

class ErrorState extends PickImagesState {
  final String message;
  ErrorState(this.message);
}
