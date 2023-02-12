
import 'package:flutter/material.dart';
import 'package:flutter_karteikarten_app/widgets/moduleItemCard.dart';

class ModuleListView extends StatelessWidget {
  const ModuleListView({super.key});

  Future<List<dynamic>> _fetchListItems() async {
    return Future.delayed(const Duration(milliseconds: 500), () {
      return [];
    });
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder(
      future: _fetchListItems(),
      builder: (context, snapshot) {
        if (!snapshot.hasData) {
          return const Center(child: CircularProgressIndicator());
        } else {
          if((snapshot.data?.length ?? 0) > 0) {
            return ListView.builder(
                itemCount: snapshot.data?.length ?? 0,
                scrollDirection: Axis.vertical,
                itemBuilder: (context, int index) {
                  int maxIndex = (snapshot.data?.length ?? 1) - 1;

                  return Padding(
                    padding: EdgeInsets.only(left: 16, right: 16, top: (index == 0) ? 16 : 0, bottom: (index == maxIndex) ? 16 : 0),
                    child: ModuleItemCard(
                      name: "Modul #${index + 1}",
                      filled: true,
                    ),
                  );
                }
            );
          } else {
            return ListView.builder(
                itemCount: 10,
                scrollDirection: Axis.vertical,
                itemBuilder: (context, index) {
                  const maxIndex = 9;

                  return Padding(
                    padding: EdgeInsets.only(left: 16, right: 16, top: (index == 0) ? 16 : 0, bottom: (index == maxIndex) ? 16 : 0),
                    child: ModuleItemCard(
                      name: "Modul #${index + 1}",
                      filled: true,
                    ),
                  );
                }
            );
          }
        }
      }
    );
  }

}