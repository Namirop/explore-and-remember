import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
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
    final List<String> imageURLList = location.getImageURLs();
    deleteImageFromFirebaseStorage(imageURLList);
    try {
      await locationsCollection.doc(location.getID).delete();
    } catch (e) {
      throw Exception(e.toString());
    }
  }

  Future<void> deleteImageFromFirebaseStorage(List<String> imageURLList) async {
    for (String imageURL in imageURLList) {
      try {
        // On extrait le nom du fichier à partir de l'URL de l'image
        Uri uri = Uri.parse(imageURL);
        // On récupère le dernier segment de l'URL
        String filePath = uri.pathSegments.last;

        Reference imageReference = FirebaseStorage.instance.ref().child(filePath);
        await imageReference.delete();

      } catch (e) {
        throw Exception(e.toString());
      }
    }
  }
}