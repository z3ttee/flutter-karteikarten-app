import 'dart:convert';
import 'dart:math';
import 'package:flutter/foundation.dart';
import 'package:flutter_karteikarten_app/constants.dart';
import 'package:flutter_karteikarten_app/entities/Card.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'Module.dart';

class StorageManager {
  //Empty Constructor
  StorageManager();

  /// Save all modules in shared preferences
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

  /// Read all modules from shared preferences
  Future<Map<String, Module>> readAll({int dummyElements = 8}) async {
    // Get instance of shared preferences
    final prefs = await SharedPreferences.getInstance();
    // Read json string from shared preferences
    final String? modulesAsString = prefs.getString("data");
    // Create empty instance of a map
    Map<String, Module> result = {};


    // Check if list exists (a valid string was returned previously).
    // If not return the empty instance from above
    if (modulesAsString == null) {
      // in debug mode, create a dummy list
      if (kDebugMode) {
        var dummies = getDummy(dummyElements);
        return saveAll(dummies).then((value) => dummies);
      }
      // If not in debug mode, return empty list
      return result;
    }
    //Json to Objects
    Map jsonRaw = json.decode(modulesAsString);
    //Create the Modules from json
    jsonRaw.forEach((key, value) {
      result[key] = Module(value['name'], value['description']);
      result[key]?.id = value['id'];
      result[key]?.iterations = value['iterations'];
      //print(value);
      List rawMapCards = value['cards'];
      //Count the last correctly answered cards
      int correctCardsCounter = 0;

      // Loop through cards in decoded json map
      for (var entity in rawMapCards) {
        // Instantiate new card
        IndexCard newCard = IndexCard(entity['question'], entity['answer']);
        newCard.id = entity['id'];
        newCard.lastCorrect = entity['lastCorrect'];
        newCard.cardAnswer = CardAnswer.getById(entity['cardAnswer']);
        newCard.cardWeight = CardWeight.getById(entity['cardWeight']);
        newCard.color = entity['color'];

        // If the card was answered incorrectly in last iteration
        // increase wrong counter
        if ((entity['lastCorrect'] as bool)) {
          correctCardsCounter++;
        }

        //Add cards to modules map
        result[key]!.cards[newCard.id] = newCard;
      }

      //Add the amount of wrong answerd questions
      result[key]!.correctCards = correctCardsCounter;
    });
    return result;
  }

  /// Save a single module to shared preferences. Setting overwriteCards=true overwrites attached cards.
  Future<bool> saveModule(Module module, {bool overwriteCards = false}) async {
    //Read the current data
    Map<String, Module> currentData = await readAll();
    //Check if the cards of a module schould be overwritten
    if (overwriteCards) {
      //get current cards
      Map<String, IndexCard>? moduleCards = currentData[module.id]?.cards;
      if (!(moduleCards == null)) {
        //Add old cards to current module
        currentData[module.id]!.cards = moduleCards;
      }
    }
    //save the new module in the list
    currentData[module.id] = module;
    //Save data to storage
    return await saveAll(currentData);
  }

  /// Save a single card on a module. If the card does not exist on the module, it will be created. Otherwise the card is updated.
  Future<bool> saveCard(String moduleId, IndexCard card) async {
    //retrieve whole Data
    Map<String, Module> currentData = await readAll();
    //Save the Card in the Module
    currentData[moduleId]!.cards[card.id] = card;
    //Save to Storage
    return await saveAll(currentData);
  }

  Future<Module?> readOneModule(String? moduleId) async {
    if (moduleId == null) return null;
    //retrieve whole Data
    Map<String, Module> currentData = await readAll();
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

      var maxCards = Random().nextInt(10);
      var correctCardsCounter = 0;

      for (int j = 0; j < maxCards; j++) {
        IndexCard ddd = IndexCard("question $j", "answer $j");
        ddd.lastCorrect = Random().nextBool();
        if (ddd.lastCorrect) correctCardsCounter++;
        ddd.cardWeight = CardWeight.normal;
        ddd.cardAnswer = CardAnswer.never;
        x[zzz.id]?.cards[ddd.id] = ddd;
      }

      x[zzz.id]?.correctCards = correctCardsCounter;
    }

    return x;
  }

  Future<bool> deleteOneModule(String moduleId) async {
    Map<String, Module> currentData = await readAll();
    currentData.remove(moduleId);
    return saveAll(currentData);
  }

  Future<bool> deleteOneCard(String? moduleId, String cardId) async {
    if (moduleId == null) return false;
    Map<String, Module> currentData = await readAll();
    currentData[moduleId]!.cards.remove(cardId);
    return saveAll(currentData);
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
