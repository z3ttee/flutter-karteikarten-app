import 'dart:ui';
import 'package:flutter/material.dart';

// This adds mouse devices to the drag Devices list.
// Causing: Allows mouse devices to drag swipeable elements

class PointerScrollBehaviour extends MaterialScrollBehavior {
  @override
  Set<PointerDeviceKind> get dragDevices => {
    PointerDeviceKind.touch,
    PointerDeviceKind.mouse,
  };
}