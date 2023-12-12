import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class AllPicturesPage extends StatefulWidget {
  const AllPicturesPage({Key? key}) : super(key: key);

  @override
  State<AllPicturesPage> createState() => _AllPicturesPageState();
}

class _AllPicturesPageState extends State<AllPicturesPage> {

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