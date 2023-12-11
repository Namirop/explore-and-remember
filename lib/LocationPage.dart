import 'package:explore_and_remember/blocs/LocationBloc/loc_events.dart';
import 'package:explore_and_remember/main.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';
import 'Location.dart';
import 'blocs/LocationBloc/loc_bloc.dart';

class LocationPage extends StatefulWidget {
  final Location location;

  const LocationPage({
    Key? key,
        required this.location,
  }) : super(key: key);

  @override
  State<LocationPage> createState() => _LocationPageState();
}

class _LocationPageState extends State<LocationPage> {

  late Location location;
  late TextEditingController name;
  late DateTime date;
  late TextEditingController note;
  late TextEditingController gps = TextEditingController(text: "Fonctionnalité non implémentée");
  late String id;
  late List<String> imageURLList = [];

  @override
  void initState() {
    super.initState();
    location = widget.location;
    name = TextEditingController(text: location.getName);
    note = TextEditingController(text: location.getNote);
    imageURLList = location.getImageURLs();
    id = location.getID;
    date = DateFormat("MMMM dd, yyyy").parse(location.getDate); // convertie la date String en DateTime
  }

  Future _selectDate(BuildContext context) async {
    // 'showDatePicker' retourne un pickedDate, càd la date choisit dans le calendrier
    // 'showDatePicker' est une fonction asynchrone, donc on utilise 'await'
    final DateTime? pickedDate = await showDatePicker(
      context: context,
      initialDate: date,
      firstDate: DateTime(1910),
      lastDate: DateTime(date.year + 1),
    );
    // si pickedDate n'est pas null, on met à jour la date
    if (pickedDate != null) {
      setState(() => date = pickedDate);
    }
  }

  _displayToast() {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Fonctionnalité non implémentée'),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme
            .of(context)
            .colorScheme
            .inversePrimary,
        title: Text(location.getName),
        actions: [
          IconButton(
            icon: const Icon(Icons.delete),
            onPressed: () {
              BlocProvider.of<LocationBloc>(context).add(DeleteLocation(location));
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
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Nom du lieu :',
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
            TextField(
                controller: name,
                decoration: InputDecoration(
                  hintText: location.getName,
                ),
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
            Text(DateFormat('MMMM dd, yyyy').format(date)),
            const SizedBox(height: 16.0),
            const Text(
              'Notes : ',
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
            TextField(
                controller: note,
                decoration: InputDecoration(
                  hintText: location.getNote,
                )
            ),
            const SizedBox(height: 16.0),
            const Text(
              'Coordonnées GPS :',
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
            TextField(
                controller: gps,
                decoration: const InputDecoration(
                  hintText: "Fonctionnalité non implémentée",
                )
            ),
            const SizedBox(height: 16.0),
            const Text(
              'Photos :',
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
            Container(
              margin: const EdgeInsets.only(top: 16.0),
              child: ElevatedButton(
                onPressed: _displayToast,
                child: const Text('Ajouter une photo'),
              ),
            ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () {
          BlocProvider.of<LocationBloc>(context).add(UpdateLocation(name.text, date, note.text, imageURLList, id, location.getLongitude, location.getLatitude));
          Navigator.pop(context);
        },
        label: const Text('Enregistrer les modifications'),
        icon: const Icon(Icons.update),
      ),
    );
  }
}