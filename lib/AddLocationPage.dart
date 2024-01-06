import 'dart:convert';
import 'dart:io';
import 'package:explore_and_remember/blocs/LocationBloc/loc_states.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:image_picker/image_picker.dart';
import 'blocs/LocationBloc/loc_bloc.dart';
import 'blocs/LocationBloc/loc_events.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:http/http.dart' as http;

import 'blocs/SearchPlaceBloc/search_place_bloc.dart';
import 'blocs/SearchPlaceBloc/search_place_events.dart';
import 'blocs/SearchPlaceBloc/search_place_states.dart';

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
        // on crée la référence de l'image dans le storage, l'endroit où elle sera stockée
        Reference imageReference = FirebaseStorage.instance.ref().child('images/$uniqueFileName.$ext');
        // on crée un fichier à partir de l'image récupérée
        File imageFile = File(image.path);
        // on upload l'image à cette référence du storage
        await imageReference.putFile(imageFile, SettableMetadata(contentType: 'image/$ext'));
        final imageURL = await imageReference.getDownloadURL();
        setState(() {
          imageURLList.add(imageURL);
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Ajouter une location'),
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
                      focusNode: focusNode,
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.search),
                    onPressed: () {
                      BlocProvider.of<LocationSearchBloc>(context).add(SearchLocation(name.text));
                      focusNode.unfocus();
                    },
                  ),
                  BlocBuilder<LocationSearchBloc, LocationSearchState>(
                    builder: (context, state) {
                      if (state is LocationSearchLoading) {
                        return const Center(
                            child: CircularProgressIndicator()
                        );
                      } else if (state is LocationSearchIsEmpty) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text('Soyez plus précis dans votre recherche'),
                          ),
                        );
                      } else if (state is LocationSearchLoaded) {
                        latitude = state.latitude;
                        longitude = state.longitude;
                        mapController.animateCamera(CameraUpdate.newCameraPosition(
                          CameraPosition(
                            target: LatLng(latitude, longitude),
                            zoom: 10,
                          ),
                        ));
                      } else if (state is LocationSearchError) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text('Erreur lors de la recherche, veuillez réessayer'),
                          ),
                        );
                      } else if (state is LocationSearchError) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text('Erreur lors de la recherche, veuillez réessayer'),
                          ),
                        );
                      }
                      return const Text('');
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
              TextField(controller: note),
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
                    zoom: 1,
                  ),
                  markers: {
                    Marker(
                      markerId: const MarkerId("default"),
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
                  onPressed: _pickImageFromPhoneGallery,
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
          BlocProvider.of<LocationBloc>(context).add(
            AddLocation(name.text, date, note.text, imageURLList, latitude, longitude),
          );
          Navigator.pop(context);
        },
        label: const Text('Ajouter ce lieu'),
        icon: const Icon(Icons.add),
        backgroundColor: const Color(0xC3A2CDFA),
      ),
    );
  }
}
