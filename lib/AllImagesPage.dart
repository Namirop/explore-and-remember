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
          if (state is LoadingState) {
            return const Center(
              child: CircularProgressIndicator(),
            );
          } else if (state is GetImagesURLsLoaded) {
            final List<String> allImagesURLList = state.imageURLList;
            return Center(
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
            );
          } else if (state is ImagesListIsEmpty) {
            return const Center(
              child: Text("Aucune image"),
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
          return const SizedBox.shrink();
        },
      ),
    );
  }
}