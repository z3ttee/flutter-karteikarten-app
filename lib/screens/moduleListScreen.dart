
import 'package:flutter/material.dart';
import 'package:flutter_karteikarten_app/dialogs/moduleEditorDialog.dart';
import 'package:flutter_karteikarten_app/widgets/moduleItemCard.dart';

class ModuleListScreen extends StatelessWidget {
  const ModuleListScreen({super.key});

  Future<Map<String,Module>> _fetchListItems() async {
    return Future.delayed(const Duration(milliseconds: 1), () async {
<<<<<<< HEAD
      StorageManager test = StorageManager();
   

      return test.getDummyModules(5);
=======
      return [];
>>>>>>> 4222937b98b5d15fe31a09a22e2653d1848a0524
    });
  }

  _openModuleEditor(BuildContext ctx) {
    print("Opening module editor");
    showDialog(
      context: ctx,
      builder: (context) {
        return const ModuleEditorDialog();
      }
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      floatingActionButton: FloatingActionButton(
        onPressed: () => _openModuleEditor(context),
        child: const Icon(Icons.add)
      ),
      body: FutureBuilder(
          future: _fetchListItems(),
          builder: (context, snapshot) {
            if (!snapshot.hasData) {
              return const Center(child: CircularProgressIndicator());
            } else {
              if((snapshot.data?.length ?? 0) > 0) {
                return CustomScrollView(
                  slivers: <Widget>[
                    SliverAppBar.medium(
                      title: const Text("Modulübersicht"),
                      actions: <Widget>[
                        IconButton(onPressed: () {}, icon: const Icon(Icons.info_outline))
                      ],
                    ),
                    SliverList(delegate: SliverChildBuilderDelegate((context, index) {
                        int maxIndex = (snapshot.data?.length ?? 1) - 1;
                        return Padding(
                          padding: EdgeInsets.only(left: 12, right: 12, top: (index == 0) ? 12 : 0, bottom: (index == maxIndex) ? 96 : 0),
                          child: ModuleItemCard(
                            name: "Modul #${index + 1}",
                            filled: true,
                          ),
                        );
                      },
                      childCount: snapshot.data?.length ?? 0
                    )),
                  ],
                );
              } else {
                return CustomScrollView(
                  slivers: <Widget>[
                    SliverAppBar.medium(
                      title: const Text("Modulübersicht"),
                      centerTitle: true,
                      scrolledUnderElevation: 4,
                      actions: <Widget>[
                        Padding(
                          padding: const EdgeInsets.only(left: 4, right: 12),
                          child: IconButton(onPressed: () {}, icon: const Icon(Icons.info_outline_rounded)),
                        )
                      ],
                    ),
                    SliverList(delegate: SliverChildBuilderDelegate((context, index) {
                      int maxIndex = 9;
                      return Padding(
                        padding: EdgeInsets.only(
                            left: 12,
                            right: 12,
                            top: (index != 0) ? 0 : 12,
                            bottom: (index != maxIndex) ? 0 : 96
                        ),
                        child: ModuleItemCard(
                          name: "Modul #${index + 1}",
                          filled: true,
                        ),
                      );
                    },
                        childCount: 10
                    )),
                  ],
                );
              }
            }
          }
      ),
    );
  }

}

