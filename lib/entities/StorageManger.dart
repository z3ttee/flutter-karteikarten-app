
//import 'dart:convert';
import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:uuid/uuid.dart';

import 'package:flutter_karteikarten_app/entities/Card.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'Module.dart';

class StorageManager {
  //Empty Constructor
  StorageManager();

  //Save all Entries
  Future<bool> saveAll(Map<String, Module> modules) async {
    //shared Preferences Instance
    final prefs = await SharedPreferences.getInstance();
    Map jsonMap = {};
    //Decode the objects
    modules.forEach((key, value) {
      jsonMap[key] = json.encode(value);
    });
    //save data an return the state of save
    return await prefs.setString("data", json.encode(modules));
  }

  //read the whole list
  Future<Map<String, Module>> readALl() async {
    final prefs = await SharedPreferences.getInstance();
    final String? modulesAsString = prefs.getString("data");
    //Map<String,Module> x = json.decode(modulesAsString!) ;
    Map<String, Module> result = {};
    //Check if list exists, if not retrive an empty one
    if(modulesAsString == null){
      //in debug mode, create a dummy list
      if(kDebugMode){return getDummy(5);}
      return result;
    }
    //Json to Objects
    Map jsonRaw = json.decode(modulesAsString!);
    //Create the Modules from json
    jsonRaw.forEach((key, value) {
      result[key] = Module(value['name'], value['description']);
      result[key]?.id = value['id'];
      //print(value);
      List rawMapCards = value['cards'];
      //Count the last wrong cards
      int wrongCounter = 0;
      //Create Cards from Json
      rawMapCards.forEach((e) {
        Card y = Card(e['question'], e['answer']);
        y.id = e['id'];
        y.lastCorrect = e['lastCorrect'];
        if ((e['lastCorrect'] as bool)) {
          wrongCounter++;
        }
        //Add cards to modules
        result[key]!.cards[y.id] = y;
      });
      //Add the amount of wrong answerd questions
      result[key]!.wrongCounter = wrongCounter;
    });
    return result;
  }

  //Save one Module
  Future<bool> saveModule(Module module, {bool overwriteCards =false}) async {
    //Read the current data
    Map<String, Module> currentData = await readALl() ;
    //Check if the cards of a module schould be overwritten
    if(!overwriteCards) {
      //get current cards
      Map<String, Card>? moduleCards = currentData[module.id]?.cards;
      if(!(moduleCards == null)){
        //Add old cards to current module
        currentData[module.id]!.cards = moduleCards;
      }
    }
    //save the new module in the list
    currentData[module.id] = module;
    //Save data to storage
    return await saveAll(currentData);
  }

  //Method to save on Card in a module
  Future<bool> saveCard(String moduleId, Card card) async {
    //retrieve whole Data
    Map<String, Module> currentData = await readALl();
    //Save the Card in the Module
    currentData[moduleId]!.cards[card.id] = card;
    //Save to Storage
    return await saveAll(currentData);
  }

  Future<Module?> readOneModule(String moduleId) async{
    //retrieve whole Data
    Map<String, Module> currentData = await readALl();
    //get the module
    Module? result = currentData[moduleId];
    //return the Module
    return result;
  }
  
  
  //Dev methode for dummy data
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