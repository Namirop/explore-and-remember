import 'dart:ui';
import 'package:explore_and_remember/UpdateLocationPage.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'Location.dart';
import 'blocs/LocationBloc/loc_bloc.dart';
import 'blocs/LocationBloc/loc_events.dart';
import 'blocs/LocationBloc/loc_states.dart';

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
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        title: Text(name),
        actions: [
          IconButton(
            icon: const Icon(Icons.edit),
            onPressed: () async {
              bool changes = await Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => UpdateLocationPage(
                    location: location,
                  ),
                ),
              );
              if (changes) {
                // Permet de récupérer les nouvelles informations du lieu après modification sur la page de modification
                BlocProvider.of<LocationBloc>(context).add(GetLocationInformation(location.id));
              }
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
                              filter: ImageFilter.blur(sigmaX: 2, sigmaY: 2),
                              child: Image.network(
                                imageURLList[currentIndex],
                                fit: BoxFit.contain,
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
    );
  }
}