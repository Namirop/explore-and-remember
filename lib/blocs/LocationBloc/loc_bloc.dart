import 'package:flutter_bloc/flutter_bloc.dart';
import '../../firebase/firestore_service.dart';
import 'loc_events.dart';
import 'loc_states.dart';
import '../../Location.dart';

class LocationBloc extends Bloc<LocationEvent, LocationState> {
  final FirestoreService _firestoreService;
  LocationBloc(this._firestoreService) : super(LocationInitial()) {
    on<GetLocations>((event, emit) async {
      emit(LocationLoading());
      try {
        await for (var locations in _firestoreService.getLocations()) {
          emit(LocationsLoaded(locations));
        }
      } catch (e) {
        emit(LocationError("Récupération des lieux impossible : $e"));
      }
    });

    on<AddLocation>((event, emit) async {
      emit(LocationLoading());
      try {
        await _firestoreService.addLocation(event.name, event.date, event.note, event.imageURLList, event.latitude, event.longitude);
      } catch (e) {
        emit(LocationError("Ajout du lieu impossible : $e"));
      }
    });

    on<UpdateLocation>((event, emit) async {
      emit(LocationLoading());
      try {
        await _firestoreService.updateLocation(event.name, event.date, event.note, event.imageURLList, event.id, event.latitude, event.longitude);
      } catch (e) {
        emit(LocationError("Modification du lieu impossible : $e"));
      }
    });

    on<DeleteLocation>((event, emit) async {
      emit(LocationLoading());
      try {
        await _firestoreService.deleteLocation(event.location);
      } catch (e) {
        emit(LocationError("Suppression du lieu impossible : $e"));
      }
    });

    on<GetLocationInformation>((event, emit) async {
      emit(LocationLoading());
      try {
        Location location = await _firestoreService.getLocationInformation(event.locationId);
        emit(LocationLoaded(location));
      } catch (e) {
        emit(LocationError("Récupération des informations du lieu impossible : $e"));
      }
    });

  }
}