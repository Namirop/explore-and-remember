import 'dart:convert';
import 'dart:io';

import 'package:explore_and_remember/blocs/LocationBloc/loc_events.dart';
import 'package:explore_and_remember/main.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:image_picker/image_picker.dart';
import 'package:intl/intl.dart';
import 'Location.dart';
import 'blocs/LocationBloc/loc_bloc.dart';
import 'package:http/http.dart' as http;

class UpdateLocationPage extends StatefulWidget {
  final Location location;

  const UpdateLocationPage({
    Key? key,
        required this.location,
  }) : super(key: key);

  @override
  State<UpdateLocationPage> createState() => _UpdateLocationPageState();
}

class _UpdateLocationPageState extends State<UpdateLocationPage> {

  late Location location;
  late TextEditingController name;
  late DateTime date;
  late TextEditingController note;
  late TextEditingController gps = TextEditingController(text: "Fonctionnalité non implémentée");
  late String id;
  late List<String> imageURLList = [];
  late double longitude;
  late double latitude;
  late GoogleMapController mapController;
  final String apiKey = 'AIzaSyBC_9BXrQhZpwI3dWGhKiLtew1kMk1oevc';

  @override
  void initState() {
    super.initState();
    location = widget.location;
    name = TextEditingController(text: location.getName);
    note = TextEditingController(text: location.getNote);
    imageURLList = location.getImageURLs();
    id = location.getID;
    date = DateFormat("MMMM dd, yyyy").parse(location.getDate); // convertie la date String en DateTime
    longitude = location.getLongitude;
    latitude = location.getLatitude;
  }

  Future _selectDate(BuildContext context) async {
    // 'showDatePicker' retourne un pickedDate, càd la date choisit dans le calendrier
    // 'showDatePicker' est une fonction asynchrone, donc on utilise 'await'
    final DateTime? pickedDate = await showDatePicker(
      context: context,
      initialDate: date,
      firstDate: DateTime(1910),
      lastDate: DateTime(date.year + 1),
    );
    // si pickedDate n'est pas null, on met à jour la date
    if (pickedDate != null) {
      setState(() => date = pickedDate);
    }
  }


  Future<void> _searchPlaces(String query) async {
    final String apiUrl = 'https://maps.googleapis.com/maps/api/place/textsearch/json?query=$query&key=$apiKey';
    final response = await http.get(Uri.parse(apiUrl));
    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      if (data['results'].isEmpty) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Soyez plus précis dans votre recherche'),
          ),
        );
      }
      setState(() {
        setState(() {
          longitude = data['results'][0]['geometry']['location']['lng'];
          latitude = data['results'][0]['geometry']['location']['lat'];
        });
        mapController.animateCamera(CameraUpdate.newCameraPosition(
          CameraPosition(
            target: LatLng(latitude, longitude),
            zoom: 10,
          ),
        ));
      });
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Erreur lors de la recherche, veuillez réessayer'),
        ),
      );
    }
  }

  Future _pickImageFromPhoneGallery() async {
    final ImagePicker picker = ImagePicker();

    final List<XFile> pickedImagesFromGallery = await picker.pickMultiImage();

    if (pickedImagesFromGallery.isNotEmpty) {
      for (var image in pickedImagesFromGallery) {
        String uniqueFileName = DateTime.now().millisecondsSinceEpoch.toString();
        final ext = image.path.split('.').last;
        Reference imageReference = FirebaseStorage.instance.ref().child('images/$uniqueFileName.$ext');
        File imageFile = File(image.path);
        await imageReference.putFile(imageFile, SettableMetadata(contentType: 'image/$ext'));
        final imageURL = await imageReference.getDownloadURL();
        setState(() {
          imageURLList.add(imageURL);
          for (var imageURL in imageURLList) {
            print("Image URL : $imageURL");
          }
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    print("Latitude : $latitude");
    print("Longitude : $longitude");
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme
            .of(context)
            .colorScheme
            .inversePrimary,
        title: Text(location.getName),
        actions: [
          IconButton(
            icon: const Icon(Icons.delete),
            onPressed: () {
              BlocProvider.of<LocationBloc>(context).add(DeleteLocation(location));
              Navigator.pop(context);
            },
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                const Text(
                  'Nom du lieu : ',
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
                Flexible(
                  child: TextField(
                    controller: name,
                    decoration: InputDecoration(
                      hintText: location.getName,
                    ),
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.search),
                  onPressed: () {
                    _searchPlaces(name.text);
                  },
                ),
              ],
            ),
            const SizedBox(height: 16.0),
            Row(
              children: [
                const Text(
                  'Date de visite :',
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
                Container(
                  margin: const EdgeInsets.only(left: 2.0),
                  child: IconButton(
                    icon: const Icon(Icons.today),
                    onPressed: () => _selectDate(context),
                  ),
                ),
              ],
            ),
            Text(DateFormat('MMMM dd, yyyy').format(date)),
            const SizedBox(height: 16.0),
            const Text(
              'Notes : ',
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
            TextField(
                controller: note,
                decoration: InputDecoration(
                  hintText: location.getNote,
                )
            ),
            const SizedBox(height: 16.0),
            const Text(
              'Carte : ',
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16.0),
            SizedBox(
              height: 200,
              child: GoogleMap(
                  onMapCreated: (GoogleMapController controller) {
                    mapController = controller;
                  },
                  initialCameraPosition: CameraPosition(
                    target: LatLng(latitude, longitude),
                    zoom: 10,
                  ),
                  markers:
                  {
                    Marker(
                        markerId: MarkerId(name.text),
                        position: LatLng(latitude, longitude)
                    ),
                  }
              ),
            ),
            const SizedBox(height: 16.0),
            const Text(
              'Photos :',
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
            Container(
              margin: const EdgeInsets.only(top: 16.0),
              child: ElevatedButton(
                onPressed: () => _pickImageFromPhoneGallery(),
                child: const Text('Ajouter une photo'),
              ),
            ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () {
          BlocProvider.of<LocationBloc>(context).add(UpdateLocation(name.text, date, note.text, imageURLList, id, latitude, longitude));
          Navigator.pop(context, true);
        },
        label: const Text('Enregistrer les modifications'),
        icon: const Icon(Icons.update),
      ),
    );
  }
}