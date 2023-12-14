import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

import 'blocs/LocationBloc/loc_bloc.dart';
import 'blocs/LocationBloc/loc_events.dart';
import 'blocs/LocationBloc/loc_states.dart';

class MapPage extends StatefulWidget {
  const MapPage({Key? key, required this.title}) : super(key: key);

  final String title;

  @override
  State<MapPage> createState() => _MapPageState();
}

class _MapPageState extends State<MapPage> {

  @override
  void initState() {
    BlocProvider.of<LocationBloc>(context).add(GetLocations());
    super.initState();
  }


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.title.toUpperCase(),
            style: const TextStyle(
                color: Colors.black,
                fontWeight: FontWeight.bold,
            )
        ),
        centerTitle: true,
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
      body: BlocBuilder<LocationBloc, LocationState>(
        builder: (context, state) {
          if (state is LocationLoading) {
            return const Center(
                child: CircularProgressIndicator()
            );
          } else if (state is LocationsLoaded) {
            return GoogleMap(
              initialCameraPosition: const CameraPosition(
                target: LatLng(0.0, 0.0),
                zoom: 1,
              ),
              markers: state.locations.map((location) => Marker(
                markerId: MarkerId(location.getName),
                position: LatLng(location.getLatitude, location.getLongitude),
                infoWindow: InfoWindow(
                  title: location.name,
                  snippet: location.note,
                ),
              )).toSet(),
            );
          } else {
            return const Center(
                child: Text("Erreur lors du chargement des lieux")
            );
          }
        },
      ),
    );
  }
}