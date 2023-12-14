import 'dart:ui';

import 'package:explore_and_remember/InformationLocationPage.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'AddLocationPage.dart';
import 'AllImagesPage.dart';
import 'MapPage.dart';
import 'SavedImagesPage.dart';
import 'blocs/LocationBloc/loc_bloc.dart';
import 'blocs/LocationBloc/loc_events.dart';
import 'blocs/LocationBloc/loc_states.dart';
import 'firebase/firebase_options.dart';
import 'Location.dart';
import 'firebase/firestore_service.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
        providers: [
          BlocProvider<LocationBloc>(
            create: (context) => LocationBloc(FirestoreService()),
          ),
        ],
        child: MaterialApp(
          title: 'Explorer and Remember',
          debugShowCheckedModeBanner: false,
          theme: ThemeData(
            colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
            useMaterial3: true,
          ),
          home: const MyHomePage(title: 'Explorer and Remember'),
        )
    );
  }
}

class MyHomePage extends StatefulWidget {

  final String title;
  const MyHomePage({super.key, required this.title});

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {

  @override
  void initState() {
    BlocProvider.of<LocationBloc>(context).add(GetLocations());
    super.initState();
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
          widget.title.toUpperCase(),
          style: const TextStyle(
            fontWeight: FontWeight.bold,
          ),
        ),
      ),

      drawer: Drawer(
        child: ListView(
          padding: EdgeInsets.zero,
          children: [
            const SizedBox(
              height: 150,
              child: DrawerHeader(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [
                      Color(0xC3A2CDFA),
                      Color(0xC30B6A85),
                    ],
                  ),
                ),
                child: Text(
                  'EXPLORER AND REMEMBER',
                  style: TextStyle(
                    color: Colors.black,
                    fontSize: 20,
                  ),
                ),
              ),
            ),
            ListTile(
              leading: const Icon(Icons.home),
              title: const Text('LISTE DES LIEUX'),
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const MyHomePage(title: 'Explorer and Remember',),
                  ),
                );
              },
            ),
            ListTile(
              leading: const Icon(Icons.photo),
              title: const Text('PHOTOS'),
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const AllImagesPage(),
                  ),
                );
              },
            ),
            ListTile(
              leading: const Icon(Icons.star),
              title: const Text('SAUVEGARDEES'),
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const SavedImagesPage(),
                  ),
                );
              },
            ),
            ListTile(
              leading: const Icon(Icons.map),
              title: const Text('CARTES DES LIEUX'),
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const MapPage(
                      title: 'Cartes des lieux',
                    ),
                  ),
                );
              },
            ),
          ],
        )
      ),


      body: BlocBuilder<LocationBloc, LocationState>(
        builder: (context, state) {
          if (state is LocationLoading) {
            return const CircularProgressIndicator();
          } else if (state is LocationsLoaded) {
            final List<Location> locations = state.locations;
            return ListView.builder(
              itemCount: locations.length,
              itemBuilder: (context, index) {
                final Location location = locations[index];
                return Card(
                  margin: const EdgeInsets.all(8.0),
                  child: Row(
                    children: [
                      Expanded(
                        child: ListTile(
                          title: Text(location.getName),
                          subtitle: Text(location.getDate),
                          onTap: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => InformationLocationPage(
                                  location: location,
                                ),
                              ),
                            );
                          },
                        ),
                      ),
                      GestureDetector(
                        onTap: () {
                          showDialog(
                            context: context,
                            builder: (BuildContext context) {
                              return Dialog(
                                  child: BackdropFilter(
                                    filter: ImageFilter.blur(sigmaX: 0, sigmaY: 0),
                                    child: Image.network(
                                      location.getFirstImage()!,
                                      fit: BoxFit.contain,
                                    ),
                                  )
                              );
                            },
                          );
                        },
                        child: SizedBox(
                          width: 120,
                          height: 80,
                          child: location.getFirstImage() != null
                              ? Image.network(
                            location.getFirstImage()!,
                            fit: BoxFit.cover,
                          )
                              : const Text("Aucune image"),
                        ),
                      ),
                    ],
                  ),
                );
              },
            );
          } else if (state is LocationError) {
            return const Text("Erreur lors de la récupération des lieux");
          }
          return const Text("Aucun lieu");
        },
      ),


      floatingActionButton: FloatingActionButton.extended(
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => const AddLocationPage(),
            ),
          );
        },
        label: const Text('Ajouter un lieu'),
        icon: const Icon(Icons.add),
        backgroundColor: const Color(0xC3A2CDFA),
      ),
    );
  }
}

