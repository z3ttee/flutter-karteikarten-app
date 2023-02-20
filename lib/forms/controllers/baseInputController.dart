
import 'package:flutter/cupertino.dart';

abstract class BaseInputController<T> extends ValueNotifier<T> {

  BaseInputController(T value): super(value);

}