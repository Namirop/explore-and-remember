import 'dart:io';

import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:image_picker/image_picker.dart';

import 'blocs/LocationBloc/loc_bloc.dart';
import 'blocs/LocationBloc/loc_events.dart';

class AddLocationPage extends StatefulWidget {
  const AddLocationPage({Key? key}) : super(key: key);

  @override
  State<AddLocationPage> createState() => _AddLocationPageState();
}

class _AddLocationPageState extends State<AddLocationPage> {

  final TextEditingController name = TextEditingController();
  late  DateTime date = DateTime.now();
  final TextEditingController note = TextEditingController();
  final TextEditingController gps = TextEditingController();
  late List<String> imageURLList = [];

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

  Future _pickImageFromPhoneGallery() async {
    final ImagePicker picker = ImagePicker();

    final List<XFile> pickedImagesFromGallery = await picker.pickMultiImage();

    if(pickedImagesFromGallery.isNotEmpty) {
      for (var image in pickedImagesFromGallery) {
        // Ici, on va uploader chaque image choisie dans le storage de Firebase

        // On assigne un nom unique à chaque image via cette methode
        String uniqueFileName = DateTime.now().millisecondsSinceEpoch.toString();

        // On récupère l'extension de l'image
        final ext = image.path.split('.').last;

        //On créer une référence à l'image (le '.$ext' n'est pas obligatoire pour que cela fonctionne)
        Reference imageReference = FirebaseStorage.instance.ref().child('images/$uniqueFileName.$ext');

          // On upload l'image dans le storage de Firebase
        File imageFile = File(image.path);
        // SettableMetadata permet de définir le type de fichier uploadé (l'ajouter sinon cela ne fonctionne pas)
        await imageReference.putFile(imageFile, SettableMetadata(contentType: 'image/$ext'));

        // On récupère l'URL de l'image uploadée
        final imageURL = await imageReference.getDownloadURL();

        // On ajoute l'URL de l'image uploadée dans la liste des URL
        setState(() {
          imageURLList.add(imageURL);
          print("IMAGE URL LIST: $imageURLList");
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Ajouter une location'),
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
            TextField(controller: name),
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
            Text('${date.day}/${date.month}/${date.year}'),
            const SizedBox(height: 16.0),
            const Text(
              'Notes : ',
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
            TextField(controller: note),
            const SizedBox(height: 16.0),
            const Text(
              'Coordonnées GPS :',
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
            TextField(controller: gps),
            const SizedBox(height: 16.0),
            const Text(
              'Photos :',
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
            Container(
              margin: const EdgeInsets.only(top: 16.0),
              child: ElevatedButton(
                onPressed: _pickImageFromPhoneGallery,
                child: const Text('Ajouter une photo'),
              ),
            ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () {
            BlocProvider.of<LocationBloc>(context).add(AddLocation(name.text, date, note.text, imageURLList));
            Navigator.pop(context);
          },
        label: const Text('Ajouter ce lieu'),
        icon: const Icon(Icons.add),
      ),

    );
  }
}

