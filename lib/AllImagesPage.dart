import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';

class AllImagesPage extends StatefulWidget {
  const AllImagesPage({Key? key}) : super(key: key);

  @override
  State<AllImagesPage> createState() => _AllImagesPageState();
}

class _AllImagesPageState extends State<AllImagesPage> {

  late List<String> allImagesURLList = [];

  @override
  void initState() {
    super.initState();
    getAllImagesURLs();
  }

  getAllImagesURLs() {
      Reference imageReference = FirebaseStorage.instance.ref().child('images');
      imageReference.listAll().then((value) {
        for (var image in value.items) {
          image.getDownloadURL().then((value) {
            setState(() {
              allImagesURLList.add(value);
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
        title: const Text('All Pictures'),
      ),
      body: Center(
        child: Column(
          children: [
            Expanded(
              child: ListView.builder(
                itemCount: allImagesURLList.length,
                itemBuilder: (context, index) {
                  return Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Image.network(allImagesURLList[index]),
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