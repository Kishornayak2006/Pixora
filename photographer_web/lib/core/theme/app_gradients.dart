import 'package:flutter/material.dart';

import 'app_colors.dart';

class AppGradients {
  AppGradients._();

  static const primary = LinearGradient(
    colors: [
      AppColors.primary,
      AppColors.secondary,
    ],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static const sidebar = LinearGradient(
    colors: [
      Color(0xffFFFFFF),
      Color(0xffF8F4FF),
    ],
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
  );

  static const background = LinearGradient(
    colors: [
      Color(0xffFAFBFF),
      Color(0xffF4F0FF),
    ],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );
}