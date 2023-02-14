
//import 'dart:convert';
import 'dart:convert';

import 'package:uuid/uuid.dart';

import 'package:flutter_karteikarten_app/entities/Card.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'Module.dart';

class StorageManager {
  //https://docs.flutter.dev/cookbook/persistence/reading-writing-files
  StorageManager();


  Future<bool> saveAll(Map<String, Module> modules) async {
    final prefs = await SharedPreferences.getInstance();
    Map json2 = {};
    modules.forEach((key, value) {
      json2[key] = json.encode(value);
    });
    //print(json.encode(modules));


    return await prefs.setString("data", json.encode(modules));
  }


  Future<Map<String, Module>> readALl() async {
    final prefs = await SharedPreferences.getInstance();
    final String? modulesAsString = prefs.getString("data");
    //Map<String,Module> x = json.decode(modulesAsString!) ;
    Map<String, Module> result = {};
    if(modulesAsString == null){return result;};
    Map x = json.decode(modulesAsString!);
    x.forEach((key, value) {
      result[key] = Module(value['name'], value['description']);
      result[key]?.id = value['id'];
      //print(value);
      List f = value['cards'];
      int wrongCounter = 0;
      f.forEach((e) {
        Card y = Card(e['question'], e['answer']);
        y.id = e['id'];
        y.lastCorrect = e['lastCorrect'];
        if ((e['lastCorrect'] as bool)) {
          wrongCounter++;
        }
        //print(result);
        result[key]!.cards[y.id] = y;
      });
      result[key]!.wrongCounter = wrongCounter;
      //print(result[key]?.id);
    });
    return result;
  }

  Future<bool> saveModule(Module module) async {
    Map<String, Module> currentData = await readALl() ;
    currentData[module.id] = module;
    return await saveAll(currentData);
  }

  Future<bool> saveCard(String moduleId, Card card) async {
    Map<String, Module> currentData = await readALl();
    currentData[moduleId]!.cards[card.id] = card;
    return await saveAll(currentData);
  }
  
  
  

  Map<String, Module> getDummy(int y) {
    Map<String, Module> x = {};
    for (int i = 0; i < y; i++) {
      Module zzz = Module("name $i", "description $i");
      x[zzz.id] = zzz;
      for (int j = 0; j < 3; j++) {
        Card ddd = Card("question $j", "answer $j");
        if((j%2) == 0){ddd.lastCorrect = true;};
        x[zzz.id]?.cards[ddd.id] = ddd;
      }
    }

    return x;
  }

  Future<Map<String, Module>> getDummyModules(int y) {
    Map<String, Module> x = {};
    for (int i = 0; i < y; i++) {
      Module zzz = Module("name $i", "description $i");
      x[zzz.id] = zzz;
    }
    return Future.value(x);
  }
}