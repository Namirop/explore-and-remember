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
      imageReference.listAll().then((imagesURLList) {
        for (var image in imagesURLList.items) {
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
        title: const Text("ALL IMAGES",
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
                itemCount: allImagesURLList.length,
                itemBuilder: (context, index) {
                  return Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Image.network(
                        allImagesURLList[index]
                    ),
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