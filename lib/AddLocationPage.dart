import 'dart:convert';
import 'dart:io';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:image_picker/image_picker.dart';
import 'blocs/LocationBloc/loc_bloc.dart';
import 'blocs/LocationBloc/loc_events.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:http/http.dart' as http;

class AddLocationPage extends StatefulWidget {
  const AddLocationPage({Key? key}) : super(key: key);

  @override
  State<AddLocationPage> createState() => _AddLocationPageState();
}

class _AddLocationPageState extends State<AddLocationPage> {

  final TextEditingController name = TextEditingController();
  final TextEditingController note = TextEditingController();
  final String apiKey = 'AIzaSyBC_9BXrQhZpwI3dWGhKiLtew1kMk1oevc';
  final FocusNode focusNode = FocusNode();

  late DateTime date = DateTime.now();
  late List<String> imageURLList = [];
  late GoogleMapController mapController;
  late double latitude = 0.0;
  late double longitude = 0.0;

  Future _selectDate(BuildContext context) async {
    final DateTime? pickedDate = await showDatePicker(
      context: context,
      initialDate: date,
      firstDate: DateTime(1910),
      lastDate: DateTime(date.year + 1),
    );
    if (pickedDate != null) {
      setState(() => date = pickedDate);
    }
  }

  Future _pickImageFromPhoneGallery() async {
    final ImagePicker picker = ImagePicker();

    final List<XFile> pickedImagesFromGallery = await picker.pickMultiImage();

    if (pickedImagesFromGallery.isNotEmpty) {
      for (var image in pickedImagesFromGallery) {
        String uniqueFileName = DateTime.now().millisecondsSinceEpoch.toString();
        final ext = image.path.split('.').last;
        Reference imageReference =
        FirebaseStorage.instance.ref().child('images/$uniqueFileName.$ext');
        File imageFile = File(image.path);
        await imageReference.putFile(imageFile, SettableMetadata(contentType: 'image/$ext'));
        final imageURL = await imageReference.getDownloadURL();
        setState(() {
          imageURLList.add(imageURL);
        });
      }
    }
  }

  Future<void> _searchPlaces(String locationQuery) async {
    final String apiUrl = 'https://maps.googleapis.com/maps/api/place/textsearch/json?query=$locationQuery&key=$apiKey';
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
        latitude = data['results'][0]['geometry']['location']['lat'];
        longitude = data['results'][0]['geometry']['location']['lng'];
      });

      setState(() {
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Ajouter une location'),
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
                      focusNode: focusNode
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.search),
                  onPressed: () {
                    final locationQuery = name.text;
                    _searchPlaces(locationQuery);
                    focusNode.unfocus();
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
            Text('${date.day}/${date.month}/${date.year}'),
            const SizedBox(height: 16.0),
            const Text(
              'Notes : ',
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
            TextField(controller: note),
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
                  zoom: 1,
                ),
                markers: {
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
                onPressed: _pickImageFromPhoneGallery,
                child: const Text('Ajouter une photo'),
              ),
            ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () {
          BlocProvider.of<LocationBloc>(context).add(
            AddLocation(name.text, date, note.text, imageURLList, latitude, longitude),
          );
          Navigator.pop(context);
        },
        label: const Text('Ajouter ce lieu'),
        icon: const Icon(Icons.add),
      ),
    );
  }
}
