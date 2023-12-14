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
    imageReference.listAll().then((savedImageURLList) {
      for (var image in savedImageURLList.items) {
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
        title: const Text("SAVED IMAGES",
            style: TextStyle(
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