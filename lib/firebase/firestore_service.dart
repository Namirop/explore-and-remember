import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:intl/intl.dart';
import '../Location.dart';

class FirestoreService {

  final locationsCollection = FirebaseFirestore.instance.collection("Locations");

  Stream<List<Location>> getLocations() {
    try {
      return locationsCollection.snapshots().map((snapshot) {
        return snapshot.docs.map((doc) {
          final data = doc.data();
          return Location(
            id: doc.id,
            name: data['Name'],
            date: data['Date'],
            note: data['Note'],
            imageURLList: List<String>.from(data['ImageURLs']), // convertie la liste dynamique en liste de String
            latitude: data['Latitude'],
            longitude: data['Longitude'],
          );
        }).toList();
      });
    } catch (e) {
      throw Exception(e.toString());
    }
  }

  Future<void> addLocation(String name, DateTime date, String note, List<String> imageURLList, double latitude, double longitude) async {
    String dateStringFormat = DateFormat("MMMM dd, yyyy").format(date);
    try {
      await locationsCollection.add({
        'Name': name,
        'Date': dateStringFormat,
        'Note': note,
        'ImageURLs': imageURLList,
        'Latitude': latitude,
        'Longitude': longitude,
      });
    } catch (e) {
      throw Exception(e.toString());
    }
  }

  Future<void> updateLocation(String name, DateTime date, String note, List<String> imageURLList, String id, double latitude, double longitude) async {
    String dateStringFormat = DateFormat("MMMM dd, yyyy").format(date);
    try {
      await locationsCollection.doc(id).update({
        'Name': name,
        'Date': dateStringFormat,
        'Note': note,
        'ImageURLs': imageURLList,
        'Latitude': latitude,
        'Longitude': longitude,
      });
    } catch (e) {
      throw Exception(e.toString());
    }
  }

  Future<void> deleteLocation(Location location) async {
    try {
      await locationsCollection.doc(location.getID).delete();
    } catch (e) {
      throw Exception(e.toString());
    }
  }

  Future<void> deleteImagesFromFirebaseStorage(List<String> imageURLList) async {
    for (String imageURL in imageURLList) {
      try {
        // On extrait le nom du fichier à partir de l'URL de l'image
        Uri uri = Uri.parse(imageURL);
        // On récupère le dernier segment de l'URL
        String filePath = uri.pathSegments.last;

        List<String> firstSegment = filePath.split('/');
        String uniqueFileNameAndExtension = firstSegment.last;
        List<String> secondSegment = uniqueFileNameAndExtension.split('.');
        String uniqueFileName = secondSegment.first;

        Reference savedImageReference = FirebaseStorage.instance.ref().child('saved');
        ListResult savedImagesList = await savedImageReference.listAll();
        for (var image in savedImagesList.items) {
          if (image.name.contains(uniqueFileName)) {
            await image.delete();
          }
        }

        Reference imageReference = FirebaseStorage.instance.ref().child(filePath);
        await imageReference.delete();

      } catch (e) {
        throw Exception(e.toString());
      }
    }
  }

  Future<void> deleteImageFromFirebaseStorageAndDB(String imageURL, List<String> imageURLList, String idLocation) async {
    try {
      Uri uri = Uri.parse(imageURL);
      String filePath = uri.pathSegments.last;
      List<String> firstSegment = filePath.split('/');
      String uniqueFileNameAndExtension = firstSegment.last;
      List<String> secondSegment = uniqueFileNameAndExtension.split('.');
      // On récupère le nom unique que l'on a attribué à l'image
      String uniqueFileName = secondSegment.first;

      // On supprime l'image du dossier 'saved' si elle y est
      Reference savedImageReference = FirebaseStorage.instance.ref().child('saved');
      ListResult savedImagesList = await savedImageReference.listAll();
      for (var image in savedImagesList.items) {
        if (image.name.contains(uniqueFileName)) {
          await image.delete();
        }
      }

      // On supprime l'image du dossier 'images'
      Reference imageReference = FirebaseStorage.instance.ref().child(filePath);
      await imageReference.delete();

      // On supprime l'image de la liste des images de la base de données
      imageURLList.remove(imageURL);

      // On met à jour la base de données
      await locationsCollection.doc(idLocation).update({
        'ImageURLs': imageURLList,
      });

    } catch (e) {
      throw Exception(e.toString());
    }
  }


  getLocationInformation(String locationId) {
    try {
      return locationsCollection.doc(locationId).get().then((doc) {
        final data = doc.data();
        return Location(
          id: doc.id,
          name: data!['Name'],
          date: data['Date'],
          note: data['Note'],
          imageURLList: List<String>.from(data['ImageURLs']), // convertie la liste dynamique en liste de String
          latitude: data['Latitude'],
          longitude: data['Longitude'],
        );
      });
    } catch (e) {
      throw Exception(e.toString());
    }
  }
}