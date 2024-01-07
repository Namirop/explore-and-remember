import 'package:explore_and_remember/UpdateLocationPage.dart';
import 'package:explore_and_remember/blocs/ImagesBloc/images_bloc.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:intl/intl.dart';
import 'Location.dart';
import 'blocs/LocationBloc/loc_bloc.dart';
import 'blocs/LocationBloc/loc_events.dart';
import 'blocs/LocationBloc/loc_states.dart';
import 'blocs/ImagesBloc/images_events.dart';
import 'main.dart';


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
        toolbarHeight: 1,
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
              padding: const EdgeInsets.all(0.0),
              child: Column(
                children: [
                  GestureDetector(
                    onTap: () {
                      showDialog(
                        context: context,
                        builder: (BuildContext context) {
                          return Dialog(
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(10.0),
                            ),
                            backgroundColor: const Color(0xA2CDFAFF),
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
                                        BlocProvider.of<ImagesBloc>(context).add(SaveImages(imageURL));
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
                          );
                        },
                      );
                    },
                    child: SizedBox(
                      height: 200,
                      child: PageView.builder(
                        itemCount: imageURLList.length,
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

                  Container(
                    padding: const EdgeInsets.all(8.0),
                    margin: const EdgeInsets.all(12.0),
                    decoration: BoxDecoration(
                      border: Border.all(color: Colors.grey.shade300),
                      borderRadius: BorderRadius.circular(10.0),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.grey.shade400.withOpacity(0.25),
                          spreadRadius: 2,
                          blurRadius: 5,
                        ),
                      ],
                    ),
                    child: Row(
                      children: [
                        const Padding(
                          padding: EdgeInsets.only(right: 16.0),
                          child: Icon(
                            Icons.location_on,
                            size: 45,
                            color: Colors.blue,
                          ),
                        ),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              name,
                              style: const TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 20.0,
                              ),
                            ),
                            const SizedBox(height: 4.0),
                            Text(
                              '${date.day}/${date.month}/${date.year}',
                              style: const TextStyle(
                                fontSize: 14.0,
                                color: Colors.grey,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),

                  Container(
                    padding: const EdgeInsets.symmetric(vertical: 8.0),
                    margin: const EdgeInsets.symmetric(horizontal: 16.0),
                    child: const Row(
                      children: [
                        Padding(
                          padding: EdgeInsets.only(right: 16.0),
                          child: Icon(
                            Icons.notes,
                            size: 45,
                            color: Colors.blue,
                          ),
                        ),
                        Text(
                          'NOTES : ',
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 18.0,
                          ),
                        ),
                      ],
                    ),
                  ),

                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(8.0),
                    margin: const EdgeInsets.all(12.0),
                    decoration: BoxDecoration(
                      border: Border.all(color: Colors.grey.shade300),
                      borderRadius: BorderRadius.circular(10.0),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.grey.shade400.withOpacity(0.25),
                          spreadRadius: 2,
                          blurRadius: 5,
                        ),
                      ],
                    ),
                    child: Text(
                      note,
                      style: const TextStyle(
                        fontSize: 16.0,
                      ),
                    ),
                  ),

                  Container(
                    padding: const EdgeInsets.symmetric(vertical: 8.0),
                    margin: const EdgeInsets.symmetric(horizontal: 16.0),
                    child: const Row(
                      children: [
                        Padding(
                          padding: EdgeInsets.only(right: 16.0),
                          child: Icon(
                            Icons.map,
                            size: 40,
                            color: Colors.blue,
                          ),
                        ),
                        Text(
                          'CARTES : ',
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 18.0,
                          ),
                        ),
                      ],
                    ),
                  ),

                  Container(
                    margin: const EdgeInsets.all(14.0),
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
                      key: ValueKey(location),
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

                  Container(
                    margin: const EdgeInsets.all(8.0),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        FloatingActionButton.extended(
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
                          label: const Text(''),
                          icon: const Icon(Icons.arrow_back),
                          heroTag: 'backButton',
                          backgroundColor: const Color(0xC3A2CDFA),
                        ),
                        const SizedBox(width: 16.0),
                        FloatingActionButton.extended(
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
                          label: const Text('MODIFIER CE LIEU'),
                          icon: const Icon(Icons.edit),
                          heroTag: 'editButton',
                          backgroundColor: const Color(0xC3A2CDFA),
                        ),
                      ],
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