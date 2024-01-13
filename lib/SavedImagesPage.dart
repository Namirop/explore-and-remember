import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'blocs/ImagesBloc/images_bloc.dart';
import 'blocs/ImagesBloc/images_events.dart';
import 'blocs/ImagesBloc/images_states.dart';

class SavedImagesPage extends StatefulWidget {
  const SavedImagesPage({Key? key}) : super(key: key);

  @override
  State<SavedImagesPage> createState() => _SavedImagesPageState();
}

class _SavedImagesPageState extends State<SavedImagesPage> {

  @override
  void initState() {
    super.initState();
    BlocProvider.of<ImagesBloc>(context).add(GetSavedImagesURLs());
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
      body: BlocBuilder<ImagesBloc, PickImagesState>(
        builder: (context, state) {
          if (state is LoadingState) {
            return const Center(
              child: CircularProgressIndicator(),
            );
          } else if (state is GetSavedImagesURLsLoaded) {
            final List<String> allSavedImagesURLList = state.savedImageURLList;
            return Center(
              child: Column(
                children: [
                  Expanded(
                    child: ListView.builder(
                      itemCount: allSavedImagesURLList.length,
                      itemBuilder: (context, index) {
                        return Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: Image.network(
                              allSavedImagesURLList[index]
                          ),
                        );
                      },
                    ),
                  ),
                ],
              ),
            );
          } else if (state is SavedImagesListIsEmpty) {
            return const Center(
              child: Text("Aucune image sauvegardée"),
            );
          } else if (state is ErrorState) {
            WidgetsBinding.instance.addPostFrameCallback((_) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text(state.message),
                ),
              );
            });
          }
          return const Center(
            child: CircularProgressIndicator(),
          );
        },
      ),
    );
  }
}