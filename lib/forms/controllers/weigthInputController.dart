
import 'package:flutter_karteikarten_app/constants.dart';
import 'package:flutter_karteikarten_app/forms/controllers/baseInputController.dart';

class WeightInputController extends BaseInputController<CardWeight> {

  WeightInputController([CardWeight? value]): super(value ?? CardWeight.simple);

}