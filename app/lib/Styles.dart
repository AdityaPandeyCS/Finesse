import 'dart:math';
import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:flutter_statusbarcolor/flutter_statusbarcolor.dart';

/// Contains constant [Color] values

/// The primary background color.
const Color primaryBackground = Color(0xff232323);

/// The secondary background color.
const Color secondaryBackground = Color(0xff2a2a2a);

/// The primary highlight color.
const Color primaryHighlight = Color(0xffe2e2e2);

/// The secondary highlight color.
const Color secondaryHighlight = Color(0xff8c8c8c);

/// The text color when the [Finesse] is inactive.
const Color inactiveColor = Color(0xFF606060);

Color getColor(String email, bool isActive) {
  if (email == null) {
    return null;
  }
  int min = 0xff000000;
  int max = 0xffffffff;
  int seed = email.codeUnits.fold(0, (i, j) => i + j);
  int val = min + Random(seed).nextInt(max - min + 1);
  Color c = Color(val);
  if (!isActive) {
//      int r = c.red, g = c.green, b = c.blue;
//      int luminosity = (0.299 * r + 0.587 * g + 0.114 * b).round();
    double l = c.computeLuminance();
    val = (l * 255).round();
    return Color.fromARGB(255, val, val, val);
  }
  return Color(val);
}

void changeStatusColor(Color color) async {
  try {
    FlutterStatusbarcolor.setStatusBarColor(color, animate: true);
    if (useWhiteForeground(color)) {
      FlutterStatusbarcolor.setStatusBarWhiteForeground(true);
      FlutterStatusbarcolor.setNavigationBarWhiteForeground(true);
    } else {
      FlutterStatusbarcolor.setStatusBarWhiteForeground(false);
      FlutterStatusbarcolor.setNavigationBarWhiteForeground(false);
    }
  } catch (e) {
    debugPrint(e.toString());
  }
}

void changeNavigationColor(Color color) async {
  try {
    FlutterStatusbarcolor.setNavigationBarColor(color, animate: true);
  } catch (e) {
    debugPrint(e.toString());
  }
}
