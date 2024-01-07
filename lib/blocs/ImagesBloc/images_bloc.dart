import 'package:explore_and_remember/blocs/ImagesBloc/images_events.dart';
import 'package:explore_and_remember/blocs/ImagesBloc/images_states.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';
import 'package:http/http.dart' as http;

class ImagesBloc extends Bloc<PickImagesEvent, PickImagesState> {
  ImagesBloc() : super(InitialState()) {
    on<PickImages>((event, emit) async {
      emit(LoadingState());
      try {
        final List<String> imageURLList = event.imageURLList;
        final ImagePicker picker = ImagePicker();
        final List<XFile> pickedImagesFromGallery = await picker.pickMultiImage();

        if (pickedImagesFromGallery.isNotEmpty) {
          for (var image in pickedImagesFromGallery) {
            String uniqueFileName = DateTime.now().millisecondsSinceEpoch.toString();
            final ext = image.path.split('.').last;
            // on crée la référence de l'image dans le storage, l'endroit où elle sera stockée
            Reference imageReference = FirebaseStorage.instance.ref().child('images/$uniqueFileName.$ext');
            // on crée un fichier à partir de l'image récupérée
            File imageFile = File(image.path);
            // on upload l'image à cette référence du storage
            await imageReference.putFile(imageFile, SettableMetadata(contentType: 'image/$ext'));
            final imageURL = await imageReference.getDownloadURL();
            imageURLList.add(imageURL);
          }
        }
        emit(PickImagesLoaded(imageURLList));
      } catch (e) {
        emit(ErrorState('Erreur lors de la récupération des images : $e'));
      }
    });

    on<SaveImages>((event, emit) async {
      emit(LoadingState());
      try {
        final String imageURL = event.imageURL;
        // On télécharge le fichier de l'image à partir de son URL
        final response = await http.get(Uri.parse(imageURL));
        // On récupère les bytes de l'image
        final bytes = response.bodyBytes;

        // On récupère le nom unique de l'image
        final uniqueFileName = imageURL.split('/').last;

        // On récupère l'extension
        final ext = uniqueFileName.split('.').last;

        // On crée une référence à l'emplacement où l'image sera sauvegardée
        Reference imageSavedReference = FirebaseStorage.instance.ref().child('saved/$uniqueFileName.$ext');

        // On sauvegarde l'image
        await imageSavedReference.putData(bytes, SettableMetadata(contentType: 'image/$ext'));
        emit(SaveImagesLoaded(imageURL));
      } catch (e) {
        emit(ErrorState('Erreur lors de la récupération des images : $e'));
      }
    });

    on<GetImagesURLs>((event, emit) async {
      emit(LoadingState());
      try {
        final List<String> allImagesURLList = [];
        // On récupère la liste des noms de tous les fichiers du dossier images
        final ListResult result = await FirebaseStorage.instance.ref().child('images').listAll();
        // On récupère les URLs de toutes les images
        for (var ref in result.items) {
          final imageURL = await ref.getDownloadURL();
          allImagesURLList.add(imageURL);
        }

        if (allImagesURLList.isEmpty) {
          emit(ImagesListIsEmpty());
        }
        emit(GetImagesURLsLoaded(allImagesURLList));
      } catch (e) {
        emit(ErrorState('Erreur lors de la récupération des images : $e'));
      }
    });

    on<GetSavedImagesURLs>((event, emit) async {
      emit(LoadingState());
      try {
        final List<String> allSavedImagesURLList = [];
        // On récupère la liste des noms de tous les fichiers du dossier saved
        final ListResult result = await FirebaseStorage.instance.ref().child('saved').listAll();
        // On récupère les URLs de toutes les images
        for (var ref in result.items) {
          final imageURL = await ref.getDownloadURL();
          allSavedImagesURLList.add(imageURL);
        }

        if (allSavedImagesURLList.isEmpty) {
          emit(SavedImagesListIsEmpty());
        }
        emit(GetSavedImagesURLsLoaded(allSavedImagesURLList));
      } catch (e) {
        emit(ErrorState('Erreur lors de la récupération des images : $e'));
      }
    });

  }
}