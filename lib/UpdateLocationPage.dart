import 'package:explore_and_remember/InformationLocationPage.dart';
import 'package:explore_and_remember/blocs/LocationBloc/loc_events.dart';
import 'package:explore_and_remember/main.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:intl/intl.dart';
import 'Location.dart';
import 'blocs/LocationBloc/loc_bloc.dart';
import 'blocs/ImagesBloc/images_bloc.dart';
import 'blocs/ImagesBloc/images_events.dart';
import 'blocs/ImagesBloc/images_states.dart';
import 'blocs/SearchPlaceBloc/search_place_bloc.dart';
import 'blocs/SearchPlaceBloc/search_place_events.dart';
import 'blocs/SearchPlaceBloc/search_place_states.dart';

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
  late TextEditingController note;
  late DateTime date;
  late String id;
  late List<String> imageURLList;
  late double longitude;
  late double latitude;
  late GoogleMapController? mapController;


  @override
  void initState() {
    super.initState();
    location = widget.location;
    name = TextEditingController(text: location.getName);
    note = TextEditingController(text: location.getNote);
    id = location.getID;
    imageURLList = location.getImageURLs();
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

              BlocProvider.of<LocationBloc>(context).add(DeleteLocation(location, imageURLList));
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
                  Expanded(
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
                      BlocProvider.of<LocationSearchBloc>(context).add(SearchLocation(name.text));
                    },
                  ),
                  BlocBuilder<LocationSearchBloc, LocationSearchState>(
                    builder: (context, state) {
                      if (state is LocationSearchLoading) {
                        return const Center(
                            child: CircularProgressIndicator()
                        );
                      } else if (state is LocationSearchIsEmpty) {
                        WidgetsBinding.instance.addPostFrameCallback((_) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content: Text('Soyez plus précis dans votre recherche'),
                            ),
                          );
                        });
                      } else if (state is LocationSearchLoaded) {
                        latitude = state.latitude;
                        longitude = state.longitude;
                        mapController?.animateCamera(CameraUpdate.newCameraPosition(
                          CameraPosition(
                            target: LatLng(latitude, longitude),
                            zoom: 10,
                          ),
                        ));
                      } else if (state is LocationSearchError) {
                        WidgetsBinding.instance.addPostFrameCallback((_) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Text(state.message),
                            ),
                          );
                        });
                      }
                      // On retourne un SizedBox.shrink() pour ne rien afficher
                      return const SizedBox.shrink();
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
                    setState(() {
                      mapController = controller;
                    });
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
                  onPressed: (){
                    BlocProvider.of<ImagesBloc>(context).add(UpdateImages(imageURLList));
                  },
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
              BlocBuilder<ImagesBloc, PickImagesState>(
                builder: (context, state) {
                  if (state is PickImagesLoaded) {
                    imageURLList = state.imageURLList;
                  } else if (state is ErrorState) {
                    WidgetsBinding.instance.addPostFrameCallback((_) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text(state.message),
                        ),
                      );
                    });
                  }
                  return const SizedBox.shrink();
                },
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