import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'blocs/ImagesBloc/images_bloc.dart';
import 'blocs/ImagesBloc/images_events.dart';
import 'blocs/ImagesBloc/images_states.dart';

class AllImagesPage extends StatefulWidget {
  const AllImagesPage({Key? key}) : super(key: key);

  @override
  State<AllImagesPage> createState() => _AllImagesPageState();
}

class _AllImagesPageState extends State<AllImagesPage> {

  late List<String> allImagesURLList;

  @override
  void initState() {
    super.initState();
    BlocProvider.of<ImagesBloc>(context).add(GetImagesURLs());
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
      body: BlocBuilder<ImagesBloc, PickImagesState>(
        builder: (context, state) {
          if (state is GetImagesURLsLoaded) {
            return Center(
              child: Column(
                children: [
                  Expanded(
                    child: ListView.builder(
                      itemCount: state.imageURLList.length,
                      itemBuilder: (context, index) {
                        return Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: Image.network(
                              state.imageURLList[index]
                          ),
                        );
                      },
                    ),
                  ),
                ],
              ),
            );
          } else if (state is ErrorState) {
            return Center(
              child: Text(state.message),
            );
          } else if (state is LoadingState) {
            return const Center(
              child: CircularProgressIndicator(),
            );
          } else if (state is ImagesListIsEmpty) {
            return const Center(
              child: Text("Aucune image"),
            );
          }
          return const SizedBox.shrink();
        },
      ),
    );
  }
}