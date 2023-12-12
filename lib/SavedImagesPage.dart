import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';

class SavedImagesPage extends StatefulWidget {
  const SavedImagesPage({Key? key}) : super(key: key);

  @override
  State<SavedImagesPage> createState() => _SavedImagesPageState();
}

class _SavedImagesPageState extends State<SavedImagesPage> {

  late List<String> savedImagesURLList = [];

  @override
  void initState() {
    super.initState();
    getSavedImagesURLs();
  }

  getSavedImagesURLs() {
    Reference imageReference = FirebaseStorage.instance.ref().child('saved');
    imageReference.listAll().then((value) {
      for (var image in value.items) {
        image.getDownloadURL().then((value) {
          setState(() {
            savedImagesURLList.add(value);
          });
        });
      }
    });
  }


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        title: const Text('Saved Pictures'),
      ),
      body: Center(
        child: Column(
          children: [
            Expanded(
              child: ListView.builder(
                itemCount: savedImagesURLList.length,
                itemBuilder: (context, index) {
                  return Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Image.network(savedImagesURLList[index]),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}