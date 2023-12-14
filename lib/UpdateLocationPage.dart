import 'dart:convert';
import 'dart:io';

import 'package:explore_and_remember/InformationLocationPage.dart';
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
    date = DateFormat("MMMM dd, yyyy").parse(location.getDate);
    longitude = location.getLongitude;
    latitude = location.getLatitude;

  }

  Future _selectDate(BuildContext context) async {
    // 'showDatePicker' retourne un pickedDate, càd la date choisit dans le calendrier
    final DateTime? pickedDate = await showDatePicker(
      context: context,
      initialDate: date,
      firstDate: DateTime(1910),
      lastDate: DateTime(date.year + 1),
      builder: (BuildContext context, Widget? child) {
        return Theme(
          data: ThemeData.light().copyWith(
            primaryColor: Colors.blue, // Change la couleur du sélecteur
            hintColor: Colors.blue, // Change la couleur des boutons OK et Annuler
            colorScheme: const ColorScheme.light(primary: Colors.blue),
            buttonTheme: const ButtonThemeData(textTheme: ButtonTextTheme.primary),
          ),
          child: child!,
        );
      },
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
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        flexibleSpace: Container(
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [
                Color(0xC3A2CDFA),
                Color(0xC30B6A85),
              ],
            ),
          ),
        ),
        title: Text(
          location.getName.toUpperCase(),
          style: const TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 20.0,
          ),
        ),
        actions: [
          IconButton(
            icon: const Icon(
              Icons.delete_sharp,
              size: 35,
            ),
            onPressed: () {
              BlocProvider.of<LocationBloc>(context).add(DeleteLocation(location));
              BlocProvider.of<LocationBloc>(context).add(DeleteImagesFromFirebaseStorage(imageURLList));
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => const MyHomePage(
                    title: 'Explorer and Remember',
                  ),
                ),
              );
            },
          ),
        ],
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  const Text(
                    'Nom du lieu : ',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 18.0,
                    ),
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
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 18.0,
                    ),
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
              Text('${date.day}/${date.month}/${date.year}'),
              const SizedBox(height: 16.0),
              const Text(
                'Notes : ',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 18.0,
                ),
              ),
              TextField(
                controller: note,
                decoration: InputDecoration(
                  hintText: location.getNote,
                ),
              ),
              const SizedBox(height: 16.0),
              const Text(
                'Carte : ',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 18.0,
                ),
              ),
              const SizedBox(height: 16.0),
              Container(
                margin: const EdgeInsets.symmetric(vertical: 8.0),
                height: 250,
                decoration: const BoxDecoration(
                  boxShadow: [
                    BoxShadow(
                      color: Colors.grey,
                      blurRadius: 5.0,
                      offset: Offset(2, 6),
                    ),
                  ],
                ),
                child: GoogleMap(
                  onMapCreated: (GoogleMapController controller) {
                    mapController = controller;
                  },
                  initialCameraPosition: CameraPosition(
                    target: LatLng(latitude, longitude),
                    zoom: 12,
                  ),
                  markers: {
                    Marker(
                      markerId: MarkerId(location.getName),
                      position: LatLng(latitude, longitude),
                    ),
                  },
                ),
              ),
              const SizedBox(height: 16.0),
              const Text(
                'Photos :',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 18.0,
                ),
              ),
              Container(
                margin: const EdgeInsets.only(top: 16.0),
                child: ElevatedButton(
                  onPressed: () => _pickImageFromPhoneGallery(),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xC3A2CDFA),
                  ),
                  child: const Text(
                      'Ajouter une photo',
                    style: TextStyle(
                      color: Colors.black,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () {
          BlocProvider.of<LocationBloc>(context).add(UpdateLocation(name.text, date, note.text, imageURLList, id, latitude, longitude));
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => InformationLocationPage(
                location: location,
              ),
            ),
          );
        },
        label: const Text('Enregistrer les modifications'),
        icon: const Icon(Icons.update),
        backgroundColor: const Color(0xC3A2CDFA),
      ),
    );
  }
}