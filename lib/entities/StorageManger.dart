
//import 'dart:convert';
import 'package:uuid/uuid.dart';

import 'package:flutter_karteikarten_app/entities/Card.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'Module.dart';

class StorageManager{
  //https://docs.flutter.dev/cookbook/persistence/reading-writing-files
  StorageManager();

  void saveAll(Module module) async{
    print(module.id.toString());
    final prefs = await SharedPreferences.getInstance();

    await prefs.setString(module.id.toString(), module.toJson());
  }

  Future<String?> getModuleByID(int id) async{
    final prefs = await SharedPreferences.getInstance();
    final String? module = prefs.getString(id.toString());

    print(module);
    return module;
  }
  Future<String?> getModules() async{
    final prefs = await SharedPreferences.getInstance();
    final String? module = prefs.getString("data");

    print(module);
    return module;
  }

  Map<String,Module> getDummy(int y ){
    Map<String,Module> x = {};
    for(int i = 0; i < y; i++){
      Module zzz = Module("name $i", "description $i");
      x[zzz.id] = zzz;
      for (int j = 0; j < 3 ; j++){
        Card ddd = Card("question $j", "answer $j");
        x[zzz.id]?.cards[ddd.id] = ddd;
      }
    }
    return x;
  }

  Future<Map<String,Module>> getDummyModules(int y ){
    Map<String,Module> x = {};
    for(int i = 0; i < y; i++){
      Module zzz = Module("name $i", "description $i");
      x[zzz.id] = zzz;
    }
    return Future.value(x);
  }

  void Jsono(){
    Map<String,Module> json = getDummy(5);
    //print(json);
     /*
    json.forEach((key, value) {
      json[key]?.cards?.forEach((key, value) {
        print(value.answer);
      });
    });
    */
  }


/*
  x(){
    return
      [
      {
        "moduleName" : modle.name,
        "moduleDescription" : m.d,
        "moduleId" : m.id,
        "cards": [
          {

          }

        ]
      }
    ]
  }
  */
}