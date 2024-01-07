import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:explore_and_remember/blocs/SearchPlaceBloc/search_place_events.dart';
import 'package:explore_and_remember/blocs/SearchPlaceBloc/search_place_states.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

const String apiKey = 'AIzaSyBC_9BXrQhZpwI3dWGhKiLtew1kMk1oevc';

class LocationSearchBloc extends Bloc<LocationSearchEvent, LocationSearchState> {
  LocationSearchBloc() : super(LocationSearchInitial()) {
    on<SearchLocation>((event, emit) async {
      emit(LocationSearchLoading());
        try {
          final String locationQuery = event.locationQuery;
          final String apiUrl = 'https://maps.googleapis.com/maps/api/place/textsearch/json?query=$locationQuery&key=$apiKey';
          final response = await http.get(Uri.parse(apiUrl));

          if (response.statusCode == 200) {
            // convertie la réponse json en objet dart
            final data = json.decode(response.body);
            final double latitude;
            final double longitude;
            if (data['results'].isEmpty) {
              emit(LocationSearchIsEmpty());
            } else {
              latitude = data['results'][0]['geometry']['location']['lat'];
              longitude = data['results'][0]['geometry']['location']['lng'];
              emit(LocationSearchLoaded(latitude, longitude));
            }
          }
        } catch (e) {
          emit(LocationSearchError('Erreur lors de la récupération des lieux : $e'));
        }
    });
  }
}