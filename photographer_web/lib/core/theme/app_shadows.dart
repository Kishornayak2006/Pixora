import 'package:flutter/material.dart';

class AppShadows {
  AppShadows._();

  static List<BoxShadow> card = [
    BoxShadow(
      color: Colors.black.withOpacity(.05),
      blurRadius: 30,
      offset: const Offset(0, 10),
    ),
  ];

  static List<BoxShadow> sidebar = [
    BoxShadow(
      color: Colors.black.withOpacity(.04),
      blurRadius: 25,
      offset: const Offset(5, 0),
    ),
  ];
}