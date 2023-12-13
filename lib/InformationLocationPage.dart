import 'dart:io';
import 'dart:ui';
import 'package:explore_and_remember/UpdateLocationPage.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:intl/intl.dart';
import 'Location.dart';
import 'blocs/LocationBloc/loc_bloc.dart';
import 'blocs/LocationBloc/loc_events.dart';
import 'blocs/LocationBloc/loc_states.dart';
import 'main.dart';
import 'package:http/http.dart' as http;


class InformationLocationPage extends StatefulWidget {
  final Location location;

  const InformationLocationPage({
    Key? key,
        required this.location,
  }) : super(key: key);

  @override
  State<InformationLocationPage> createState() => _InformationLocationPageState();
}

class _InformationLocationPageState extends State<InformationLocationPage> {

  late Location location;
  late List<String> imageURLList;
  late GoogleMapController mapController;
  late double latitude;
  late double longitude;
  late String name;
  late String note;
  late DateTime date;
  late int currentIndex = 0;


  @override
  void initState() {
    super.initState();
    location = widget.location;
    imageURLList = location.getImageURLs();
    latitude = location.getLatitude;
    longitude = location.getLongitude;
    name = location.getName;
    note = location.getNote;
    date = DateFormat("MMMM dd, yyyy").parse(location.getDate);
    BlocProvider.of<LocationBloc>(context).add(GetLocationInformation(location.id));
  }

  Future<void> _saveImage(String imageURL) async {

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
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        title: Text(name),
        automaticallyImplyLeading: false,
        actions: [
          IconButton(
            icon: const Icon(Icons.edit),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => UpdateLocationPage(
                    location: location,
                  ),
                ),
              );
            },
          ),
        ],
      ),
      body: BlocBuilder<LocationBloc, LocationState>(
        builder: (context, state) {
          if (state is LocationLoading) {
            return const Center(
              child: CircularProgressIndicator(),
            );
          } else if (state is LocationLoaded) {
            location = state.location;
            imageURLList = location.getImageURLs();
            latitude = location.getLatitude;
            longitude = location.getLongitude;
            name = location.getName;
            note = location.getNote;
            date = DateFormat("MMMM dd, yyyy").parse(location.getDate);
          }
          return SingleChildScrollView(
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Photos : ',
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 16.0),
                  GestureDetector(
                    onTap: () {
                      showDialog(
                        context: context,
                        builder: (BuildContext context) {
                          return Dialog(
                            child: BackdropFilter(
                              filter: ImageFilter.blur(sigmaX: 1, sigmaY: 1),
                              child: Column(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Image.network(
                                    imageURLList[currentIndex],
                                    fit: BoxFit.contain,
                                  ),
                                  const SizedBox(height: 16.0),
                                  Row(
                                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                                    children: [
                                      IconButton(
                                        icon: const Icon(Icons.save),
                                        onPressed: () {
                                          final imageURL = imageURLList[currentIndex];
                                          _saveImage(imageURL);
                                          Navigator.pop(context);
                                        },
                                      ),
                                      IconButton(
                                        icon: const Icon(Icons.delete),
                                        onPressed: () {
                                          final imageURL = imageURLList[currentIndex];
                                          final idLocation = location.getID;
                                          BlocProvider.of<LocationBloc>(context).add(DeleteImageFromFirebaseStorageAndDB(imageURL, imageURLList, idLocation));
                                          Navigator.pop(context);
                                        },
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                            ),
                          );
                        },
                      );
                    },
                    child: SizedBox(
                      height: 200,
                      child: PageView.builder(
                        itemCount: imageURLList.length,
                        // dès que l'on change de photo, le nouvel index devient le courant
                        onPageChanged: (index) {
                          setState(() {
                            currentIndex = index;
                          });
                        },
                        itemBuilder: (context, index) {
                          return Image.network(
                            imageURLList[index],
                            fit: BoxFit.cover,
                          );
                        },
                      ),
                    ),
                  ),
                  const SizedBox(height: 16.0),
                  const Text(
                    'Notes : ',
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 16.0),
                  Text(note),
                  const SizedBox(height: 16.0),
                  const Text(
                    'Date de visite : ',
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 16.0),
                  Text('${date.day}/${date.month}/${date.year}'),
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
                        zoom: 12,
                      ),
                      markers: {
                        Marker(
                          markerId: MarkerId(name),
                          position: LatLng(latitude, longitude),
                        ),
                      },
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => const MyHomePage(
                title: 'Explorer and Remember',
              ),
            ),
          );
        },
        label: const Text('Retour'),
        icon: const Icon(Icons.arrow_back),
      ),
    );
  }
}